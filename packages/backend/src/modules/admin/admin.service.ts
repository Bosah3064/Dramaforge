import { Injectable, NotFoundException } from '@nestjs/common';
import { CoinBucket, EnforcementState, LedgerReason, UserRole } from 'dramaforge-shared';
import { PrismaService } from '../../prisma.service';
import { AIProviderService } from '../ai-provider/ai-provider.service';
import { WalletService } from '../wallet/wallet.service';

export interface EnforceUserDto {
  state: EnforcementState;
  reason: string;
}

export interface AdjustCoinsDto {
  bucket: CoinBucket;
  amount: number; // positive = credit, negative = debit
  reason: string;
}

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
    private readonly aiProvider: AIProviderService,
  ) {}

  async listUsers(search?: string, limit = 50) {
    const where = search ? { email: { contains: search, mode: 'insensitive' as any } } : {};
    const users = await this.prisma.user.findMany({
      where,
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        subscriptions: { where: { status: 'ACTIVE' } },
      },
    });

    const enriched = await Promise.all(
      users.map(async (u) => {
        const balance = await this.walletService.getBalance(u.id);
        const { passwordHash, ...clean } = u;
        return {
          ...clean,
          balance,
        };
      }),
    );

    return enriched;
  }

  async setEnforcement(userId: string, dto: EnforceUserDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const prevState = user.enforcementState;

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { enforcementState: dto.state },
      }),
      this.prisma.enforcementEvent.create({
        data: {
          userId,
          previousState: prevState,
          newState: dto.state,
          reason: `Admin manual action: ${dto.reason}`,
        },
      }),
    ]);

    return { success: true, userId, previousState: prevState, newState: dto.state };
  }

  async adjustCoins(userId: string, dto: AdjustCoinsDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    if (dto.amount >= 0) {
      await this.walletService.grantCoins(
        userId,
        dto.bucket,
        dto.amount,
        LedgerReason.ADMIN_ADJUSTMENT,
        undefined,
        dto.reason,
      );
    } else {
      await this.walletService.deductCoins(
        userId,
        Math.abs(dto.amount),
        LedgerReason.ADMIN_ADJUSTMENT,
        dto.reason,
      );
    }

    const updatedBalance = await this.walletService.getBalance(userId);
    return { success: true, userId, updatedBalance };
  }

  async getModerationQueue(limit = 50) {
    return this.prisma.moderationEvent.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, email: true, enforcementState: true } },
      },
    });
  }

  async getProviderHealth() {
    return {
      activeProvider: this.aiProvider.getProviderName(),
      status: 'HEALTHY',
      timestamp: new Date().toISOString(),
      capabilities: {
        textGeneration: true,
        imageKeyframes: true,
        videoSynthesis: true,
        photoEffects: true,
        assembly: true,
      },
    };
  }
}

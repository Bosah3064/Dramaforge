import {
  BadRequestException,
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { CoinBucket, LedgerReason, UserProfileDto, UserRole } from 'dramaforge-shared';
import { PrismaService } from '../../prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { LoginDto, SignupDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly walletService: WalletService,
  ) {}

  async signup(dto: SignupDto) {
    if (!dto.isAgeVerified) {
      throw new BadRequestException('You must be at least 13 years of age to register for DramaForge.');
    }

    const existing = await this.prisma.user.findUnique({
      where: { email: dto.email.toLowerCase() },
    });

    if (existing) {
      throw new ConflictException('An account with this email already exists.');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(dto.password, salt);

    const user = await this.prisma.user.create({
      data: {
        email: dto.email.toLowerCase(),
        passwordHash,
        isAgeVerified: true,
        role: UserRole.USER,
      },
    });

    // Grant 20 welcome starter coins into PURCHASED (non-expiring) bucket
    await this.walletService.grantCoins(
      user.id,
      CoinBucket.PURCHASED,
      20,
      LedgerReason.GRANT,
      undefined,
      'welcome_bonus',
    );

    const token = this.generateToken(user.id, user.email, user.role);

    return {
      token,
      user: this.toProfileDto(user),
    };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email.toLowerCase() },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials.');
    }

    const matches = await bcrypt.compare(dto.password, user.passwordHash);
    if (!matches) {
      throw new UnauthorizedException('Invalid credentials.');
    }

    const token = this.generateToken(user.id, user.email, user.role);

    return {
      token,
      user: this.toProfileDto(user),
    };
  }

  async getMe(userId: string): Promise<UserProfileDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        subscriptions: {
          where: { status: 'ACTIVE' },
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found.');
    }

    return this.toProfileDto(user);
  }

  private generateToken(userId: string, email: string, role: string): string {
    return this.jwtService.sign({
      sub: userId,
      email,
      role,
    });
  }

  private toProfileDto(user: any): UserProfileDto {
    const sub = user.subscriptions?.[0];
    return {
      id: user.id,
      email: user.email,
      role: user.role,
      enforcementState: user.enforcementState,
      isAgeVerified: user.isAgeVerified,
      createdAt: user.createdAt.toISOString(),
      subscription: sub
        ? {
            tier: sub.tier,
            status: sub.status,
            currentPeriodEnd: sub.currentPeriodEnd.toISOString(),
          }
        : null,
    };
  }
}

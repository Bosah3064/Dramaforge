import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';

export interface ConsentSubmissionDto {
  version: string;
  scope: string;
  providersDisclosed: string[];
  accepted: boolean;
}

@Injectable()
export class ComplianceService {
  private readonly logger = new Logger(ComplianceService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Records user explicit pre-transfer consent before any prompt or media is sent to AI models.
   */
  async recordConsent(userId: string, data: ConsentSubmissionDto, ipAddress?: string) {
    if (!data.accepted) {
      throw new BadRequestException('You must accept the third-party AI data disclosure to use generation features.');
    }

    const record = await this.prisma.consentRecord.create({
      data: {
        userId,
        version: data.version,
        scope: data.scope,
        providersDisclosed: data.providersDisclosed,
        ipAddress: ipAddress ?? null,
      },
    });

    this.logger.log(`Consent recorded for user ${userId}, terms version: ${data.version}`);
    return { success: true, consentId: record.id, acceptedAt: record.acceptedAt };
  }

  /**
   * Checks if the user has an active pre-transfer consent record.
   */
  async hasConsent(userId: string): Promise<boolean> {
    const record = await this.prisma.consentRecord.findFirst({
      where: { userId },
      orderBy: { acceptedAt: 'desc' },
    });
    return !!record;
  }

  /**
   * GDPR Data Portability: exports all user account, project, and transaction data.
   */
  async exportUserData(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        consentRecords: true,
        coinLedgers: true,
        subscriptions: true,
        projects: {
          include: {
            stories: {
              include: { shots: true },
            },
          },
        },
        effectsJobs: true,
      },
    });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    // Strip password hash for security
    const { passwordHash, ...cleanData } = user;
    return cleanData;
  }

  /**
   * Right to Erasure / Account Deletion.
   */
  async deleteUserAccount(userId: string) {
    await this.prisma.user.delete({
      where: { id: userId },
    });
    this.logger.warn(`User account ${userId} and all related data purged successfully`);
    return { success: true, message: 'Account and associated personal data deleted.' };
  }

  /**
   * 30-Day Retention Cleaner: Sweeps temporary reference images and generations.
   */
  async sweepExpiredAssets(): Promise<{ purgedCount: number }> {
    const now = new Date();
    const expiredAssets = await this.prisma.asset.findMany({
      where: {
        retentionExpiry: {
          lte: now,
        },
      },
    });

    if (expiredAssets.length > 0) {
      await this.prisma.asset.deleteMany({
        where: {
          id: {
            in: expiredAssets.map((a) => a.id),
          },
        },
      });
      this.logger.log(`Retention cleaner: purged ${expiredAssets.length} expired asset records`);
    }

    return { purgedCount: expiredAssets.length };
  }
}

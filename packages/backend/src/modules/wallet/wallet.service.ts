import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import {
  CoinBucket,
  CoinLedgerItemDto,
  LedgerDirection,
  LedgerReason,
  WalletBalanceDto,
} from 'dramaforge-shared';
import { PrismaService } from '../../prisma.service';

export interface CoinDeductionResult {
  success: boolean;
  totalDeducted: number;
  deductedFromSubscription: number;
  deductedFromPurchased: number;
  ledgerRowIds: string[];
}

@Injectable()
export class WalletService {
  private readonly logger = new Logger(WalletService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Calculates real-time balance strictly from the immutable ledger.
   * Subscription coins must not be expired.
   */
  async getBalance(userId: string): Promise<WalletBalanceDto> {
    const now = new Date();

    const ledgerEntries = await this.prisma.coinLedger.findMany({
      where: { userId },
      orderBy: { createdAt: 'asc' },
    });

    let subscriptionCoins = 0;
    let purchasedCoins = 0;
    let expiringCoins48h = 0;
    let soonestExpiryDate: Date | null = null;

    const in48Hours = new Date(now.getTime() + 48 * 60 * 60 * 1000);

    for (const entry of ledgerEntries) {
      if (entry.bucket === CoinBucket.SUBSCRIPTION) {
        // If entry has an expiration date and it has passed, it is no longer valid
        if (entry.expiresAt && entry.expiresAt <= now) {
          continue;
        }

        if (entry.direction === LedgerDirection.CREDIT) {
          subscriptionCoins += entry.amount;

          // Check if expiring within 48h
          if (entry.expiresAt && entry.expiresAt <= in48Hours && entry.expiresAt > now) {
            expiringCoins48h += entry.amount;
            if (!soonestExpiryDate || entry.expiresAt < soonestExpiryDate) {
              soonestExpiryDate = entry.expiresAt;
            }
          }
        } else {
          subscriptionCoins = Math.max(0, subscriptionCoins - entry.amount);
        }
      } else if (entry.bucket === CoinBucket.PURCHASED) {
        if (entry.direction === LedgerDirection.CREDIT) {
          purchasedCoins += entry.amount;
        } else {
          purchasedCoins = Math.max(0, purchasedCoins - entry.amount);
        }
      }
    }

    return {
      totalCoins: subscriptionCoins + purchasedCoins,
      subscriptionCoins,
      purchasedCoins,
      expiringSoon: expiringCoins48h > 0 ? {
        amount: expiringCoins48h,
        expiresAt: soonestExpiryDate ? soonestExpiryDate.toISOString() : null,
      } : null,
    };
  }

  /**
   * Pre-deducts coins with strict FIFO priority:
   * 1. SUBSCRIPTION COINS are consumed first.
   * 2. PURCHASED COINS are consumed second.
   * Creates immutable debit rows in `coin_ledger`.
   */
  async deductCoins(
    userId: string,
    amount: number,
    reason: LedgerReason,
    referenceId?: string,
  ): Promise<CoinDeductionResult> {
    if (amount <= 0) {
      return {
        success: true,
        totalDeducted: 0,
        deductedFromSubscription: 0,
        deductedFromPurchased: 0,
        ledgerRowIds: [],
      };
    }

    const balance = await this.getBalance(userId);

    if (balance.totalCoins < amount) {
      throw new BadRequestException(
        `Insufficient coins. Required: ${amount}, Available: ${balance.totalCoins} (${balance.subscriptionCoins} subscription + ${balance.purchasedCoins} purchased)`,
      );
    }

    const deductFromSub = Math.min(balance.subscriptionCoins, amount);
    const deductFromPurchased = amount - deductFromSub;

    let currentSubBalance = balance.subscriptionCoins;
    let currentPurchasedBalance = balance.purchasedCoins;
    const ledgerRowIds: string[] = [];

    // Deduct from subscription bucket if available
    if (deductFromSub > 0) {
      currentSubBalance -= deductFromSub;
      const subRow = await this.prisma.coinLedger.create({
        data: {
          userId,
          bucket: CoinBucket.SUBSCRIPTION,
          direction: LedgerDirection.DEBIT,
          amount: deductFromSub,
          balanceAfterSubscription: currentSubBalance,
          balanceAfterPurchased: currentPurchasedBalance,
          reason,
          referenceId,
        },
      });
      ledgerRowIds.push(subRow.id);
    }

    // Deduct remaining from purchased bucket
    if (deductFromPurchased > 0) {
      currentPurchasedBalance -= deductFromPurchased;
      const purRow = await this.prisma.coinLedger.create({
        data: {
          userId,
          bucket: CoinBucket.PURCHASED,
          direction: LedgerDirection.DEBIT,
          amount: deductFromPurchased,
          balanceAfterSubscription: currentSubBalance,
          balanceAfterPurchased: currentPurchasedBalance,
          reason,
          referenceId,
        },
      });
      ledgerRowIds.push(purRow.id);
    }

    this.logger.log(
      `Deducted ${amount} coins for user ${userId} (${deductFromSub} sub, ${deductFromPurchased} purchased). Ref: ${referenceId}`,
    );

    return {
      success: true,
      totalDeducted: amount,
      deductedFromSubscription: deductFromSub,
      deductedFromPurchased: deductFromPurchased,
      ledgerRowIds,
    };
  }

  /**
   * Grants coins into specified bucket with an optional expiration timestamp.
   */
  async grantCoins(
    userId: string,
    bucket: CoinBucket,
    amount: number,
    reason: LedgerReason,
    expiresAt?: Date,
    referenceId?: string,
  ) {
    if (amount <= 0) return;

    const balance = await this.getBalance(userId);
    const newSubBalance = bucket === CoinBucket.SUBSCRIPTION ? balance.subscriptionCoins + amount : balance.subscriptionCoins;
    const newPurchasedBalance = bucket === CoinBucket.PURCHASED ? balance.purchasedCoins + amount : balance.purchasedCoins;

    const row = await this.prisma.coinLedger.create({
      data: {
        userId,
        bucket,
        direction: LedgerDirection.CREDIT,
        amount,
        balanceAfterSubscription: newSubBalance,
        balanceAfterPurchased: newPurchasedBalance,
        reason,
        expiresAt,
        referenceId,
      },
    });

    this.logger.log(`Granted ${amount} ${bucket} coins to user ${userId}. Reason: ${reason}`);
    return row;
  }

  /**
   * Compensating refund for technical or moderation failures.
   */
  async autoRefund(
    userId: string,
    generationId: string,
    amount: number,
    split?: { subscription: number; purchased: number },
  ) {
    if (amount <= 0) return;

    const balance = await this.getBalance(userId);
    let subRefund = split?.subscription ?? 0;
    let purchasedRefund = split?.purchased ?? 0;

    if (!split) {
      // Default: refund into Purchased bucket (safest and customer-friendly)
      purchasedRefund = amount;
    }

    let currentSubBalance = balance.subscriptionCoins;
    let currentPurchasedBalance = balance.purchasedCoins;

    if (subRefund > 0) {
      currentSubBalance += subRefund;
      await this.prisma.coinLedger.create({
        data: {
          userId,
          bucket: CoinBucket.SUBSCRIPTION,
          direction: LedgerDirection.CREDIT,
          amount: subRefund,
          balanceAfterSubscription: currentSubBalance,
          balanceAfterPurchased: currentPurchasedBalance,
          reason: LedgerReason.REFUND,
          referenceId: generationId,
        },
      });
    }

    if (purchasedRefund > 0) {
      currentPurchasedBalance += purchasedRefund;
      await this.prisma.coinLedger.create({
        data: {
          userId,
          bucket: CoinBucket.PURCHASED,
          direction: LedgerDirection.CREDIT,
          amount: purchasedRefund,
          balanceAfterSubscription: currentSubBalance,
          balanceAfterPurchased: currentPurchasedBalance,
          reason: LedgerReason.REFUND,
          referenceId: generationId,
        },
      });
    }

    this.logger.warn(
      `[AUTO-REFUND] Refunded ${amount} coins to user ${userId} for generation ${generationId}`,
    );
  }

  /**
   * Returns immutable ledger transaction history.
   */
  async getLedgerHistory(userId: string, limit = 50): Promise<CoinLedgerItemDto[]> {
    const items = await this.prisma.coinLedger.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });

    return items.map((item) => ({
      id: item.id,
      bucket: item.bucket as CoinBucket,
      direction: item.direction as LedgerDirection,
      amount: item.amount,
      balanceAfterSubscription: item.balanceAfterSubscription,
      balanceAfterPurchased: item.balanceAfterPurchased,
      reason: item.reason as LedgerReason,
      referenceId: item.referenceId,
      createdAt: item.createdAt.toISOString(),
    }));
  }
}

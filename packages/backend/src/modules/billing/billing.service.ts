import { Injectable, Logger } from '@nestjs/common';
import {
  CoinBucket,
  LedgerReason,
  SUBSCRIPTION_COIN_ALLOWANCES,
  SubscriptionStatus,
  SubscriptionTier,
} from 'dramaforge-shared';
import { PrismaService } from '../../prisma.service';
import { WalletService } from '../wallet/wallet.service';

export interface RevenueCatWebhookPayload {
  event: {
    type: string;
    app_user_id: string;
    product_id: string;
    expiration_at_ms?: number;
    purchased_at_ms?: number;
  };
}

@Injectable()
export class BillingService {
  private readonly logger = new Logger(BillingService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly walletService: WalletService,
  ) {}

  async handleRevenueCatEvent(payload: RevenueCatWebhookPayload) {
    const { event } = payload;
    const userId = event.app_user_id;
    this.logger.log(`Received RevenueCat event [${event.type}] for user ${userId}, product: ${event.product_id}`);

    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      this.logger.warn(`User ${userId} not found for webhook event`);
      return { received: true, ignored: true };
    }

    if (event.type === 'INITIAL_PURCHASE' || event.type === 'RENEWAL') {
      const isMonthly = event.product_id.includes('monthly');
      const tier = isMonthly ? SubscriptionTier.PRO_MONTHLY : SubscriptionTier.PRO_WEEKLY;
      const coinAllowance = isMonthly
        ? SUBSCRIPTION_COIN_ALLOWANCES.PRO_MONTHLY
        : SUBSCRIPTION_COIN_ALLOWANCES.PRO_WEEKLY;

      const periodEnd = event.expiration_at_ms
        ? new Date(event.expiration_at_ms)
        : new Date(Date.now() + (isMonthly ? 30 : 7) * 24 * 60 * 60 * 1000);

      // Create or update subscription record
      await this.prisma.subscription.upsert({
        where: { storeId: event.product_id + '_' + userId },
        create: {
          userId,
          storeId: event.product_id + '_' + userId,
          tier,
          status: SubscriptionStatus.ACTIVE,
          currentPeriodStart: new Date(),
          currentPeriodEnd: periodEnd,
          coinsAllocated: coinAllowance,
        },
        update: {
          tier,
          status: SubscriptionStatus.ACTIVE,
          currentPeriodStart: new Date(),
          currentPeriodEnd: periodEnd,
          coinsAllocated: coinAllowance,
        },
      });

      // Grant subscription coins with explicit expiry at end of billing cycle
      await this.walletService.grantCoins(
        userId,
        CoinBucket.SUBSCRIPTION,
        coinAllowance,
        LedgerReason.GRANT,
        periodEnd,
        `sub_${event.product_id}`,
      );

      return { success: true, allocated: coinAllowance };
    }

    if (event.type === 'NON_RENEWING_PURCHASE') {
      // Consumable Coin Pack (Purchased bucket, never expires)
      let coinAmount = 100;
      if (event.product_id.includes('350')) coinAmount = 350;
      if (event.product_id.includes('1000')) coinAmount = 1000;

      await this.walletService.grantCoins(
        userId,
        CoinBucket.PURCHASED,
        coinAmount,
        LedgerReason.GRANT,
        undefined, // Never expires
        `pack_${event.product_id}`,
      );

      return { success: true, allocated: coinAmount };
    }

    if (event.type === 'EXPIRATION') {
      await this.prisma.subscription.updateMany({
        where: { userId },
        data: { status: SubscriptionStatus.EXPIRED },
      });
      return { success: true, status: 'EXPIRED' };
    }

    return { received: true };
  }
}

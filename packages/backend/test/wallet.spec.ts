import { BadRequestException } from '@nestjs/common';
import { CoinBucket, LedgerDirection, LedgerReason } from 'dramaforge-shared';
import { WalletService } from '../src/modules/wallet/wallet.service';

describe('Dual-Bucket Coin Ledger & Financial Invariants', () => {
  let walletService: WalletService;
  let mockPrisma: any;
  let ledgerStore: any[] = [];

  beforeEach(() => {
    ledgerStore = [];
    mockPrisma = {
      coinLedger: {
        create: jest.fn().mockImplementation(({ data }) => {
          const entry = { id: `row_${Date.now()}_${Math.random()}`, createdAt: new Date(), ...data };
          ledgerStore.push(entry);
          return entry;
        }),
        findMany: jest.fn().mockImplementation(({ where }) => {
          return ledgerStore.filter((row) => row.userId === where.userId);
        }),
      },
    };
    walletService = new WalletService(mockPrisma);
  });

  it('In-place edits are forbidden: grants create immutable ledger rows', async () => {
    const userId = 'user_test_1';
    await walletService.grantCoins(userId, CoinBucket.PURCHASED, 100, LedgerReason.GRANT);
    await walletService.grantCoins(userId, CoinBucket.SUBSCRIPTION, 50, LedgerReason.GRANT, new Date(Date.now() + 86400000));

    expect(ledgerStore.length).toBe(2);
    expect(ledgerStore[0].bucket).toBe(CoinBucket.PURCHASED);
    expect(ledgerStore[0].amount).toBe(100);
    expect(ledgerStore[1].bucket).toBe(CoinBucket.SUBSCRIPTION);
    expect(ledgerStore[1].amount).toBe(50);

    const balance = await walletService.getBalance(userId);
    expect(balance.purchasedCoins).toBe(100);
    expect(balance.subscriptionCoins).toBe(50);
    expect(balance.totalCoins).toBe(150);
  });

  it('FIFO Bucket Order: Subscription coins are consumed first, then purchased coins', async () => {
    const userId = 'user_fifo_test';
    // Grant 30 subscription coins and 50 purchased coins
    await walletService.grantCoins(userId, CoinBucket.SUBSCRIPTION, 30, LedgerReason.GRANT, new Date(Date.now() + 86400000));
    await walletService.grantCoins(userId, CoinBucket.PURCHASED, 50, LedgerReason.GRANT);

    // Deduct 40 coins (should take 30 from subscription, 10 from purchased)
    const result = await walletService.deductCoins(userId, 40, LedgerReason.USAGE, 'shot_gen_1');

    expect(result.success).toBe(true);
    expect(result.deductedFromSubscription).toBe(30);
    expect(result.deductedFromPurchased).toBe(10);
    expect(result.totalDeducted).toBe(40);

    const balanceAfter = await walletService.getBalance(userId);
    expect(balanceAfter.subscriptionCoins).toBe(0);
    expect(balanceAfter.purchasedCoins).toBe(40);
    expect(balanceAfter.totalCoins).toBe(40);
  });

  it('Strict balance invariant: Rejects deduction when total coins are insufficient', async () => {
    const userId = 'user_insufficient';
    await walletService.grantCoins(userId, CoinBucket.PURCHASED, 10, LedgerReason.GRANT);

    await expect(
      walletService.deductCoins(userId, 25, LedgerReason.USAGE, 'shot_gen_fail'),
    ).rejects.toThrow(BadRequestException);
  });

  it('Pre-deduction with auto-refund: Restores exact coin split on technical failure', async () => {
    const userId = 'user_refund_test';
    await walletService.grantCoins(userId, CoinBucket.SUBSCRIPTION, 20, LedgerReason.GRANT, new Date(Date.now() + 86400000));
    await walletService.grantCoins(userId, CoinBucket.PURCHASED, 20, LedgerReason.GRANT);

    // Deduct 25 coins: 20 sub, 5 purchased
    const deduction = await walletService.deductCoins(userId, 25, LedgerReason.USAGE, 'job_fail_1');
    const midBalance = await walletService.getBalance(userId);
    expect(midBalance.totalCoins).toBe(15);

    // Auto-refund with split
    await walletService.autoRefund(userId, 'job_fail_1', 25, {
      subscription: deduction.deductedFromSubscription,
      purchased: deduction.deductedFromPurchased,
    });

    const finalBalance = await walletService.getBalance(userId);
    expect(finalBalance.subscriptionCoins).toBe(20);
    expect(finalBalance.purchasedCoins).toBe(20);
    expect(finalBalance.totalCoins).toBe(40);
  });

  it('Expiry Invariant: Expired subscription coins are excluded from balance', async () => {
    const userId = 'user_expiry_test';
    const pastDate = new Date(Date.now() - 3600000); // 1 hour ago
    await walletService.grantCoins(userId, CoinBucket.SUBSCRIPTION, 50, LedgerReason.GRANT, pastDate);
    await walletService.grantCoins(userId, CoinBucket.PURCHASED, 30, LedgerReason.GRANT);

    const balance = await walletService.getBalance(userId);
    expect(balance.subscriptionCoins).toBe(0); // Expired, so 0
    expect(balance.purchasedCoins).toBe(30);
    expect(balance.totalCoins).toBe(30);
  });
});


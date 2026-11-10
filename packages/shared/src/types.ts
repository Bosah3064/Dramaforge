import {
  CoinBucket,
  EnforcementState,
  LedgerDirection,
  LedgerReason,
  SubscriptionStatus,
  SubscriptionTier,
  UserRole,
} from './enums';

export interface UserProfileDto {
  id: string;
  email: string;
  role: UserRole;
  enforcementState: EnforcementState;
  isAgeVerified: boolean;
  createdAt: string;
  subscription?: {
    tier: SubscriptionTier;
    status: SubscriptionStatus;
    currentPeriodEnd: string;
  } | null;
}

export interface WalletBalanceDto {
  totalCoins: number;
  subscriptionCoins: number;
  purchasedCoins: number;
  expiringSoon: {
    amount: number;
    expiresAt: string | null;
  } | null;
}

export interface CoinLedgerItemDto {
  id: string;
  bucket: CoinBucket;
  direction: LedgerDirection;
  amount: number;
  balanceAfterSubscription: number;
  balanceAfterPurchased: number;
  reason: LedgerReason;
  referenceId?: string | null;
  createdAt: string;
}

export interface ConsentRecordDto {
  userId: string;
  version: string;
  scope: string;
  providersDisclosed: string[];
  acceptedAt: string;
}

export interface StoryboardShotDto {
  id: string;
  sequenceIndex: number;
  sceneDescription: string;
  cameraDirection: string;
  dialogue?: string | null;
  durationSeconds: number;
  keyframePrompt: string;
  keyframeImageUrl?: string | null;
  videoClipUrl?: string | null;
  status: string;
}

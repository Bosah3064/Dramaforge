export enum UserRole {
  USER = 'USER',
  ADMIN = 'ADMIN',
}

export enum EnforcementState {
  NONE = 'NONE',
  WARNING = 'WARNING',
  FEATURE_LIMIT = 'FEATURE_LIMIT',
  TEMP_SUSPEND = 'TEMP_SUSPEND',
  BANNED = 'BANNED',
}

export enum CoinBucket {
  SUBSCRIPTION = 'SUBSCRIPTION',
  PURCHASED = 'PURCHASED',
}

export enum LedgerDirection {
  CREDIT = 'CREDIT',
  DEBIT = 'DEBIT',
}

export enum LedgerReason {
  GRANT = 'GRANT',
  USAGE = 'USAGE',
  REFUND = 'REFUND',
  EXPIRY = 'EXPIRY',
  ADMIN_ADJUSTMENT = 'ADMIN_ADJUSTMENT',
}

export enum SubscriptionTier {
  FREE = 'FREE',
  PRO_WEEKLY = 'PRO_WEEKLY',
  PRO_MONTHLY = 'PRO_MONTHLY',
}

export enum SubscriptionStatus {
  ACTIVE = 'ACTIVE',
  CANCELLED = 'CANCELLED',
  EXPIRED = 'EXPIRED',
  GRACE_PERIOD = 'GRACE_PERIOD',
}

export enum ProjectMode {
  QUICK = 'QUICK',
  STUDIO = 'STUDIO',
}

export enum AspectRatio {
  PORTRAIT_9_16 = 'PORTRAIT_9_16',
  LANDSCAPE_16_9 = 'LANDSCAPE_16_9',
  SQUARE_1_1 = 'SQUARE_1_1',
}

export enum ProjectStatus {
  DRAFT = 'DRAFT',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
}

export enum PipelineStage {
  STORY = 'STORY',
  STORYBOARD = 'STORYBOARD',
  SHOT_VIDEOS = 'SHOT_VIDEOS',
  FINAL_CUT = 'FINAL_CUT',
  COMPLETED = 'COMPLETED',
}

export enum ShotStatus {
  PENDING = 'PENDING',
  IMAGE_GENERATING = 'IMAGE_GENERATING',
  IMAGE_DONE = 'IMAGE_DONE',
  VIDEO_GENERATING = 'VIDEO_GENERATING',
  VIDEO_DONE = 'VIDEO_DONE',
  FAILED = 'FAILED',
}

export enum GenerationType {
  STORY_SCRIPT = 'STORY_SCRIPT',
  KEYFRAME_IMAGE = 'KEYFRAME_IMAGE',
  SHOT_VIDEO = 'SHOT_VIDEO',
  FINAL_ASSEMBLY = 'FINAL_ASSEMBLY',
  PHOTO_EFFECT = 'PHOTO_EFFECT',
}

export enum GenerationStatus {
  QUEUED = 'QUEUED',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
}

export enum EffectType {
  HUG = 'HUG',
  KISS = 'KISS',
  DANCE = 'DANCE',
  LOOK_AT_CAMERA = 'LOOK_AT_CAMERA',
  AGING = 'AGING',
  BABY_VERSION = 'BABY_VERSION',
  OUTFIT_CHANGE = 'OUTFIT_CHANGE',
}

export enum ModerationAction {
  ALLOW = 'ALLOW',
  WARN = 'WARN',
  BLOCK = 'BLOCK',
}

export enum AIProviderType {
  MOCK = 'MOCK',
  OPENAI = 'OPENAI',
  ANTHROPIC = 'ANTHROPIC',
  GOOGLE_VEO = 'GOOGLE_VEO',
  BYTEPLUS = 'BYTEPLUS',
}

/**
 * DramaForge Coin Pricing Schedule (Strict financial invariants)
 */
export const COIN_PRICING = {
  // Script Generation is free to encourage user onboarding & exploration
  SCRIPT_GENERATION: 0,

  // Storyboard Keyframe generation (Text-to-Image with character reference)
  KEYFRAME_PER_SHOT: 2,

  // Shot Video generation (Image-to-Video 5-8s clip)
  VIDEO_PER_SHOT: 8,

  // Viral Photo Animation Effect (Single or dual photo 5-10s clip)
  PHOTO_EFFECT: 8,

  // Final assembly & 1080p high definition render
  FINAL_RENDER_1080P: 15,

  // 720p watermarked render is free for all users
  FINAL_RENDER_720P_WATERMARKED: 0,
} as const;

export const SUBSCRIPTION_COIN_ALLOWANCES = {
  PRO_WEEKLY: 150,   // Grants 150 subscription coins / week
  PRO_MONTHLY: 700,  // Grants 700 subscription coins / month
} as const;

export const COIN_PACKAGES = [
  { id: 'coins_100', name: 'Starter Pack', coins: 100, priceUsd: 2.99 },
  { id: 'coins_350', name: 'Creator Pack', coins: 350, priceUsd: 8.99 },
  { id: 'coins_1000', name: 'Studio Pack', coins: 1000, priceUsd: 22.99 },
] as const;

# DramaForge — Competitive Intelligence & Clean-Room Analysis

> **Notice:** This document contains competitive intelligence derived strictly from public documents, live web scans of app store mirrors, public terms of use, privacy policies, and public community reviews on Reddit and app store forums. No proprietary code, binaries, or decompiled assets were used. DramaForge is an original, clean-room product with independent branding, UI, and implementation.

---

## 1. Executive Summary & Market Landscape

| Competitor Feature | Observed State (Drma / Competitors) | DramaForge Differentiation Strategy |
| :--- | :--- | :--- |
| **Product Hook** | Viral photo effects ("AI Hug / Kiss / Dance") + keyword-stuffed package name (`luma.sora.pika.runway.video.ai`) | Dual-engine: Viral Photo Effects as UA funnel + Full 4-Stage Drama Studio for creators |
| **Pipeline Workflow** | Step-by-Step & Quick Generation (Script -> Storyboard -> Video -> Cut) | Full multi-shot consistency engine + interactive script/storyboard editing |
| **Point Expiry** | Subscription points expire strictly every billing period (aggressive hook) | Dual-Bucket Economy: Subscription coins expire with 48h notice; Purchased coins **never expire** |
| **Character Consistency** | High drift across shots, face distortions and unnatural morphing | Character Reference Anchors passed to keyframe text-to-image generator across all shots |
| **Safety & Consent** | Minimal verification, widely criticized for non-consensual deepfake risks | First-class Pre-Transfer Consent, 13+ Age Gate, Face Consent Checkbox, Graduated Enforcement |
| **Pricing & Transparency** | Hidden paywalls, deceptive free trials, \$7-\$40/week charges | Transparent coin ledger, free script expansion, clear cost confirmation, auto-refunds on failure |
| **Cross-Platform** | Mobile only (iOS/Android) | Flutter mobile client + Web Admin Panel + Desktop-compatible architecture |

---

## 2. Live Web Scan Findings (Reddit, App Store Reviews, Legal Filings)

### 2.1 Top User Complaints Uncovered from Live Forums
1. **The "Bait-and-Switch" Credit Trap**: Many apps give users 5 free credits on onboarding, but a single render costs 10 credits, immediately hitting users with a \$9.99/week paywall.
2. **Non-Consensual Deepfakes & NCII**: Viral kiss/hug apps have triggered major community backlash (e.g., r/extremelyinfuriating) because bad actors upload unconsenting peers, coworkers, or public figures. DramaForge directly counters this with cryptographic/audit-logged face consent verification and multi-stage moderation.
3. **Unforgiving Credit Deductions on Glitched Outputs**: When the AI video model produces distorted limbs or unnatural morphs, the user's credits are consumed with zero recourse. DramaForge implements pre-deduction with auto-refund on technical/model failure and granular single-shot regeneration.
4. **Subscription Traps & Hidden Auto-Renewals**: Dark patterns in competitor apps make cancellation cumbersome. DramaForge provides native store-standard billing transparency via RevenueCat and in-app subscription management.

---

## 3. Feature & Flow Matrix

### 3.1 Core User Flows
1. **Flow A: Quick Generation (One-Tap)**
   - Inputs: Story premise / prompt, genre/style template (Cinematic, Anime, Revenge Drama, Noir, Cyberpunk), aspect ratio (9:16 vertical default, 16:9, 1:1), target duration (15s, 30s, 60s).
   - Execution: Server pipeline asynchronously handles script expansion -> storyboard shot list -> keyframe image generation -> video generation -> assembly + audio.
   - Outputs: Playable, exportable short-drama video with push/in-app notification on completion.

2. **Flow B: Step-by-Step Studio**
   - **Stage 1 (Story)**: Expand prompt into rich 3-act outline with character profiles and dialogue.
   - **Stage 2 (Storyboard)**: Per-shot breakdown (camera direction, scene prompt, dialogue, duration). Keyframe thumbnails generated per shot.
   - **Stage 3 (Shot Videos)**: Image-to-video generation (5-8s per clip) with individual shot regeneration and progress tracking.
   - **Stage 4 (Final Cut)**: Video concatenation, transition smoothing, automated subtitle burning (SRT/VTT), background music track mixing. Export in 720p (free with watermark) or 1080p (unwatermarked for subscribers).

3. **Flow C: Viral Photo Effects**
   - Templates: Hug, Kiss, Dance, Look-at-Camera, Aging, Baby Version, Outfit Swap.
   - Strict face-detection consent guard: explicit confirmation checkbox required.

---

## 4. Monetization Mechanics (Dual-Bucket Coin Economy)

- **Subscription Coins**: Granted on weekly/monthly subscription renewal; expire at the end of the billing period; no rollover; 48-hour push notification before expiry.
- **Purchased Coins**: One-time consumable packs; never expire; strictly consumed after subscription coins are depleted.
- **Cost Schedule**:
  - Script generation: Free / 0 coins
  - Storyboard Keyframe generation: 2 coins per shot
  - Shot Video generation (image-to-video): 8 coins per shot
  - Photo Effect generation: 8 coins
  - Final 1080p Cut Render: 15 coins
  - Watermark Removal: Included with active subscription
- **Ledger Invariants**:
  - Double-entry-style immutable ledger (`coin_ledger`).
  - Pre-authorization / pre-deduction prior to queueing generation.
  - Automatic compensating refund if generation fails or is rejected by moderation/technical errors.

---

## 5. Privacy, Safety & Compliance Mandates

- **Consent Record**: Before sending user media/prompts to third-party AI models (OpenAI, Google Veo, Anthropic, etc.), user must explicitly accept a clear pre-transfer consent disclosure specifying data types and recipients.
- **Data Minimization**: User account identifiers are NEVER included in model payloads.
- **Retention**: Ephemeral reference uploads automatically scheduled for deletion after 30 days.
- **Enforcement Pipeline**:
  - Tier 1: Warning + Content Block
  - Tier 2: Feature Cooldown / Rate Limit
  - Tier 3: Temporary Suspension (24h - 7d)
  - Tier 4: Permanent Ban + Device / Account Blacklist



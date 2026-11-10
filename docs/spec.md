# DramaForge — Product Specification & Technical Requirements

## 1. Product Definition
DramaForge is an AI-powered short-drama video studio and photo animation platform. It enables users to transform a single-line story prompt or uploaded images into fully realized, cinematic 15–90 second videos (in 9:16 vertical, 16:9 widescreen, or 1:1 square aspect ratios).

## 2. Core User Flows
1. **Flow A (Quick Generation)**:
   - Input: Text idea / genre template + character photos (optional) + duration & aspect ratio.
   - Output: Automatic end-to-end pipeline execution delivering a completed short drama video.
2. **Flow B (Step-by-Step Studio)**:
   - Stage 1: Story outline & script expansion (LLM).
   - Stage 2: Storyboard shot breakdown with keyframe thumbnails (LLM + T2I).
   - Stage 3: Shot video generation (I2V / T2V, 5–8s clips) with individual shot regeneration.
   - Stage 4: Final cut assembly, subtitle sync, music mixing, and watermark-conditional rendering.
3. **Flow C (Viral Photo Effects)**:
   - Input: 1–2 photos + effect selection (Hug, Kiss, Dance, Look-at-camera, Aging, Baby-version, Outfit change).
   - Compliance: Explicit real-person consent confirmation gate.
   - Output: 5–10s animated high-fidelity clip.

## 3. Technology Stack & Justification
- **Backend**: Node.js with NestJS / TypeScript + Prisma ORM + PostgreSQL + Redis (BullMQ) + S3-compatible storage.
  - *Justification*: Node.js v24 is actively available; TypeScript guarantees type safety across DTOs, schemas, and API contracts; NestJS provides enterprise dependency injection, clean modular separation, and native BullMQ queue management for async video workloads.
- **Mobile Client**: Flutter (Dart) with MVVM architecture, Riverpod state management, and GoRouter.
- **Admin Web Panel**: Lightweight modern SPA (React / Tailwind / Vite) communicating with backend admin endpoints.
- **AI Provider Abstraction**: Pluggable `AIProvider` interface supporting OpenAI / Anthropic for scripts, Seedream / Stable Diffusion / Midjourney-class for keyframes, and Google Veo / Seedance for video clips, backed by comprehensive Mock Adapters for dev and automated testing.
- **Monetization**: Dual-bucket coin ledger (Subscription coins with monthly expiry vs. Purchased coins with permanent validity).
- **Safety & Moderation**: Pre-generation text keyword/regex classifiers, image moderation, explicit consent records, age gate 13+, and graduated enforcement states (`NONE` -> `WARNING` -> `FEATURE_LIMIT` -> `TEMP_SUSPEND` -> `BANNED`).


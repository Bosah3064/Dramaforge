# DramaForge — Agent Standing Guardrails & Architecture Rules

## 1. AI Provider Abstraction
- All AI provider interactions (LLM script generation, keyframe text-to-image, shot image-to-video, photo effects) **MUST** go through the `AIProvider` / `VideoAIAdapter` interface.
- **NEVER** call a provider SDK (OpenAI, Anthropic, Google Veo, BytePlus, etc.) directly from business logic or controllers.
- Provide full Mock AI Adapters for local development and test suites so all tests and dev loops run deterministically with zero API keys and zero cost.

## 2. Dual-Bucket Coin Ledger & Financial Invariants
- Currency: **Coins**. Tracked strictly in two separate buckets:
  1. `SUBSCRIPTION_COINS`: expire at billing period end, no rollover, notification 48h prior.
  2. `PURCHASED_COINS`: non-expiring, consumed ONLY after subscription coins are depleted.
- **NEVER perform in-place balance edits.** Every coin movement (grant, deduction, refund, expiry) MUST be an immutable row in `coin_ledger`.
- Balance is computed as the sum of ledger entries or cached with strict ledger write locks.
- **Pre-deduction with auto-refund**: Coins are reserved/deducted BEFORE enqueueing a generation job. On technical failure or model rejection, the exact deducted coins are automatically refunded via a compensating ledger entry with the associated `generation_id`.

## 3. Safety, Moderation & Privacy Compliance (Non-Negotiable)
- **Age Gate**: Explicit 13+ verification at onboarding/signup.
- **Consent Architecture**: Pre-transfer consent record (`user_id`, `version`, `timestamp`, `scope`, `providers`) must be acknowledged and logged before any asset or prompt is dispatched to an AI model.
- **Photo Effects Real-Person Flag**: Effects targeting uploaded human faces require explicit confirmation: `"I have consent from every identifiable person in this media."`
- **Multi-Stage Moderation**: Automated text keyword/regex & image safety checks before generation, plus provider safety response handling.
- **Graduated Enforcement Machine**: `NONE` -> `WARNING` -> `FEATURE_LIMIT` -> `TEMP_SUSPEND` -> `BANNED`.
- **Privacy Retention**: Reference uploads tagged for auto-deletion after 30 days. Creative payloads NEVER include user account IDs. No user data used for model training.

## 4. Development Operations & Review
- Ask the user before adding new external heavy dependencies, adding paid external APIs, or executing irreversible database migrations.
- Always maintain clean monorepo boundaries between backend, mobile app, admin panel, and shared contracts.
- Checkpoint git after every milestone acceptance.


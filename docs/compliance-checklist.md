# DramaForge — Store Compliance, Data-Safety & AI Governance Checklist

## 1. Google Play & App Store Compliance Mandates

### 1.1 Age Gate & Child Safety (13+ Requirement)
- [x] **Hard Age Gate**: Explicit date-of-birth verification screen blocking users under 13 at account registration.
- [x] **No CSAM Tolerance**: Automated regex and hash-based blocking on any prompt or media mentioning or implying underage sexuality. Immediate escalation to `BANNED` and IP/device hashing.

### 1.2 Non-Consensual Intimate Imagery (NCII) & Deepfake Safeguards
- [x] **Photo Animation Face Checkbox**: Mandatory confirmation on every photo upload involving real people:
  > *"I certify that I have explicit consent from every identifiable person in this media."*
- [x] **Prohibited Celebrity / Deepfake Prompts**: Regex classifier intercepts keywords (`deepfake nude`, `unconsenting kiss`, `revenge porn`) before reaching generation queues.
- [x] **Graduated Enforcement Machine**:
  - Strike 1: `WARNING` + generation blocked.
  - Strike 2: `FEATURE_LIMIT` (generation locked for 24h).
  - Strike 3: `TEMP_SUSPEND` (account locked 7 days).
  - Strike 4: `BANNED` (permanent revocation).

### 1.3 Pre-Transfer Third-Party AI Disclosure (GDPR Article 13 & 14)
- [x] Explicit modal shown prior to first AI call naming third-party AI processors: **OpenAI, Google Veo, Anthropic, BytePlus**.
- [x] Active server-side consent logging in `consent_records` (`user_id`, `version`, `timestamp`, `ip_address`, `scope`).
- [x] User account identifiers scrubbed from model payloads (zero account IDs leaked to LLMs or video generators).
- [x] No user content utilized for training public models.

### 1.4 Retention & Data Erasure (GDPR Articles 17 & 20)
- [x] **30-Day Automated Sweep**: Ephemeral face uploads and working keyframes tagged with `retention_expiry = now + 30 days` and purged automatically.
- [x] **GDPR Data Portability Endpoint**: `GET /api/v1/compliance/export-data` delivers machine-readable JSON archive of all user projects and transaction logs.
- [x] **Right to Erasure Endpoint**: `DELETE /api/v1/compliance/delete-account` completely removes user records, ledger entries, and S3 assets.

---

## 2. Monetization & Dual-Bucket Ledger Compliance

- [x] **Store-Approved In-App Purchases**: Seamless RevenueCat integration handling Apple StoreKit and Google Play Billing.
- [x] **Subscription Points Expiry Disclosure**: Clear UI disclosure showing Subscription Coins expire at billing cycle end with push notifications sent 48 hours prior.
- [x] **Consumer-Friendly Non-Expiring Coins**: Purchased point packs never expire and are consumed strictly after subscription points.
- [x] **Automated Refund Guarantee**: Any network error, GPU timeout, or AI safety rejection automatically generates a compensating credit entry in the immutable `coin_ledger`.
- [x] **Restore Purchases**: Present and operational on the wallet paywall screen.

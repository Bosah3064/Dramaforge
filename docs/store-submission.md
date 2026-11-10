# DramaForge — App Store & Google Play Submission Dossier

## 1. App Store Metadata

- **App Name**: DramaForge: AI Short Drama Studio
- **Subtitle**: Turn Ideas & Photos into Cinematic Videos
- **Primary Category**: Photo & Video / Entertainment
- **Content Rating**: 13+ (Teen / Mature Themes in Drama)
- **Primary Keywords**: AI video studio, short drama maker, photo animation, AI Hug Kiss, character consistency, script to video

---

## 2. Google Play Data Safety Form Declarations

| Data Category | Data Collected | Purpose | Shared with 3rd Parties? |
| :--- | :--- | :--- | :--- |
| **Personal Info** | Email address, User ID | Account management, authentication | No |
| **Photos & Videos** | User-uploaded reference photos, generated shot clips | App functionality (generating short dramas & photo animation) | Yes (AI processors: OpenAI, Google Veo, BytePlus via encrypted API with zero-training SLA) |
| **Financial Info** | Purchase history (Coins & Subscriptions) | In-app billing via Google Play Billing / RevenueCat | No |
| **App Info & Performance**| Crash logs, diagnostics | Analytics & performance optimization | Yes (Firebase Crashlytics) |

---

## 3. Required App Permissions

- `android.permission.INTERNET`: Required for API requests, AI model dispatch, and video streaming.
- `android.permission.READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE`: Required for selecting reference photos for character consistency and photo animation effects.
- `android.permission.WRITE_EXTERNAL_STORAGE` (API < 33): Required for exporting assembled short drama videos to the device gallery.
- `com.android.vending.BILLING`: Required for consumable coin packs and auto-renewing subscriptions.

---

## 4. In-App Purchase Identifiers (RevenueCat & StoreKit)

1. `dramaforge_pro_weekly`: \$6.99 / week (Auto-renewing, 150 subscription coins / week)
2. `dramaforge_pro_monthly`: \$19.99 / month (Auto-renewing, 700 subscription coins / month, Best Value)
3. `dramaforge_coins_100`: \$2.99 (Consumable point pack, non-expiring)
4. `dramaforge_coins_350`: \$8.99 (Consumable point pack, non-expiring)
5. `dramaforge_coins_1000`: \$22.99 (Consumable point pack, non-expiring)


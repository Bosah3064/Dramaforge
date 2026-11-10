# DramaForge — Complete Firebase Cloud Firestore Setup Guide

This guide walks you step-by-step through setting up **DramaForge** on **Firebase Cloud Firestore**, configuring the collections, security rules, indexes, authentication, and connecting both the **Flutter Mobile App** and the **Backend API / Cloud Functions**.

---

## 1. Firebase Project Initialization

### Step 1: Create a Project in the Firebase Console
1. Go to [https://console.firebase.google.com/](https://console.firebase.google.com/) and click **Add Project**.
2. Name your project: `dramaforge-studio` (or your chosen project name).
3. (Recommended) Enable **Google Analytics** (required for Firebase Analytics and Crashlytics).
4. Click **Create Project**.

### Step 2: Enable Firebase Authentication
1. In the Firebase Console left menu, navigate to **Build** > **Authentication**.
2. Click **Get Started**.
3. Under the **Sign-in method** tab:
   - Enable **Email/Password**.
   - (Optional) Enable **Google** and **Apple** sign-in for seamless mobile login.

### Step 3: Enable Cloud Firestore
1. Navigate to **Build** > **Firestore Database**.
2. Click **Create Database**.
3. Select database location (e.g., `nam5 (us-central)` or closest to your users).
4. Start in **Production Mode** (we will apply strict custom security rules below).

### Step 4: Enable Cloud Storage for Assets
1. Navigate to **Build** > **Storage**.
2. Click **Get Started** and accept default security rules.
3. This bucket hosts reference portrait uploads, generated keyframe thumbnails, and assembled short drama MP4 videos.

---

## 2. Firestore Document & Collection Architecture

In Cloud Firestore, we translate our 11 relational entities into a hybrid top-level and subcollection structure optimized for real-time mobile listeners:

```
firestore/
├── users/ {userId}
│   ├── (fields: email, role, enforcementState, isAgeVerified, createdAt)
│   ├── subcollection: consent_records/ {consentId}
│   │   └── (version, scope, providersDisclosed, ipAddress, acceptedAt)
│   ├── subcollection: coin_ledger/ {ledgerEntryId}   [SERVER-WRITE ONLY]
│   │   └── (bucket, direction, amount, reason, referenceId, expiresAt, createdAt)
│   └── subcollection: subscriptions/ {subId}
│       └── (storeId, tier, status, currentPeriodStart, currentPeriodEnd)
│
├── projects/ {projectId}
│   ├── (userId, title, mode, aspectRatio, stylePreset, status, finalVideoUrl, updatedAt)
│   └── subcollection: stories/ {storyId}
│       ├── (synopsis, genre, characters, scriptText, version)
│       └── subcollection: shots/ {shotId}
│           └── (sequenceIndex, sceneDescription, cameraDirection, dialogue, keyframeImageUrl, videoClipUrl, status)
│
├── generations/ {generationId}
│   └── (userId, jobId, type, provider, coinCost, status, errorMessage, refundStatus, createdAt)
│
├── effects_jobs/ {jobId}
│   └── (userId, effectType, sourceImageS3Key, hasConsentConfirmation, status, outputVideoS3Key, createdAt)
│
└── moderation_events/ {eventId}  [ADMIN & SERVER ONLY]
    └── (userId, contentType, triggerKeyword, riskScore, actionTaken, details, createdAt)
```

---

## 3. Production Security Rules (`firestore.rules`)

> [!IMPORTANT]
> **Strict Financial Invariant**: Clients MUST NEVER write directly to `coin_ledger`. Only trusted server processes (`firebase-admin` SDK or Cloud Functions) can credit or debit coins.

Create or update `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isAuthenticated() && request.auth.token.role == 'ADMIN';
    }

    // 1. Users Collection
    match /users/{userId} {
      allow read: if isOwner(userId) || isAdmin();
      // Allow user creation if age-verified (13+)
      allow create: if isOwner(userId) && request.resource.data.isAgeVerified == true;
      allow update: if isOwner(userId) && 
        // Users cannot alter their own enforcement state or admin role
        !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'enforcementState']);
      allow delete: if isOwner(userId) || isAdmin();

      // Subcollection: Consent Records
      match /consent_records/{consentId} {
        allow read: if isOwner(userId) || isAdmin();
        allow create: if isOwner(userId);
        allow update, delete: if false; // Immutable audit log
      }

      // Subcollection: Coin Ledger (STRICT SERVER-ONLY WRITES)
      match /coin_ledger/{ledgerId} {
        allow read: if isOwner(userId) || isAdmin();
        allow write: if false; // Only Cloud Functions / Backend Admin SDK can write
      }

      // Subcollection: Subscriptions
      match /subscriptions/{subId} {
        allow read: if isOwner(userId) || isAdmin();
        allow write: if false; // Only RevenueCat webhooks / backend can write
      }
    }

    // 2. Projects & Storyboard Subcollections
    match /projects/{projectId} {
      allow read: if isAuthenticated() && (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && (resource.data.userId == request.auth.uid || isAdmin());

      match /stories/{storyId} {
        allow read, write: if isAuthenticated();
        
        match /shots/{shotId} {
          allow read, write: if isAuthenticated();
        }
      }
    }

    // 3. Generations Collection
    match /generations/{generationId} {
      allow read: if isAuthenticated() && (resource.data.userId == request.auth.uid || isAdmin());
      allow write: if false; // Managed by backend queue workers
    }

    // 4. Viral Photo Effects Jobs
    match /effects_jobs/{jobId} {
      allow read: if isAuthenticated() && (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isAuthenticated() && 
        request.resource.data.userId == request.auth.uid &&
        request.resource.data.hasConsentConfirmation == true; // Face consent mandatory
      allow update: if false;
    }

    // 5. Moderation Events (Admin Only)
    match /moderation_events/{eventId} {
      allow read, write: if isAdmin();
    }
  }
}
```

---

## 4. Firestore Composite Indexes (`firestore.indexes.json`)

To enable fast real-time queries for history, shot sequences, and 48-hour expiration sweeps:

```json
{
  "indexes": [
    {
      "collectionGroup": "coin_ledger",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "bucket", "order": "ASCENDING" },
        { "fieldPath": "expiresAt", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "shots",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "sequenceIndex", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "projects",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "updatedAt", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## 5. Connecting the Flutter App (`packages/mobile`)

### Step 1: Install FlutterFire CLI
Run in terminal:
```bash
dart pub global activate flutterfire_cli
npm install -g firebase-tools
firebase login
```

### Step 2: Configure Firebase for Flutter
In `packages/mobile`:
```bash
flutterfire configure --project=dramaforge-studio
```
This generates `lib/firebase_options.dart` configured for iOS, Android, and Web automatically.

### Step 3: Add Flutter Dependencies
In `packages/mobile/pubspec.yaml`, add:
```yaml
dependencies:
  firebase_core: ^2.30.1
  firebase_auth: ^4.19.4
  cloud_firestore: ^4.17.2
  firebase_storage: ^11.7.4
```

### Step 4: Initialize in `main.dart`
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DramaForgeApp());
}
```

---

## 6. Connecting the Backend API / Cloud Functions (`packages/backend`)

The backend uses `firebase-admin` to execute privileged ledger transactions and queue processing.

### Step 1: Download Service Account Key
1. Go to **Firebase Console** > **Project Settings** (gear icon) > **Service accounts**.
2. Click **Generate new private key**.
3. Save the JSON file as `serviceAccountKey.json` (do not commit to git!).

### Step 2: Configure in NestJS Backend
In `.env`:
```env
FIREBASE_PROJECT_ID=dramaforge-studio
FIREBASE_SERVICE_ACCOUNT_KEY_PATH=./serviceAccountKey.json
```

In `src/main.ts` or a `FirebaseAdminService`:
```typescript
import * as admin from 'firebase-admin';

admin.initializeApp({
  credential: admin.credential.cert(require(process.env.FIREBASE_SERVICE_ACCOUNT_KEY_PATH)),
  storageBucket: `${process.env.FIREBASE_PROJECT_ID}.appspot.com`,
});

export const db = admin.firestore();
export const bucket = admin.storage().bucket();
```

---

## 7. Deploying Rules and Indexes via CLI

Deploy rules directly from the project root:
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Google account
firebase login

# Set the active project
firebase use dramaforge-studio

# Deploy Firestore rules and indexes
firebase deploy --only firestore:rules,firestore:indexes
```

import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// Initialize Firebase Admin with project ID
if (!getApps().length) {
  initializeApp({
    projectId: 'dramaforge-f0357',
  });
}

const db = getFirestore();

async function seedDramaForgeFirestore() {
  console.log('🌱 Seeding DramaForge Collections & Tables in Cloud Firestore (dramaforge-f0357)...');

  const now = new Date().toISOString();
  const thirtyDaysLater = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString();

  // 1. Users Collection
  const demoUserId = 'creator_demo_001';
  const userRef = db.collection('users').doc(demoUserId);
  await userRef.set({
    email: 'creator@dramaforge.ai',
    role: 'USER',
    enforcementState: 'NONE',
    isAgeVerified: true,
    createdAt: now,
    updatedAt: now,
  });
  console.log('✅ Created user document: users/creator_demo_001');

  // 2. Pre-Transfer Consent Subcollection
  await userRef.collection('consent_records').doc('consent_initial').set({
    version: '2026.1',
    scope: 'story_script,keyframes,video_synthesis',
    providersDisclosed: [
      'OpenAI (Script & Storyboard)',
      'Google Veo (Video Synthesis)',
      'BytePlus (Image & Motion)',
      'Anthropic (Creative Expansion)',
    ],
    ipAddress: '127.0.0.1',
    acceptedAt: now,
  });
  console.log('✅ Created consent record subcollection');

  // 3. Dual-Bucket Coin Ledger Subcollection (Immutable Rows)
  await userRef.collection('coin_ledger').doc('ledger_grant_welcome').set({
    bucket: 'PURCHASED',
    direction: 'CREDIT',
    amount: 100,
    balanceAfterSubscription: 0,
    balanceAfterPurchased: 100,
    reason: 'GRANT',
    referenceId: 'welcome_starter_pack',
    expiresAt: null, // Never expires
    createdAt: now,
  });

  await userRef.collection('coin_ledger').doc('ledger_grant_pro_monthly').set({
    bucket: 'SUBSCRIPTION',
    direction: 'CREDIT',
    amount: 700,
    balanceAfterSubscription: 700,
    balanceAfterPurchased: 100,
    reason: 'GRANT',
    referenceId: 'sub_pro_monthly_cycle_1',
    expiresAt: thirtyDaysLater, // Expiring in 30 days
    createdAt: now,
  });
  console.log('✅ Created dual-bucket coin_ledger rows');

  // 4. Subscriptions Subcollection
  await userRef.collection('subscriptions').doc('sub_active').set({
    storeId: 'revenuecat_sub_monthly_001',
    tier: 'PRO_MONTHLY',
    status: 'ACTIVE',
    coinsAllocated: 700,
    currentPeriodStart: now,
    currentPeriodEnd: thirtyDaysLater,
    createdAt: now,
  });
  console.log('✅ Created active subscription document');

  // 5. Drama Projects Collection & Subcollections
  const projectId = 'proj_penthouse_confrontation';
  const projectRef = db.collection('projects').doc(projectId);
  await projectRef.set({
    userId: demoUserId,
    title: 'The Penthouse Confrontation',
    mode: 'STUDIO',
    aspectRatio: '9:16',
    stylePreset: 'cinematic',
    targetDurationSeconds: 30,
    status: 'COMPLETED',
    finalVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    createdAt: now,
    updatedAt: now,
  });

  const storyRef = projectRef.collection('stories').doc('story_001');
  await storyRef.set({
    synopsis: 'When investigative reporter Elena Vance uncovers a covert takeover orchestrated by CEO Marcus Sterling, a tense confrontation in a rainy penthouse penthouse leads to a shocking alliance neither anticipated.',
    genre: 'Revenge Drama',
    characters: [
      { name: 'Elena Vance', appearance: 'Investigative reporter in trench coat, dark brown hair' },
      { name: 'Marcus Sterling', appearance: 'Billionaire CEO in navy suit, silver eyes' },
    ],
    scriptText: 'ACT I: THE INFILTRATION\nScene 1: Marcus high-rise office.\nElena slides the encrypted drive across the glass table.',
    version: 1,
    createdAt: now,
  });

  // Story Shots
  await storyRef.collection('shots').doc('shot_01').set({
    sequenceIndex: 1,
    sceneDescription: 'High-rise glass office at night. Rain streams down windows with neon reflections.',
    cameraDirection: 'Wide establishing tracking shot moving forward toward Marcus silhouetted by the glass.',
    dialogue: 'Elena: You thought you buried the prototype data, Marcus.',
    durationSeconds: 5,
    keyframeImageUrl: 'https://images.unsplash.com/photo-1508873696983-2df5293cbdaf?w=800',
    videoClipUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    status: 'VIDEO_DONE',
    createdAt: now,
  });

  await storyRef.collection('shots').doc('shot_02').set({
    sequenceIndex: 2,
    sceneDescription: 'Elena steps into ambient light holding glowing encrypted flash drive.',
    cameraDirection: 'Medium low-angle push in on Elena Vance.',
    dialogue: 'Elena: Paper trails do not vanish into thin air.',
    durationSeconds: 5,
    keyframeImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
    videoClipUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    status: 'VIDEO_DONE',
    createdAt: now,
  });
  console.log('✅ Created project, story, and storyboard shot subcollections');

  // 6. Viral Photo Effects Collection
  await db.collection('effects_jobs').doc('effect_hug_001').set({
    userId: demoUserId,
    effectType: 'HUG',
    sourceImageS3Key: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
    secondaryImageS3Key: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
    hasConsentConfirmation: true, // Face consent gate passed
    status: 'COMPLETED',
    outputVideoS3Key: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    createdAt: now,
  });
  console.log('✅ Created effects_jobs sample');

  // 7. Moderation Events Collection
  await db.collection('moderation_events').doc('mod_event_001').set({
    userId: demoUserId,
    contentType: 'TEXT',
    triggerKeyword: 'none (safe audit)',
    riskScore: 0.05,
    actionTaken: 'ALLOW',
    details: { prompt: 'Penthouse confrontation in neon rain' },
    createdAt: now,
  });
  console.log('✅ Created moderation_events sample');

  console.log('\n🎉 ALL COLLECTIONS & TABLES READY IN CLOUD FIRESTORE!');
}

seedDramaForgeFirestore().catch((err) => {
  console.error('Error seeding Firestore:', err);
  process.exit(1);
});

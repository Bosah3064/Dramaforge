const fs = require('fs');
const path = require('path');
const os = require('os');

// 1. Read token from firebase-tools.json
const configPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
if (!fs.existsSync(configPath)) {
  console.error('Firebase tools config not found');
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const accessToken = config.tokens.access_token;
const projectId = 'dramaforge-f0357';
const baseUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

async function setDocument(docPath, fields) {
  const url = `${baseUrl}/${docPath}`;
  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
    body: JSON.stringify({ fields }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error(`Error setting ${docPath}:`, errorText);
    throw new Error(`Failed to set ${docPath}`);
  }

  const result = await response.json();
  console.log(`✅ Set: ${docPath}`);
  return result;
}

async function run() {
  console.log('🚀 Seeding DramaForge Collections & Documents in Cloud Firestore via REST API...\n');

  const now = new Date().toISOString();
  const thirtyDays = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString();

  // 1. users/creator_demo_001
  await setDocument('users/creator_demo_001', {
    email: { stringValue: 'creator@dramaforge.ai' },
    role: { stringValue: 'USER' },
    enforcementState: { stringValue: 'NONE' },
    isAgeVerified: { booleanValue: true },
    createdAt: { timestampValue: now },
    updatedAt: { timestampValue: now },
  });

  // 2. users/creator_demo_001/consent_records/consent_initial
  await setDocument('users/creator_demo_001/consent_records/consent_initial', {
    version: { stringValue: '2026.1' },
    scope: { stringValue: 'story_script,keyframes,video_synthesis' },
    providersDisclosed: {
      arrayValue: {
        values: [
          { stringValue: 'OpenAI (Script & Storyboard)' },
          { stringValue: 'Google Veo (Video Synthesis)' },
          { stringValue: 'BytePlus (Image & Motion)' },
          { stringValue: 'Anthropic (Creative Expansion)' },
        ],
      },
    },
    ipAddress: { stringValue: '127.0.0.1' },
    acceptedAt: { timestampValue: now },
  });

  // 3. users/creator_demo_001/coin_ledger/ledger_welcome
  await setDocument('users/creator_demo_001/coin_ledger/ledger_welcome', {
    bucket: { stringValue: 'PURCHASED' },
    direction: { stringValue: 'CREDIT' },
    amount: { integerValue: '100' },
    balanceAfterSubscription: { integerValue: '0' },
    balanceAfterPurchased: { integerValue: '100' },
    reason: { stringValue: 'GRANT' },
    referenceId: { stringValue: 'welcome_starter_pack' },
    createdAt: { timestampValue: now },
  });

  // 4. users/creator_demo_001/coin_ledger/ledger_pro_monthly
  await setDocument('users/creator_demo_001/coin_ledger/ledger_pro_monthly', {
    bucket: { stringValue: 'SUBSCRIPTION' },
    direction: { stringValue: 'CREDIT' },
    amount: { integerValue: '700' },
    balanceAfterSubscription: { integerValue: '700' },
    balanceAfterPurchased: { integerValue: '100' },
    reason: { stringValue: 'GRANT' },
    referenceId: { stringValue: 'sub_pro_monthly_cycle_1' },
    expiresAt: { timestampValue: thirtyDays },
    createdAt: { timestampValue: now },
  });

  // 5. users/creator_demo_001/subscriptions/sub_pro_monthly
  await setDocument('users/creator_demo_001/subscriptions/sub_pro_monthly', {
    storeId: { stringValue: 'revcat_sub_monthly_001' },
    tier: { stringValue: 'PRO_MONTHLY' },
    status: { stringValue: 'ACTIVE' },
    coinsAllocated: { integerValue: '700' },
    currentPeriodStart: { timestampValue: now },
    currentPeriodEnd: { timestampValue: thirtyDays },
    createdAt: { timestampValue: now },
  });

  // 6. projects/proj_penthouse_confrontation
  await setDocument('projects/proj_penthouse_confrontation', {
    userId: { stringValue: 'creator_demo_001' },
    title: { stringValue: 'The Penthouse Confrontation' },
    mode: { stringValue: 'STUDIO' },
    aspectRatio: { stringValue: '9:16' },
    stylePreset: { stringValue: 'cinematic' },
    targetDurationSeconds: { integerValue: '30' },
    status: { stringValue: 'COMPLETED' },
    finalVideoUrl: { stringValue: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4' },
    createdAt: { timestampValue: now },
    updatedAt: { timestampValue: now },
  });

  // 7. projects/proj_penthouse_confrontation/stories/story_001
  await setDocument('projects/proj_penthouse_confrontation/stories/story_001', {
    synopsis: { stringValue: 'When investigative reporter Elena Vance uncovers a covert takeover orchestrated by CEO Marcus Sterling, a tense confrontation in a rainy penthouse leads to a shocking alliance neither anticipated.' },
    genre: { stringValue: 'Revenge Drama' },
    scriptText: { stringValue: 'ACT I: THE INFILTRATION\nScene 1: Marcus high-rise office.\nELENA: You thought you buried the prototype data, Marcus.' },
    version: { integerValue: '1' },
    createdAt: { timestampValue: now },
  });

  // 8. projects/proj_penthouse_confrontation/stories/story_001/shots/shot_01
  await setDocument('projects/proj_penthouse_confrontation/stories/story_001/shots/shot_01', {
    sequenceIndex: { integerValue: '1' },
    sceneDescription: { stringValue: 'High-rise glass office at night. Rain streams down windows with neon reflections.' },
    cameraDirection: { stringValue: 'Wide establishing tracking shot moving forward toward Marcus silhouetted by the glass.' },
    dialogue: { stringValue: 'Elena: You thought you buried the prototype data, Marcus.' },
    durationSeconds: { integerValue: '5' },
    keyframeImageUrl: { stringValue: 'https://images.unsplash.com/photo-1508873696983-2df5293cbdaf?w=800' },
    videoClipUrl: { stringValue: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4' },
    status: { stringValue: 'VIDEO_DONE' },
    createdAt: { timestampValue: now },
  });

  // 9. projects/proj_penthouse_confrontation/stories/story_001/shots/shot_02
  await setDocument('projects/proj_penthouse_confrontation/stories/story_001/shots/shot_02', {
    sequenceIndex: { integerValue: '2' },
    sceneDescription: { stringValue: 'Elena steps into ambient light holding glowing encrypted flash drive.' },
    cameraDirection: { stringValue: 'Medium low-angle push in on Elena Vance.' },
    dialogue: { stringValue: 'Elena: Paper trails do not vanish into thin air.' },
    durationSeconds: { integerValue: '5' },
    keyframeImageUrl: { stringValue: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800' },
    videoClipUrl: { stringValue: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4' },
    status: { stringValue: 'VIDEO_DONE' },
    createdAt: { timestampValue: now },
  });

  // 10. effects_jobs/effect_hug_001
  await setDocument('effects_jobs/effect_hug_001', {
    userId: { stringValue: 'creator_demo_001' },
    effectType: { stringValue: 'HUG' },
    sourceImageS3Key: { stringValue: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800' },
    secondaryImageS3Key: { stringValue: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800' },
    hasConsentConfirmation: { booleanValue: true },
    status: { stringValue: 'COMPLETED' },
    outputVideoS3Key: { stringValue: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4' },
    createdAt: { timestampValue: now },
  });

  // 11. moderation_events/mod_event_001
  await setDocument('moderation_events/mod_event_001', {
    userId: { stringValue: 'creator_demo_001' },
    contentType: { stringValue: 'TEXT' },
    triggerKeyword: { stringValue: 'none (safe audit)' },
    riskScore: { doubleValue: 0.05 },
    actionTaken: { stringValue: 'ALLOW' },
    createdAt: { timestampValue: now },
  });

  console.log('\n🎉 ALL 11 TABLES / COLLECTIONS ARE LIVE AND POPULATED IN CLOUD FIRESTORE!');
}

run().catch(console.error);

class AppConstants {
  static const String appName = 'DramaForge';
  static const String apiBaseUrl = 'http://localhost:3000/api/v1';

  // Coin Pricing
  static const int scriptGenerationCost = 0;
  static const int keyframePerShotCost = 2;
  static const int videoPerShotCost = 8;
  static const int photoEffectCost = 8;
  static const int finalRender1080pCost = 15;

  // Third-Party AI Providers Disclosed in Pre-Transfer Consent
  static const List<String> disclosedAiProviders = [
    'OpenAI (Script & Dialogue generation)',
    'Google Veo (Cinematic video synthesis)',
    'Anthropic (Creative story expansion)',
    'BytePlus (Image & Video generative models)',
  ];

  static const String consentTermsVersion = '2026.1';
}


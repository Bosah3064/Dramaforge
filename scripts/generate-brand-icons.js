const fs = require('fs');
const path = require('path');
const { Resvg } = require('@resvg/resvg-js');

// Master Vector SVG (1024x1024)
const masterSvg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <defs>
    <!-- Background Gradient -->
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0e1322"/>
      <stop offset="50%" stop-color="#080b14"/>
      <stop offset="100%" stop-color="#03050a"/>
    </linearGradient>

    <!-- Neon Shield/Border Gradient -->
    <linearGradient id="borderGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#a855f7" stop-opacity="0.8"/>
      <stop offset="50%" stop-color="#6366f1" stop-opacity="0.5"/>
      <stop offset="100%" stop-color="#f59e0b" stop-opacity="0.7"/>
    </linearGradient>

    <!-- Clapper / Forge Main Gradient -->
    <linearGradient id="forgeGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#9333ea"/>
      <stop offset="45%" stop-color="#7c3aed"/>
      <stop offset="100%" stop-color="#4f46e5"/>
    </linearGradient>

    <!-- Molten Gold AI Spark Gradient -->
    <linearGradient id="goldSpark" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#fffbeb"/>
      <stop offset="30%" stop-color="#fef08a"/>
      <stop offset="70%" stop-color="#f59e0b"/>
      <stop offset="100%" stop-color="#d97706"/>
    </linearGradient>

    <!-- Neon Glow Filter -->
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="16" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>

    <filter id="sparkGlow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="24" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>

  <!-- Base Rounded Container -->
  <rect x="24" y="24" width="976" height="976" rx="224" fill="url(#bgGrad)"/>
  <rect x="24" y="24" width="976" height="976" rx="224" fill="none" stroke="url(#borderGrad)" stroke-width="12"/>

  <!-- Ambient Internal Violet Bloom -->
  <circle cx="512" cy="512" r="340" fill="#7c3aed" opacity="0.16" filter="url(#glow)"/>
  <circle cx="512" cy="540" r="220" fill="#f59e0b" opacity="0.12" filter="url(#glow)"/>

  <!-- Clapperboard Top Plate (Tilted Action Cut) -->
  <g transform="translate(512, 512)">
    <!-- Film Perforation Dots on Left -->
    <circle cx="-320" cy="-220" r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="-320" cy="-140" r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="-320" cy="-60"  r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="-320" cy="20"   r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="-320" cy="100"  r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="-320" cy="180"  r="16" fill="#6366f1" opacity="0.6"/>

    <!-- Film Perforation Dots on Right -->
    <circle cx="320" cy="-220" r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="320" cy="-140" r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="320" cy="-60"  r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="320" cy="20"   r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="320" cy="100"  r="16" fill="#6366f1" opacity="0.6"/>
    <circle cx="320" cy="180"  r="16" fill="#6366f1" opacity="0.6"/>

    <!-- Main Clapper Head Angle -->
    <path d="M -260 -240 L 260 -240 L 230 -160 L -290 -160 Z" fill="#1e1b4b" stroke="#7c3aed" stroke-width="6"/>

    <!-- Clapper Chevron Stripes -->
    <polygon points="-240,-240 -180,-240 -210,-160 -270,-160" fill="url(#goldSpark)"/>
    <polygon points="-120,-240 -60,-240 -90,-160 -150,-160" fill="url(#forgeGrad)"/>
    <polygon points="0,-240 60,-240 30,-160 -30,-160" fill="url(#goldSpark)"/>
    <polygon points="120,-240 180,-240 150,-160 90,-160" fill="url(#forgeGrad)"/>

    <!-- Stylized "DF" Monogram / Cinematic Frame Body -->
    <!-- Letter 'D' Frame Outer -->
    <path d="M -230 -120 
             L 60 -120 
             C 180 -120, 240 -40, 240 60 
             C 240 160, 180 240, 60 240 
             L -230 240 Z" 
          fill="none" 
          stroke="url(#forgeGrad)" 
          stroke-width="52" 
          stroke-linejoin="round"
          filter="url(#glow)"/>

    <!-- Letter 'F' Cross-Bars inside Monogram -->
    <path d="M -70 -20 L 100 -20" stroke="url(#forgeGrad)" stroke-width="44" stroke-linecap="round"/>
    <path d="M -70 80 L 60 80" stroke="url(#forgeGrad)" stroke-width="44" stroke-linecap="round"/>

    <!-- Central AI Star Spark / Molten Core -->
    <g transform="translate(70, -30)" filter="url(#sparkGlow)">
      <!-- 8-Pointed Star -->
      <path d="M 0 -110 
               Q 0 -15, -95 0 
               Q 0 15, 0 110 
               Q 0 15, 95 0 
               Q 0 -15, 0 -110 Z" 
            fill="url(#goldSpark)"/>
      <path d="M 0 -70 
               Q 0 -10, -60 0 
               Q 0 10, 0 70 
               Q 0 10, 60 0 
               Q 0 -10, 0 -70 Z" 
            transform="rotate(45)" 
            fill="#ffffff" 
            opacity="0.9"/>
      <circle cx="0" cy="0" r="18" fill="#ffffff"/>
    </g>

    <!-- Secondary Ambient Sparks -->
    <circle cx="-160" cy="-60" r="6" fill="#fde047" opacity="0.8"/>
    <circle cx="180" cy="160" r="8" fill="#f59e0b" opacity="0.9"/>
    <circle cx="-140" cy="180" r="5" fill="#a855f7" opacity="0.8"/>
  </g>
</svg>`;

async function renderPng(svgString, width, height) {
  const resvg = new Resvg(svgString, {
    fitTo: {
      mode: 'width',
      value: width,
    },
  });
  const pngData = resvg.render();
  return pngData.asPng();
}

async function main() {
  console.log('🎨 Generating DramaForge Brand Identity, Icons, and Favicons everywhere...\n');

  // Ensure directories exist
  const dirs = [
    'assets/logo',
    'packages/mobile/web',
    'packages/mobile/web/icons',
    'packages/mobile/android/app/src/main/res/mipmap-mdpi',
    'packages/mobile/android/app/src/main/res/mipmap-hdpi',
    'packages/mobile/android/app/src/main/res/mipmap-xhdpi',
    'packages/mobile/android/app/src/main/res/mipmap-xxhdpi',
    'packages/mobile/android/app/src/main/res/mipmap-xxxhdpi',
    'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset',
    'packages/admin-panel/public',
  ];

  for (const d of dirs) {
    fs.mkdirSync(d, { recursive: true });
  }

  // 1. Write Master SVG
  fs.writeFileSync('assets/logo/dramaforge_logo_master.svg', masterSvg, 'utf8');
  fs.writeFileSync('packages/admin-panel/public/favicon.svg', masterSvg, 'utf8');
  console.log('✅ Master SVG: assets/logo/dramaforge_logo_master.svg');

  // Target image definitions
  const targets = [
    // Brand Master
    { path: 'assets/logo/dramaforge_icon_1024.png', size: 1024 },
    { path: 'assets/logo/dramaforge_icon_512.png', size: 512 },

    // Web / PWA Favicon & Icons
    { path: 'packages/mobile/web/favicon.png', size: 64 },
    { path: 'packages/mobile/web/icons/Icon-192.png', size: 192 },
    { path: 'packages/mobile/web/icons/Icon-512.png', size: 512 },
    { path: 'packages/mobile/web/icons/Icon-maskable-192.png', size: 192 },
    { path: 'packages/mobile/web/icons/Icon-maskable-512.png', size: 512 },
    { path: 'packages/admin-panel/public/favicon.png', size: 64 },

    // Android Launcher Icons (mipmap)
    { path: 'packages/mobile/android/app/src/main/res/mipmap-mdpi/ic_launcher.png', size: 48 },
    { path: 'packages/mobile/android/app/src/main/res/mipmap-hdpi/ic_launcher.png', size: 72 },
    { path: 'packages/mobile/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png', size: 96 },
    { path: 'packages/mobile/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png', size: 144 },
    { path: 'packages/mobile/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png', size: 192 },

    // iOS Launcher Icon
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png', size: 1024 },
  ];

  for (const t of targets) {
    const png = await renderPng(masterSvg, t.size, t.size);
    fs.writeFileSync(t.path, png);
    console.log(`✅ Generated (${t.size}x${t.size}): ${t.path}`);
  }

  console.log('\n✨ ALL LOGOS, FAVICONS, AND LAUNCHER ICONS CREATED SUCCESSFULLY!');
}

main().catch(console.error);

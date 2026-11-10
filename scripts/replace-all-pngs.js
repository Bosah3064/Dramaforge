const fs = require('fs');
const path = require('path');
const { Resvg } = require('@resvg/resvg-js');

const masterSvgPath = 'assets/logo/dramaforge_logo_master.svg';
const masterSvg = fs.readFileSync(masterSvgPath, 'utf8');

async function renderPng(width, height) {
  const resvg = new Resvg(masterSvg, {
    fitTo: {
      mode: 'width',
      value: width,
    },
  });
  return resvg.render().asPng();
}

async function run() {
  console.log('🔄 Replacing ALL project PNGs with the new DramaForge logo everywhere...\n');

  const targets = [
    // 1. Android Launcher Icons
    { path: 'packages/mobile/android/app/src/main/res/mipmap-mdpi/ic_launcher.png', size: 48 },
    { path: 'packages/mobile/android/app/src/main/res/mipmap-hdpi/ic_launcher.png', size: 72 },
    { path: 'packages/mobile/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png', size: 96 },
    { path: 'packages/mobile/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png', size: 144 },
    { path: 'packages/mobile/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png', size: 192 },

    // 2. Web & PWA Icons
    { path: 'packages/mobile/web/favicon.png', size: 64 },
    { path: 'packages/mobile/web/icons/Icon-192.png', size: 192 },
    { path: 'packages/mobile/web/icons/Icon-512.png', size: 512 },
    { path: 'packages/mobile/web/icons/Icon-maskable-192.png', size: 192 },
    { path: 'packages/mobile/web/icons/Icon-maskable-512.png', size: 512 },
    { path: 'packages/admin-panel/public/favicon.png', size: 64 },

    // 3. iOS App Icons
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png', size: 20 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png', size: 40 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png', size: 60 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png', size: 29 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png', size: 58 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png', size: 87 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png', size: 40 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png', size: 80 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png', size: 120 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png', size: 120 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png', size: 180 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png', size: 76 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png', size: 152 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png', size: 167 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png', size: 1024 },

    // 4. iOS Launch Images
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png', size: 300 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png', size: 600 },
    { path: 'packages/mobile/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png', size: 900 },

    // 5. macOS App Icons
    { path: 'packages/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png', size: 16 },
    { path: 'packages/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png', size: 32 },
    { path: 'packages/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png', size: 64 },
    { path: 'packages/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png', size: 128 },
    { path: 'packages/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png', size: 256 },
    { path: 'packages/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png', size: 512 },
    { path: 'packages/mobile/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png', size: 1024 },
  ];

  for (const t of targets) {
    const dir = path.dirname(t.path);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    const png = await renderPng(t.size, t.size);
    fs.writeFileSync(t.path, png);
    console.log(`✅ Replaced (${t.size}x${t.size}): ${t.path}`);
  }

  console.log('\n🎉 ALL PNG LOGOS AND ICONS SUCCESSFULLY REPLACED ACROSS THE ENTIRE PROJECT!');
}

run().catch(console.error);

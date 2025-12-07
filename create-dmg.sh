#!/bin/bash

# DeskPlant DMG Creator Script
# Bu script dağıtım için profesyonel bir DMG dosyası oluşturur

set -e

echo "📦 DeskPlant DMG oluşturuluyor..."
echo ""

# Değişkenler
APP_NAME="DeskPlant"
VERSION="1.0.0"
BUILD_DIR="build"
DMG_NAME="${APP_NAME}-${VERSION}-Universal"
DIST_DIR="dist"
VOLUME_NAME="DeskPlant"
BACKGROUND_COLOR="#34C759"

# Build edilmiş uygulamayı bul
APP_PATH=$(find "$BUILD_DIR" -name "${APP_NAME}.app" -type d | head -1)

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Hata: Önce uygulamayı build etmelisiniz!"
    echo "Şunu çalıştırın: ./build.sh"
    exit 1
fi

# Dist dizinini oluştur
echo "📁 Dist dizini hazırlanıyor..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Geçici DMG dizini oluştur
TEMP_DMG_DIR="${DIST_DIR}/temp"
mkdir -p "$TEMP_DMG_DIR"

# Uygulamayı geçici dizine kopyala
echo "📋 Uygulama kopyalanıyor..."
cp -R "$APP_PATH" "$TEMP_DMG_DIR/"

# Applications klasörüne sembolik link oluştur
echo "🔗 Applications bağlantısı oluşturuluyor..."
ln -s /Applications "$TEMP_DMG_DIR/Applications"

# README dosyası ekle
echo "📝 README dosyası oluşturuluyor..."
cat > "$TEMP_DMG_DIR/README.txt" << 'EOF'
🌱 DeskPlant - Pomodoro Zamanlayıcı

KURULUM:
1. DeskPlant.app dosyasını Applications klasörüne sürükleyin
2. Applications klasöründen uygulamayı açın
3. Menü çubuğunda bitki ikonunu göreceksiniz

SİSTEM GEREKSİNİMLERİ:
• macOS 13.0 (Ventura) veya üzeri
• Intel Mac veya Apple Silicon (M1/M2/M3) Mac

ÖZELLİKLER:
• Pomodoro tekniği ile odaklanma
• Otomatik zamanlayıcı (25 dk çalışma, 5 dk mola)
• Bitki büyütme sistemi ile motivasyon
• İstatistikler ve ilerleme takibi
• Sistem bildirimleri
• Çoklu dil desteği (Türkçe, İngilizce, Fransızca, Almanca)
• Sistem başlangıcında otomatik açılma

DESTEK:
Sorunlar için: https://github.com/yourusername/deskplant/issues

MİMARİ:
Bu uygulama Universal Binary olarak derlenmiştir ve hem Intel hem de 
Apple Silicon çipli Mac'lerde yerel olarak çalışır.

© 2024 DeskPlant. Tüm hakları saklıdır.
EOF

# DMG oluştur
echo "💿 DMG dosyası oluşturuluyor..."
DMG_PATH="${DIST_DIR}/${DMG_NAME}.dmg"

# Geçici DMG oluştur
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$TEMP_DMG_DIR" \
    -ov -format UDZO \
    -imagekey zlib-level=9 \
    "$DMG_PATH"

# Geçici dosyaları temizle
echo "🧹 Geçici dosyalar temizleniyor..."
rm -rf "$TEMP_DMG_DIR"

# DMG bilgileri
DMG_SIZE=$(du -sh "$DMG_PATH" | cut -f1)
DMG_MD5=$(md5 -q "$DMG_PATH" 2>/dev/null || echo "N/A")

echo ""
echo "✅ DMG başarıyla oluşturuldu!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 DMG Dosyası: $DMG_PATH"
echo "📏 Boyut: $DMG_SIZE"
echo "🔐 MD5: $DMG_MD5"
echo "🏗️  Versiyon: $VERSION"
echo "💻 Mimari: Universal (Intel + Apple Silicon)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Dağıtım Önerileri:"
echo ""
echo "1️⃣  DMG'yi test etmek için:"
echo "   open \"$DMG_PATH\""
echo ""
echo "2️⃣  DMG'yi paylaşmak için:"
echo "   - GitHub Releases'e yükleyin"
echo "   - Web sitenizde barındırın"
echo "   - Email veya dosya paylaşım servisleri kullanın"
echo ""
echo "3️⃣  Notarize (Apple onayı) için:"
echo "   ./notarize.sh \"$DMG_PATH\""
echo ""
echo "⚠️  ÖNEMLİ: Profesyonel dağıtım için uygulamanızı Apple Developer"
echo "   hesabınızla imzalamanız ve notarize etmeniz önerilir."
echo ""


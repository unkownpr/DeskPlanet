#!/bin/bash

# DeskPlant Universal Binary Build Script
# Bu script hem Intel hem de Apple Silicon çipli Mac'ler için uygulama oluşturur

set -e  # Hata durumunda çık

echo "🌱 DeskPlant Universal Binary Build Başlatılıyor..."
echo ""

# Xcode kurulu mu kontrol et
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Hata: Xcode yüklü değil veya xcodebuild PATH'te yok"
    echo "Lütfen Xcode'u App Store'dan yükleyin"
    exit 1
fi

# Proje değişkenleri
PROJECT_NAME="DeskPlant"
SCHEME="DeskPlant"
CONFIGURATION="Release"
BUILD_DIR="build"
VERSION="1.0.0"

# Önceki build'leri temizle
echo "🧹 Önceki build'ler temizleniyor..."
rm -rf "$BUILD_DIR"

# Universal Binary için build (hem Intel hem de Apple Silicon)
echo "🔨 Universal Binary oluşturuluyor (Intel + Apple Silicon)..."
echo "   - macOS 13.0 ve üzeri destekleniyor"
echo ""

xcodebuild \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -arch x86_64 \
    -arch arm64 \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    build

# Build edilmiş uygulamayı bul
APP_PATH=$(find "$BUILD_DIR" -name "${PROJECT_NAME}.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Hata: Build edilmiş uygulama bulunamadı"
    exit 1
fi

# Mimarileri doğrula
echo ""
echo "🔍 Binary mimarileri kontrol ediliyor..."
BINARY_PATH="${APP_PATH}/Contents/MacOS/${PROJECT_NAME}"
if [ -f "$BINARY_PATH" ]; then
    ARCHS=$(lipo -archs "$BINARY_PATH" 2>/dev/null || echo "Bilinmeyen")
    echo "   ✓ Desteklenen mimariler: $ARCHS"
    
    if [[ "$ARCHS" == *"x86_64"* ]] && [[ "$ARCHS" == *"arm64"* ]]; then
        echo "   ✓ Universal Binary başarılı! (Intel + Apple Silicon)"
    else
        echo "   ⚠️  Uyarı: Sadece $ARCHS desteği var"
    fi
else
    echo "   ⚠️  Uyarı: Binary dosyası bulunamadı"
fi

# Uygulama bilgileri
echo ""
echo "✅ Build başarılı!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Uygulama: $APP_PATH"
echo "📏 Boyut: $(du -sh "$APP_PATH" | cut -f1)"
echo "🏗️  Versiyon: $VERSION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Kullanım Seçenekleri:"
echo ""
echo "1️⃣  Uygulamayı test etmek için:"
echo "   open \"$APP_PATH\""
echo ""
echo "2️⃣  Applications klasörüne kurmak için:"
echo "   cp -r \"$APP_PATH\" /Applications/"
echo ""
echo "3️⃣  DMG dosyası oluşturmak için (dağıtım için önerilir):"
echo "   ./create-dmg.sh"
echo ""

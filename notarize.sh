#!/bin/bash

# DeskPlant Notarization Script
# Bu script uygulamanızı Apple tarafından onaylatır (macOS Gatekeeper için gerekli)

set -e

echo "🔐 DeskPlant Notarization İşlemi"
echo ""

# Kullanım kontrolü
if [ $# -eq 0 ]; then
    echo "❌ Hata: DMG dosyası belirtilmedi"
    echo ""
    echo "Kullanım:"
    echo "  ./notarize.sh <dmg-dosya-yolu>"
    echo ""
    echo "Örnek:"
    echo "  ./notarize.sh dist/DeskPlant-1.0.0-Universal.dmg"
    echo ""
    exit 1
fi

DMG_PATH="$1"

if [ ! -f "$DMG_PATH" ]; then
    echo "❌ Hata: DMG dosyası bulunamadı: $DMG_PATH"
    exit 1
fi

# Apple Developer bilgilerini kontrol et
echo "📋 Gerekli Bilgiler:"
echo ""
echo "Notarization için aşağıdaki bilgilere ihtiyacınız var:"
echo "1. Apple Developer hesabı (99 USD/yıl)"
echo "2. Developer ID Application sertifikası"
echo "3. App-specific password (appleid.apple.com'dan oluşturun)"
echo ""

read -p "Apple ID (email): " APPLE_ID
read -p "Team ID (10 karakterli kod, developer.apple.com'da bulunur): " TEAM_ID
read -s -p "App-specific password: " APP_PASSWORD
echo ""
echo ""

if [ -z "$APPLE_ID" ] || [ -z "$TEAM_ID" ] || [ -z "$APP_PASSWORD" ]; then
    echo "❌ Hata: Tüm bilgiler gerekli"
    exit 1
fi

# Keychain'e password kaydet (opsiyonel)
echo "💾 Keychain'e password kaydediliyor..."
xcrun notarytool store-credentials "DeskPlant-Notarization" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "$APP_PASSWORD" 2>/dev/null || true

# DMG'yi imzala (eğer imzalı değilse)
echo ""
echo "✍️  DMG imzalanıyor..."
codesign --force --sign "Developer ID Application" "$DMG_PATH" 2>/dev/null || {
    echo "⚠️  Uyarı: DMG imzalanamadı. Manuel olarak imzalayın veya devam edin."
}

# Notarization'a gönder
echo ""
echo "📤 Apple'a notarization için gönderiliyor..."
echo "   (Bu işlem 5-30 dakika sürebilir...)"
echo ""

SUBMIT_OUTPUT=$(xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "$APP_PASSWORD" \
    --wait)

echo "$SUBMIT_OUTPUT"

# Submission ID'yi al
SUBMISSION_ID=$(echo "$SUBMIT_OUTPUT" | grep "id:" | head -1 | awk '{print $2}')

if [ -z "$SUBMISSION_ID" ]; then
    echo "❌ Hata: Submission ID alınamadı"
    exit 1
fi

# Durumu kontrol et
echo ""
echo "🔍 Notarization durumu kontrol ediliyor..."
STATUS=$(xcrun notarytool info "$SUBMISSION_ID" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "$APP_PASSWORD")

echo "$STATUS"

if echo "$STATUS" | grep -q "status: Accepted"; then
    echo ""
    echo "✅ Notarization başarılı!"
    echo ""
    echo "📎 Ticket'ı DMG'ye ekle..."
    xcrun stapler staple "$DMG_PATH"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ DMG başarıyla notarize edildi ve staple'landı!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Artık DMG'nizi güvenle dağıtabilirsiniz."
    echo "Kullanıcılar Gatekeeper uyarısı almayacak."
    echo ""
else
    echo ""
    echo "❌ Notarization başarısız!"
    echo ""
    echo "Log'u görüntülemek için:"
    echo "xcrun notarytool log $SUBMISSION_ID --apple-id $APPLE_ID --team-id $TEAM_ID --password [PASSWORD]"
    echo ""
    exit 1
fi


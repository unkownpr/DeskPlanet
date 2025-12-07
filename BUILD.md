# 🔧 Build Instructions

> Detaylı derleme ve dağıtım talimatları

## 📋 Gereksinimler

- **Xcode**: 15.0 veya üzeri
- **macOS SDK**: 13.0+ 
- **Command Line Tools**: `xcode-select --install`
- **Git**: Versiyon kontrolü için

## 🚀 Hızlı Derleme

### 1. Universal Binary (Önerilen)

Intel ve Apple Silicon için tek binary:

```bash
./build.sh
```

Bu komut:
- ✅ Universal Binary oluşturur (x86_64 + arm64)
- ✅ Release konfigürasyonu kullanır
- ✅ Mimarileri otomatik doğrular
- ✅ `build/DerivedData/Build/Products/Release/` klasörüne çıktı verir

### 2. DMG Paketi Oluşturma

Dağıtım için DMG dosyası:

```bash
# Önce build edin
./build.sh

# Sonra DMG oluşturun
./create-dmg.sh
```

Çıktı: `dist/DeskPlant-X.X.X-Universal.dmg`

### 3. Notarization (Opsiyonel)

Apple onayı için (Apple Developer hesabı gerektirir):

```bash
./notarize.sh dist/DeskPlant-X.X.X-Universal.dmg
```

## 🛠️ Manuel Build

### Release Build (Universal)

```bash
xcodebuild -project DeskPlant.xcodeproj \
  -scheme DeskPlant \
  -configuration Release \
  -arch x86_64 -arch arm64 \
  ONLY_ACTIVE_ARCH=NO \
  -derivedDataPath build/DerivedData \
  build
```

### Debug Build

```bash
xcodebuild -project DeskPlant.xcodeproj \
  -scheme DeskPlant \
  -configuration Debug \
  -derivedDataPath build/DerivedData \
  build
```

### Sadece Apple Silicon

```bash
xcodebuild -project DeskPlant.xcodeproj \
  -scheme DeskPlant \
  -configuration Release \
  -arch arm64 \
  -derivedDataPath build/DerivedData \
  build
```

### Sadece Intel

```bash
xcodebuild -project DeskPlant.xcodeproj \
  -scheme DeskPlant \
  -configuration Release \
  -arch x86_64 \
  -derivedDataPath build/DerivedData \
  build
```

## ✅ Binary Doğrulama

### Desteklenen Mimarileri Kontrol Et

```bash
lipo -info build/DerivedData/Build/Products/Release/DeskPlant.app/Contents/MacOS/DeskPlant
```

**Beklenen çıktı:**
```
Architectures in the fat file: DeskPlant are: x86_64 arm64
```

### Detaylı Binary Bilgisi

```bash
file build/DerivedData/Build/Products/Release/DeskPlant.app/Contents/MacOS/DeskPlant
```

### Code Signature Kontrolü

```bash
codesign -dv --verbose=4 build/DerivedData/Build/Products/Release/DeskPlant.app
```

## 📦 Dağıtım

### 1. Development Build (Kendi Kullanımınız İçin)

```bash
# Build edin
./build.sh

# Applications'a kopyalayın
cp -r build/DerivedData/Build/Products/Release/DeskPlant.app /Applications/

# Çalıştırın
open /Applications/DeskPlant.app
```

### 2. Public Distribution (Paylaşım İçin)

#### Code Signing Olmadan (Basit)

```bash
# Build + DMG oluştur
./build.sh
./create-dmg.sh

# dist/ klasöründeki DMG'yi paylaşın
```

**Not:** Kullanıcıların ilk açılışta "sağ tık → Aç" yapması gerekir.

#### Code Signing ile (Profesyonel)

**Gereksinimler:**
- Apple Developer Program üyeliği ($99/yıl)
- Developer ID Application sertifikası

**Adımlar:**

1. **Sertifikayı alın:**
   - developer.apple.com → Certificates
   - "Developer ID Application" sertifikası oluşturun
   - Keychain'e yükleyin

2. **Xcode'da yapılandırın:**
   - Project → Signing & Capabilities
   - Team: Apple Developer hesabınızı seçin
   - Signing Certificate: Developer ID Application

3. **Build ve sign edin:**
```bash
# CODE_SIGN_IDENTITY ile build
xcodebuild -project DeskPlant.xcodeproj \
  -scheme DeskPlant \
  -configuration Release \
  -arch x86_64 -arch arm64 \
  CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)" \
  -derivedDataPath build/DerivedData \
  build
```

4. **Notarize edin:**
```bash
./notarize.sh dist/DeskPlant-X.X.X-Universal.dmg
```

## 🔄 GitHub Actions (Otomatik)

Repository'de `.github/workflows/release.yml` mevcut.

### Otomatik Release Tetikleme

```bash
# Yeni tag oluştur
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1
```

GitHub Actions otomatik olarak:
1. ✅ Universal binary build eder
2. ✅ DMG paketi oluşturur
3. ✅ GitHub Release yayınlar
4. ✅ DMG'yi release'e ekler

### Workflow Detayları

Workflow şunları yapar:
- macOS 13 runner kullanır
- Xcode 15+ ile build eder
- `v*` tag'lerinde tetiklenir
- DMG ve ZIP formatında çıktı verir
- SHA-256 checksum'ları oluşturur

## 🐛 Troubleshooting

### Build Hataları

**"xcodebuild: command not found"**
```bash
# Command Line Tools yükleyin
xcode-select --install
```

**"No signing identity found"**
- Development için: Xcode → Preferences → Accounts → hesap ekle
- Distribution için: developer.apple.com'dan sertifika alın

**"Architecture not supported"**
```bash
# Binary'yi kontrol edin
lipo -info path/to/DeskPlant.app/Contents/MacOS/DeskPlant

# Gerekirse rebuild
./build.sh
```

### DMG Hataları

**"create-dmg command not found"**
```bash
# Homebrew ile yükleyin
brew install create-dmg
```

**"No such file or directory"**
- Önce `./build.sh` çalıştırın
- `build/DerivedData/Build/Products/Release/` klasöründe DeskPlant.app olmalı

### Runtime Hataları

**"DeskPlant.app is damaged"**
- Gatekeeper uyarısı, normal bir durumdur
- Çözüm: `xattr -cr DeskPlant.app` veya "sağ tık → Aç"

**"Icon not showing"**
- Debug build kullanıyorsanız Release build yapın
- Assets.xcassets/AppIcon doğru yapılandırılmış olmalı

## 📚 Ek Kaynaklar

### Apple Developer Dokümanları
- [Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)
- [Notarization Process](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Universal Binaries](https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary)

### Xcode Build Settings
- `ARCHS`: Hedef mimariler (x86_64, arm64)
- `ONLY_ACTIVE_ARCH`: NO = tüm mimariler için build et
- `CODE_SIGN_IDENTITY`: Kullanılacak sertifika
- `MARKETING_VERSION`: Uygulama versiyonu (Info.plist)
- `CURRENT_PROJECT_VERSION`: Build numarası

### Script Detayları

**build.sh:**
- Universal binary build eder
- Mimari doğrulaması yapar
- Çıktı konumunu gösterir

**create-dmg.sh:**
- DMG penceresi düzenini ayarlar
- Uygulama ikonunu ekler
- Applications klasörüne symlink oluşturur
- Volume ismini özelleştirir

**notarize.sh:**
- Apple notarization servisine gönderir
- Onay sürecini takip eder
- Başarılı olursa DMG'yi stapler

## 💡 İpuçları

1. **Temiz Build:** `rm -rf build/` ile önbelleği temizleyin
2. **Hızlı Test:** Debug build daha hızlı derler
3. **Distribution:** Release build + code signing + notarization kullanın
4. **CI/CD:** GitHub Actions otomatik build için kullanın
5. **Versiyon:** `Info.plist` veya `project.pbxproj` içinde `MARKETING_VERSION` güncelleyin

---

**Başarılı build'ler! 🎉**


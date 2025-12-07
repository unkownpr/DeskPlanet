# 🌱 DeskPlant

>   

DeskPlant is a macOS menu bar application that combines the proven Pomodoro technique with the joy of growing a digital plant. Stay focused, take breaks, and watch your plant thrive as you complete work sessions!

![DeskPlant Banner](plant.png)

## ✨ Features

### 🎯 Core Functionality
- **Pomodoro Timer**: Classic 25-5-15 minute intervals (Work-Short Break-Long Break)
- **Digital Plant Growth**: Your plant grows as you complete focus sessions
- **Menu Bar Integration**: Always accessible from your macOS menu bar
- **Smart Notifications**: Get notified when it's time to work or take a break

### 🌍 Multilingual Support
- 🇬🇧 English
- 🇹🇷 Türkçe (Turkish)
- 🇫🇷 Français (French)
- 🇩🇪 Deutsch (German)
- Dynamic language switching (no restart required)

### 🖱️ Intuitive Controls
- **Left Click**: Open main interface
- **Right Click**: Quick actions menu
- **Keyboard Shortcuts**:
  - `⌘F` - Start Focus
  - `⌘P` - Pause
  - `⌘R` - Resume
  - `⌘S` - Stop
  - `⌘O` - Open DeskPlant
  - `⌘Q` - Quit

### 🌿 Plant System
- **Health Bar**: Tracks your plant's health (0-100%)
- **Level System**: Your plant levels up every 5 completed sessions
- **Multiple Plant Types**:
  - 🌳 **Bonsai**: Balanced growth and decay
  - 🌵 **Cactus**: Slow growth, very resilient
  - 🎋 **Bamboo**: Fast growth, needs regular care
- **Auto-Decay**: Plant health decreases if unused for 4+ hours

### 📊 Statistics & Analytics
- Daily session tracking
- Weekly statistics
- Streak counter
- Total sessions and minutes
- Visual charts and graphs

### 🎨 User Experience
- **Dark Mode**: Full support for macOS dark mode
- **Onboarding Tour**: First-time user guide (replayable from settings)
- **Modern UI**: Clean, minimal design with SwiftUI
- **Compact Design**: Optimized for small screens
- **App Icon**: Beautiful custom icon for all sizes

## 📥 Installation

### Requirements
- macOS 13.0 (Ventura) or later
- **Universal Binary**: Works natively on both Intel and Apple Silicon (M1/M2/M3/M4) Macs

> **Note:** DeskPlant is currently macOS-only. iOS/iPadOS support is technically feasible but would require significant UI/UX redesign for touch interfaces and different app lifecycle. See [iOS/iPadOS Port](#iosipados-port) section for details.

### Option 1: Download DMG (Önerilen)
1. [Releases sayfasından](https://github.com/yourusername/DeskPlant/releases) en son `DeskPlant-X.X.X-Universal.dmg` dosyasını indirin
2. DMG dosyasını açın
3. `DeskPlant.app` dosyasını `Applications` klasörüne sürükleyin
4. Applications klasöründen uygulamayı açın (ilk açılışta sağ tıklayıp "Aç" seçin)
5. Bildirim izinlerini verin

### Option 2: Build from Source (Geliştirici)
```bash
# Repoyu klonlayın
git clone https://github.com/yourusername/DeskPlant.git
cd DeskPlant

# Universal Binary build edin (Intel + Apple Silicon)
./build.sh

# Uygulamayı çalıştırın
open build/DerivedData/Build/Products/Release/DeskPlant.app

# Opsiyonel: DMG oluşturun (dağıtım için)
./create-dmg.sh

# Opsiyonel: Applications'a kopyalayın
cp -r build/DerivedData/Build/Products/Release/DeskPlant.app /Applications/
```

> **🔐 Dağıtım için:** Detaylı build ve dağıtım talimatları için [DISTRIBUTION.md](DISTRIBUTION.md) dosyasına bakın. Universal Binary, code signing ve notarization konularını içerir.

## 🚀 Usage

### Getting Started
1. Launch DeskPlant - it appears in your menu bar as 🌱
2. **Left click** the icon to open the main interface
3. Select your plant type in Settings
4. Click "Start Focus" to begin your first Pomodoro session
5. Complete the 25-minute focus session to water your plant

### Understanding the Plant System

#### Health Mechanics
- **+10 Health**: Earned for each completed 25-minute work session
- **-5 Health**: Lost for every 4 hours of inactivity
- **Health Status**:
  - 80-100%: 🌟 Thriving
  - 60-79%: 💚 Healthy
  - 40-59%: 💛 Needs Care
  - 20-39%: 🟠 Wilting
  - 0-19%: 🔴 Critical

#### Leveling Up
- Your plant levels up every **5 completed sessions**
- Higher levels unlock visual improvements
- Track your progress in the Stats tab

### Pomodoro Workflow
1. **Work Session** (25 minutes): Focus on your task
2. **Short Break** (5 minutes): Rest and recharge
3. **Repeat** 4 times
4. **Long Break** (15 minutes): Take a longer rest

### Customization
- **Timer Settings**: Adjust work/break durations (15-60 min work, 3-15 min short break, 10-30 min long break)
- **Language**: Choose from 4 languages in Settings
- **Plant Type**: Switch between Bonsai, Cactus, or Bamboo
- **Launch at Login**: Automatically start DeskPlant when you log in
- **Onboarding**: Replay the tutorial anytime from Settings

## 🎮 Controls Reference

### Main Interface (Left Click)
- **Plant Tab**: View your plant and start/pause timer
- **Stats Tab**: Check your productivity statistics
- **Settings Tab**: Customize timer, language, and plant type

### Quick Menu (Right Click)
- **Start Focus / Pause / Resume / Stop**: Quick timer controls
- **Plant Status**: View health and level at a glance
- **Open DeskPlant**: Open main interface
- **Quit DeskPlant**: Close the app

### Keyboard Shortcuts
All shortcuts work when the menu is open:
- `⌘F` - Start Focus Session
- `⌘P` - Pause Current Session
- `⌘R` - Resume Paused Session
- `⌘S` - Stop Current Session
- `⌘O` - Open Main Interface
- `⌘Q` - Quit Application

## 🏗️ Architecture

### Technology Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI + AppKit
- **Architecture**: MVVM (Model-View-ViewModel)
- **Persistence**: UserDefaults
- **Notifications**: UNUserNotificationCenter
- **Localization**: .strings files with dynamic loading

### Project Structure
```
DeskPlant/
├── DeskPlantApp.swift           # App entry point
├── Controllers/
│   └── MenuBarController.swift  # Menu bar & popover management
├── Models/
│   ├── PomodoroTimer.swift      # Timer logic
│   ├── PlantState.swift         # Plant health & growth
│   └── PlantType.swift          # Plant type definitions
├── Views/
│   ├── PopoverView.swift        # Main UI (tabs)
│   ├── PlantAnimationView.swift # Plant visualization
│   ├── StatsView.swift          # Statistics charts
│   └── OnboardingView.swift     # First-time tutorial
├── Utils/
│   ├── DataManager.swift        # Data persistence
│   ├── NotificationManager.swift # System notifications
│   └── LocalizationManager.swift # Multi-language support
└── Resources/
    ├── Assets.xcassets/         # App icon & images
    └── Localization/            # Language files
        ├── en.lproj/
        ├── tr.lproj/
        ├── fr.lproj/
        └── de.lproj/
```

### Key Components
- **MenuBarController**: Manages status bar item, popover, and context menu
- **PomodoroTimer**: Handles timer logic, state machine, and session tracking
- **PlantState**: Manages plant health, level, and auto-decay system
- **LocalizationManager**: Provides dynamic language switching

## 🌍 Localization

DeskPlant supports 4 languages with full UI translation:

### Adding a New Language
1. Create new `.lproj` folder in `DeskPlant/Resources/Localization/`
2. Add `Localizable.strings` file with translations
3. Update `Language` enum in `LocalizationManager.swift`
4. Add language to Xcode project's `PBXVariantGroup`

### Translation Keys
All UI strings use localization keys like:
- `button.startFocus` → "Start Focus" / "Fokusa Başla" / etc.
- `plant.status.thriving` → "Thriving" / "Mükemmel" / etc.
- `settings.description` → App description in each language

## 🔧 Building & Development

### Prerequisites
- Xcode 15.0+
- macOS 13.0+ SDK
- Command Line Tools

### Quick Build (Universal Binary)
```bash
# Hem Intel hem de Apple Silicon için build
./build.sh
```

Bu otomatik olarak:
- ✅ Universal Binary oluşturur (x86_64 + arm64)
- ✅ Release konfigürasyonu kullanır
- ✅ Mimarileri doğrular

### DMG Oluşturma (Dağıtım Paketi)
```bash
# Önce build edin
./build.sh

# Sonra DMG oluşturun
./create-dmg.sh
```

DMG çıktısı: `dist/DeskPlant-1.0.0-Universal.dmg`

### Notarization (Apple Onayı - Opsiyonel)
```bash
# Apple Developer hesabı gerektirir
./notarize.sh dist/DeskPlant-1.0.0-Universal.dmg
```

### Manuel Build
```bash
# Universal Binary (Intel + Apple Silicon)
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

### Binary Doğrulama
```bash
# Desteklenen mimarileri kontrol et
lipo -info build/DerivedData/Build/Products/Release/DeskPlant.app/Contents/MacOS/DeskPlant

# Beklenen çıktı: "Architectures in the fat file: DeskPlant are: x86_64 arm64"
```

### Code Signing
Geliştirme build'leri için code signing devre dışı:
```bash
CODE_SIGN_IDENTITY="-" \
CODE_SIGN_STYLE="Manual"
```

Profesyonel dağıtım için:
1. Apple Developer Program'a üye olun ($99/yıl)
2. Developer ID Application sertifikası oluşturun
3. Xcode → Signing & Capabilities'de yapılandırın
4. Notarize script'i ile Apple onayı alın

Detaylı bilgi için: [DISTRIBUTION.md](DISTRIBUTION.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Guidelines
1. Follow Swift style guide
2. Maintain MVVM architecture
3. Add localization for new strings
4. Test on both Light and Dark modes
5. Ensure backward compatibility (macOS 13.0+)

### Localization Contributions
Native speakers are welcome to improve translations or add new languages!

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Created by **[ssilistre.dev](https://ssilistre.dev)**

## 🙏 Acknowledgments

- Pomodoro Technique® by Francesco Cirillo
- SF Symbols by Apple
- Plant icon inspiration from various open-source projects

## 📧 Support

For bugs, feature requests, or questions:
- Open an issue on GitHub
- Contact: ssilistre.dev

## 🗺️ Roadmap

### Planned Features
- [ ] iCloud sync across devices
- [ ] iOS/iPadOS version (see details below)
- [ ] Custom plant skins/themes
- [ ] Sound effects and ambient music
- [ ] Weekly/monthly reports export
- [ ] Integration with calendar apps
- [ ] Custom timer presets
- [ ] Widget support for macOS 14+ / iOS 17+
- [ ] Multiple plant gardens
- [ ] Apple Watch complication

### Known Issues
- Icon may not appear in Debug builds (use Release)
- First launch requires "Open" from context menu (unsigned app)

## 📱 iOS/iPadOS Port

### Current Status
DeskPlant is currently **macOS-only**. An iOS/iPadOS version is technically feasible but requires significant changes:

### Technical Feasibility ✅
The core functionality is platform-agnostic:
- ✅ SwiftUI views can be adapted for iOS
- ✅ Timer logic is platform-independent
- ✅ Plant system works on any platform
- ✅ Localization is ready
- ✅ Data models are compatible

### Required Changes for iOS/iPadOS 🔄

#### UI/UX Redesign (Major)
- **Menu Bar → Tab Bar**: Convert menu bar app to standard iOS navigation
- **Popover → Fullscreen**: Redesign compact popover for full-screen layouts
- **Context Menu → Gestures**: Replace right-click with long-press gestures
- **Keyboard Shortcuts → Touch**: Adapt controls for touch interface
- **App Icon**: Create additional icon sizes for iOS

#### Features to Add
- **Background Timer**: Implement background task handling for iOS
- **Notifications**: Adapt notification system for iOS permissions
- **Widget**: Create iOS Home Screen widget
- **iPad Split View**: Support for multitasking
- **Dynamic Island**: Integration for iPhone 14 Pro+

#### Features to Modify
- **Launch at Login → Auto-start**: Different implementation on iOS
- **Always-on Display**: Only available on certain iPhone models
- **Memory Management**: More aggressive cleanup for iOS

### Estimated Effort
- **Development Time**: 2-3 weeks
- **Testing**: 1 week across devices
- **App Store Submission**: 1 week review process

### Platform-Specific Considerations
- **App Store Guidelines**: Must follow iOS HIG (Human Interface Guidelines)
- **Subscription Model**: Consider iOS payment integration
- **TestFlight**: Beta testing distribution
- **Universal Binary**: Support iPhone, iPad, and Mac (Catalyst)

### Would You Like iOS Support?
If there's interest, we can:
1. Create a separate iOS/iPadOS target
2. Share core logic (Models, Utils)
3. Build iOS-specific UI (SwiftUI + UIKit hybrid)
4. Submit to App Store

**Vote for iOS support**: Open an issue labeled `platform: ios` to show interest!

## 📸 Screenshots

### Main Interface
Left click the menu bar icon to access:
- 🌱 Plant Tab: View and grow your plant
- 📊 Stats Tab: Track your productivity
- ⚙️ Settings Tab: Customize everything

### Context Menu
Right click for quick actions:
- Start/Pause/Resume timer
- View plant status
- Quick quit

### Multilingual
Switch languages instantly from Settings - all UI updates in real-time!

---

**Made with ❤️ and ☕ using the Pomodoro Technique**

*Stay focused, grow your plant, boost your productivity!* 🌱⏱️💪

---

# 🌱 DeskPlant (Türkçe)

> Pomodoro tekniği ile verimliliğinizi artırırken dijital bir bitki büyütün.

DeskPlant, kanıtlanmış Pomodoro tekniğini dijital bitki büyütme keyfi ile birleştiren bir macOS menü çubuğu uygulamasıdır. Odaklanın, mola verin ve çalışma seanslarınızı tamamladıkça bitkinin gelişmesini izleyin!

![DeskPlant Banner](plant.png)

## ✨ Özellikler

### 🎯 Temel Fonksiyonlar
- **Pomodoro Zamanlayıcı**: Klasik 25-5-15 dakikalık aralıklar (Çalışma-Kısa Mola-Uzun Mola)
- **Dijital Bitki Büyütme**: Fokus seanslarını tamamladıkça bitkinin büyür
- **Menü Çubuğu Entegrasyonu**: macOS menü çubuğundan her zaman erişilebilir
- **Akıllı Bildirimler**: Çalışma veya mola zamanı geldiğinde bildirim alın

### 🌍 Çok Dilli Destek
- 🇬🇧 İngilizce
- 🇹🇷 Türkçe
- 🇫🇷 Fransızca
- 🇩🇪 Almanca
- Dinamik dil değiştirme (yeniden başlatma gerektirmez)

### 🖱️ Sezgisel Kontroller
- **Sol Tık**: Ana arayüzü aç
- **Sağ Tık**: Hızlı işlemler menüsü
- **Klavye Kısayolları**:
  - `⌘F` - Fokusa Başla
  - `⌘P` - Duraklat
  - `⌘R` - Devam Et
  - `⌘S` - Durdur
  - `⌘O` - DeskPlant'i Aç
  - `⌘Q` - Çık

### 🌿 Bitki Sistemi
- **Sağlık Çubuğu**: Bitkinin sağlığını takip eder (0-100%)
- **Seviye Sistemi**: Her 5 tamamlanan seansta bitkin seviye atlar
- **Çoklu Bitki Türleri**:
  - 🌵 **Kaktüs**: En bağışlayıcı, yeni başlayanlar için ideal (⭐)
  - 🌿 **Monstera**: Dayanıklı tropikal bitki, iyi denge (⭐⭐)
  - 🎋 **Bambu**: Hızlı büyür, orta düzey bakım (⭐⭐)
  - 🌳 **Bonzai**: Sabırlı büyüme, özveri gerektirir (⭐⭐⭐)
  - 🌻 **Ayçiçeği**: Parlak ve neşeli, düzenli bakım ister (⭐⭐⭐⭐)
  - 🌸 **Sakura**: En zorlu, sadece ustalar için (⭐⭐⭐⭐⭐)
- **Otomatik Zayıflama**: 4+ saat kullanılmazsa bitki sağlığı azalır
- **Görsel Değişimler**: Bitki sağlığına göre emoji, eğilme, renk değişiklikleri

### 📊 İstatistikler ve Analizler
- Günlük seans takibi
- Haftalık istatistikler
- Seri sayacı
- Toplam seans ve dakikalar
- Görsel grafikler ve tablolar


 
## 🚀 Kullanım

### Başlarken
1. DeskPlant'i başlatın - menü çubuğunuzda 🌱 olarak görünür
2. Ana arayüzü açmak için ikona **sol tıklayın**
3. Ayarlar'dan bitki türünüzü seçin
4. İlk Pomodoro seansınızı başlatmak için "Fokusa Başla"ya tıklayın
5. Bitkini sulamak için 25 dakikalık fokus seansını tamamlayın

### Bitki Sistemini Anlamak

#### Sağlık Mekanikleri
- **+10 Sağlık**: Her tamamlanan 25 dakikalık çalışma seansı için kazanılır
- **-5 Sağlık**: Her 4 saatlik hareketsizlik için kaybedilir
- **Sağlık Durumu**:
  - 80-100%: 🌟 Mükemmel
  - 60-79%: 💚 Sağlıklı
  - 40-59%: 💛 Bakım İster
  - 20-39%: 🟠 Solmakta
  - 0-19%: 🔴 Kritik

#### Seviye Atlama
- Bitkinin her **5 tamamlanan seansta** seviye atlar
- Daha yüksek seviyeler görsel iyileştirmeler açar
- İlerlemeni Stats sekmesinden takip et

#### Görsel Değişimler
- **Sağlıklı (80-100%)**: 🌳 Canlı emoji, dik duruş, yeşil yapraklar
- **Normal (60-79%)**: 🌿 Standart görünüm
- **Bakım Gerektiren (40-59%)**: 🌾 Hafif eğilme, soluk renkler
- **Solmakta (20-39%)**: 🍂 Belirgin eğilme, sararmış yapraklar
- **Kritik (0-19%)**: 🥀 Çok eğik, kahverengi yapraklar, küçük boyut

### Pomodoro İş Akışı
1. **Çalışma Seansı** (25 dakika): Görevine odaklan
2. **Kısa Mola** (5 dakika): Dinlen ve enerji topla
3. **4 kez tekrarla**
4. **Uzun Mola** (15 dakika): Daha uzun bir dinlenme yap

### Özelleştirme
- **Zamanlayıcı Ayarları**: Çalışma/mola sürelerini ayarla (15-60 dk çalışma, 3-15 dk kısa mola, 10-30 dk uzun mola)
- **Dil**: Ayarlar'dan 4 dil arasından seç
- **Bitki Türü**: Kaktüs, Monstera, Bambu, Bonzai, Ayçiçeği veya Sakura arasında geçiş yap
- **Başlangıçta Çalıştır**: Giriş yaptığınızda DeskPlant'i otomatik başlat
- **Başlangıç Turu**: Öğreticiyi istediğin zaman Ayarlar'dan tekrar oynat

## 🎮 Kontrol Referansı

### Ana Arayüz (Sol Tık)
- **Bitki Sekmesi**: Bitkini gör ve zamanlayıcıyı başlat/duraklat
- **Stats Sekmesi**: Verimlilik istatistiklerini kontrol et
- **Ayarlar Sekmesi**: Her şeyi özelleştir

### Hızlı Menü (Sağ Tık)
- **Fokusa Başla / Duraklat / Devam Et / Durdur**: Hızlı zamanlayıcı kontrolleri
- **Bitki Durumu**: Sağlık ve seviyeyi bir bakışta gör
- **DeskPlant'i Aç**: Ana arayüzü aç
- **DeskPlant'ten Çık**: Uygulamayı kapat

### Klavye Kısayolları
Menü açıkken tüm kısayollar çalışır:
- `⌘F` - Fokus Seansı Başlat
- `⌘P` - Mevcut Seansı Duraklat
- `⌘R` - Duraklatılan Seansa Devam Et
- `⌘S` - Mevcut Seansı Durdur
- `⌘O` - Ana Arayüzü Aç
- `⌘Q` - Uygulamadan Çık

## 🏗️ Mimari

### Teknoloji Yığını
- **Dil**: Swift 5.9+
- **UI Framework**: SwiftUI + AppKit
- **Mimari**: MVVM (Model-View-ViewModel)
- **Kalıcılık**: UserDefaults
- **Bildirimler**: UNUserNotificationCenter
- **Yerelleştirme**: Dinamik yükleme ile .strings dosyaları

### Proje Yapısı
```
DeskPlant/
├── DeskPlantApp.swift           # Uygulama giriş noktası
├── Controllers/
│   └── MenuBarController.swift  # Menü çubuğu ve popover yönetimi
├── Models/
│   ├── PomodoroTimer.swift      # Zamanlayıcı mantığı
│   ├── PlantState.swift         # Bitki sağlığı ve büyümesi
│   └── PlantType.swift          # Bitki türü tanımları
├── Views/
│   ├── PopoverView.swift        # Ana UI (sekmeler)
│   ├── PlantAnimationView.swift # Bitki görselleştirme
│   ├── StatsView.swift          # İstatistik grafikleri
│   └── OnboardingView.swift     # İlk kullanım öğreticisi
├── Utils/
│   ├── DataManager.swift        # Veri kalıcılığı
│   ├── NotificationManager.swift # Sistem bildirimleri
│   ├── LocalizationManager.swift # Çok dilli destek
│   └── LaunchAtLogin.swift      # Başlangıçta çalıştır
└── Resources/
    ├── Assets.xcassets/         # Uygulama ikonu ve görseller
    └── Localization/            # Dil dosyaları
        ├── en.lproj/
        ├── tr.lproj/
        ├── fr.lproj/
        └── de.lproj/
```

### Anahtar Bileşenler
- **MenuBarController**: Durum çubuğu öğesini, popover'ı ve bağlam menüsünü yönetir
- **PomodoroTimer**: Zamanlayıcı mantığı, durum makinesi ve seans takibini işler
- **PlantState**: Bitki sağlığı, seviye ve otomatik zayıflama sistemini yönetir
- **LocalizationManager**: Dinamik dil değiştirme sağlar
- **LaunchAtLogin**: macOS ServiceManagement ile başlangıçta çalıştır özelliği

## 🌍 Yerelleştirme

DeskPlant, tam UI çevirisi ile 4 dili destekler:

### Yeni Dil Ekleme
1. `DeskPlant/Resources/Localization/` içinde yeni `.lproj` klasörü oluştur
2. Çeviriler ile `Localizable.strings` dosyası ekle
3. `LocalizationManager.swift` içindeki `Language` enum'unu güncelle
4. Dili Xcode projesinin `PBXVariantGroup`'una ekle

### Çeviri Anahtarları
Tüm UI metinleri şu şekilde yerelleştirme anahtarları kullanır:
- `button.startFocus` → "Start Focus" / "Fokusa Başla" / vb.
- `plant.status.thriving` → "Thriving" / "Mükemmel" / vb.
- `settings.description` → Her dilde uygulama açıklaması

## 🔧 Derleme ve Geliştirme

### Ön Gereksinimler
- Xcode 15.0+
- macOS 13.0+ SDK
- Command Line Tools

- **Otomatik Tetikleme**: `v*` etiketlerinde
- **Evrensel Derleme**: Intel + Apple Silicon
- **Çoklu Format**: DMG ve ZIP
- **Güvenlik**: SHA-256 checksum'lar
- **Sürüm Notları**: Otomatik oluşturulur

## 🤝 Katkıda Bulunma

Katkılar memnuniyetle karşılanır! Lütfen Pull Request göndermekten çekinmeyin.

### Geliştirme Kuralları
1. Swift stil rehberine uyun
2. MVVM mimarisini koruyun
3. Yeni metinler için yerelleştirme ekleyin
4. Hem Açık hem de Karanlık modlarda test edin
5. Geriye dönük uyumluluğu sağlayın (macOS 13.0+)

### Yerelleştirme Katkıları
Ana dili olan kişiler çevirileri geliştirmek veya yeni diller eklemek için memnuniyetle karşılanır!

## 📝 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır - detaylar için LICENSE dosyasına bakın.

## 👨‍💻 Yazar

**[ssilistre.dev](https://ssilistre.dev)** tarafından oluşturuldu

## 🙏 Teşekkürler

- Francesco Cirillo'nun Pomodoro Tekniği®
- Apple'ın SF Symbols
- Çeşitli açık kaynak projelerden bitki ikonu ilhamı

## 📧 Destek

Hatalar, özellik istekleri veya sorular için:
- GitHub'da bir issue açın
- İletişim: ssilistre.dev

## 🗺️ Yol Haritası

### Planlanan Özellikler
- [ ] Cihazlar arası iCloud senkronizasyonu
- [ ] iOS/iPadOS versiyonu (detaylar aşağıda)
- [ ] Özel bitki kaplamaları/temaları
- [ ] Ses efektleri ve ortam müziği
- [ ] Haftalık/aylık rapor dışa aktarma
- [ ] Takvim uygulamaları ile entegrasyon
- [ ] Özel zamanlayıcı ön ayarları
- [ ] macOS 14+ / iOS 17+ için Widget desteği
- [ ] Çoklu bitki bahçeleri
- [ ] Apple Watch komplikasyonu

### Bilinen Sorunlar
- Debug derlemelerinde ikon görünmeyebilir (Release kullanın)
- İlk açılış bağlam menüsünden "Aç" gerektirir (imzasız uygulama)

## 📱 iOS/iPadOS Portu

### Mevcut Durum
DeskPlant şu anda **sadece macOS** içindir. 

### Teknik Fizibilite ✅
Temel işlevsellik platform bağımsızdır:
- ✅ SwiftUI görünümleri iOS için uyarlanabilir
- ✅ Zamanlayıcı mantığı platform bağımsız
- ✅ Bitki sistemi her platformda çalışır
- ✅ Yerelleştirme hazır
- ✅ Veri modelleri uyumlu

 

### Ana Arayüz
Menü çubuğu ikonuna sol tıklayarak erişin:
- 🌱 Bitki Sekmesi: Bitkini gör ve büyüt
- 📊 Stats Sekmesi: Verimliliğini takip et
- ⚙️ Ayarlar Sekmesi: Her şeyi özelleştir

 
Hızlı işlemler için sağ tıklayın:
- Zamanlayıcıyı Başlat/Duraklat/Devam Ettir
- Bitki durumunu görüntüle
- Hızlı çıkış

### Çok Dilli
Ayarlar'dan anında dil değiştirin - tüm UI gerçek zamanlı güncellenir!

---

**❤️ ve ☕ ile Pomodoro Tekniği kullanılarak yapıldı**

*Odaklan, bitkini büyüt, verimliliğini artır!* 🌱⏱️💪

# 🌱 DeskPlant

[![Build Status](https://img.shields.io/github/actions/workflow/status/unkownpr/DeskPlanet-/release.yml?branch=master)](https://github.com/unkownpr/DeskPlanet-/actions)
[![Release](https://img.shields.io/github/v/release/unkownpr/DeskPlanet-)](https://github.com/unkownpr/DeskPlanet-/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%2013.0%2B-blue)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

> **[🇬🇧 English](README.md)** | **[🇹🇷 Türkçe](#türkçe)**

![DeskPlant Banner](plant.png)

---

## Türkçe

**DeskPlant**, kanıtlanmış Pomodoro tekniğini dijital bitki büyütme keyfi ile birleştiren bir macOS menü çubuğu uygulamasıdır. Odaklanın, mola verin ve çalışma seanslarınızı tamamladıkça bitkinin gelişmesini izleyin!

### 💎 Freemium Model

DeskPlant **ücretsiz** olarak temel özelliklerle kullanılabilir. Premium özelliklerin kilidini **ömür boyu lisans** ile açın!

**[🛒 Ömür Boyu Lisans Satın Al - ₺299.99](https://eshop.ssilistre.dev/buy/5399c73c-21b1-40df-b841-f823d5a20a98)**

**Ücretsiz Özellikler:**
- ✅ Temel Pomodoro Zamanlayıcı (25-5-15)
- ✅ Tek Bitki Türü
- ✅ Temel İstatistikler

**Premium Özellikler (Ömür Boyu Lisans):**
- 🌟 Tüm Bitki Türleri (Bonzai, Kaktüs, Bambu ve daha fazlası)
- 🌟 Gelişmiş İstatistikler ve Analizler
- 🌟 Özel Zamanlayıcı Ayarları
- 🌟 Sınırsız Bitki Büyümesi
- 🌟 Öncelikli Destek

### ✨ Temel Özellikler

- **🎯 Pomodoro Zamanlayıcı**: Klasik 25-5-15 dakikalık aralıklar
- **🌱 Dijital Bitki Büyütme**: Tamamlanan seanslarla bitki büyür
- **🌍 Çok Dilli**: İngilizce, Türkçe, Fransızca, Almanca
- **📊 İstatistikler**: Detaylı analizlerle verimliliği takip edin
- **⌨️ Klavye Kısayolları**: Kısayollarla hızlı erişim (⌘F, ⌘P, ⌘R, ⌘S)
- **🌿 Çoklu Bitki Türleri**: Bonzai, Kaktüs, Bambu - benzersiz büyüme paternleri
- **🔔 Akıllı Bildirimler**: Çalışma ve molalar için zamanında hatırlatmalar
- **🌙 Karanlık Mod**: Tam macOS karanlık mod desteği

### 📥 Kurulum

#### Gereksinimler
- macOS 13.0 (Ventura) veya üzeri
- Universal Binary (Intel + Apple Silicon)

#### İndirme ve Kurulum
1. [Releases](https://github.com/unkownpr/DeskPlanet-/releases) sayfasından en son DMG dosyasını indirin
2. DMG dosyasını açın
3. `DeskPlant.app` dosyasını Applications klasörüne sürükleyin
4. **Önemli**: İlk açılış için özel adımlar gereklidir (aşağıya bakın ⚠️)

#### ⚠️ İlk Açılış (macOS Güvenliği)

Uygulama Apple tarafından notarize edilmediği için macOS "hasarlı" uyarısı gösterecektir. Bu normaldir! Şu adımları izleyin:

**Yöntem 1 - Terminal (Önerilen):**
```bash
xattr -cr /Applications/DeskPlant.app
```
Sonra uygulamayı normal şekilde açın.

**Yöntem 2 - Sağ tık:**
1. Applications klasöründe `DeskPlant.app`'e sağ tıklayın
2. "Aç" seçeneğini seçin
3. Güvenlik diyaloğunda "Aç"a tıklayın

**Yöntem 3 - Sistem Ayarları:**
1. Uygulamayı açmayı deneyin (hata alacaksınız)
2. Sistem Ayarları → Gizlilik ve Güvenlik'e gidin
3. DeskPlant uyarısının yanındaki "Yine de Aç"a tıklayın
4. Onaylamak için "Aç"a tıklayın

**Bunu sadece bir kez yapmanız yeterli!** İlk açılıştan sonra uygulama normal şekilde açılacaktır.

### 🚀 Hızlı Başlangıç

1. Menü çubuğunuzdaki 🌱 ikonuna tıklayın
2. Ayarlar'dan bitki türünüzü seçin
3. 25 dakikalık bir seans başlatmak için "Fokusa Başla"ya tıklayın
4. Bitkini büyütmek için seansları tamamlayın!

### 🎮 Kontroller

- **Sol Tık**: Ana arayüzü aç
- **Sağ Tık**: Hızlı işlemler menüsü
- **Klavye Kısayolları**:
  - `⌘F` - Fokusa Başla
  - `⌘P` - Duraklat
  - `⌘R` - Devam Et
  - `⌘S` - Durdur

### 🔧 Kaynak Koddan Derleme

Detaylı derleme talimatları için [BUILD.md](BUILD.md) dosyasına bakın.

```bash
# Hızlı derleme
./build.sh

# DMG oluştur
./create-dmg.sh
```

### 📝 Lisans

MIT Lisansı - detaylar için [LICENSE](LICENSE) dosyasına bakın.

### 👨‍💻 Yazar

**[ssilistre.dev](https://ssilistre.dev)** tarafından oluşturuldu

### 📧 Destek

- [Issue açın](https://github.com/unkownpr/DeskPlanet-/issues)
- İletişim: ssilistre.dev

---

**❤️ ile Pomodoro Tekniği kullanılarak yapıldı**

*Odaklan, bitkini büyüt, verimliliğini artır!* 🌱⏱️


# BLM4587 — Bandırma Cepte (Flutter)

> **BLM4587 iOS ile Mobil Uygulama Geliştirme I** — 2026–2027 Güz Yarıyılı  
> Öğrenci: Zeynep Lal Kaşıkçı · 22290070 · [@lalkasikci](https://github.com/lalkasikci)
> 1. Hafta Videosu: https://drive.google.com/file/d/10T9040N_DKEMLlaNFFBkiemWlbgJOszE/view?usp=sharing
> 2. Hafta Videosu: https://drive.google.com/file/d/1xipZLxDvKNv3sCHkfKxVSjfIEht3GKSu/view?usp=sharing
> 3. Hafta Videosu: https://drive.google.com/file/d/17lTkUT_YM4BxIJBBeLpSFKVmtALNAvx0/view?usp=sharing
Bandırma sakinlerinin, öğrencilerin ve ziyaretçilerin **yerel bilgilere tek bir uygulamadan** ulaşmasını sağlayan Android mobil uygulaması.

---

## Proje Yapısı

```
BLM4587-Bandirma-Cepte/
└── mobile/                  # Flutter uygulaması (bu klasör)
    └── lib/
        ├── main.dart          # Giriş noktası
        ├── app_router.dart    # go_router yönlendirme
        ├── models/            # Dart veri modelleri
        ├── services/          # HTTP + Auth servis katmanı
        └── screens/           # Ekranlar
```

> **Backend:** ASP.NET Core Web API + PostgreSQL (`BandirmaCepteDb`)  

---

## Haftalık Gelişim

| Hafta | Tamamlanan | Dosyalar |
|-------|-----------|---------|
| **1–2** | Flutter başlangıç yapısı, yönlendirme, HTTP servis katmanı, JWT giriş | `main.dart`, `app_router.dart`, `api_service.dart`, `auth_service.dart` |
| **3** | Alt gezinme, ana sayfa kısayolları, API'den haber listesi ve detayları, hat ve sefer bilgileri | `home_screen.dart`, `news_screen.dart`, `news_detail_screen.dart`, `bus_lines_screen.dart` |

---

## Kurulum & Çalıştırma

### Ön Koşullar
- Flutter 3.29+ (`flutter --version`)
- Android emülatörü veya fiziksel Android cihaz

### Adımlar

```bash
cd mobile
flutter pub get
flutter run
```

> **Emülatörde** API'ye `10.0.2.2:5000` üzerinden bağlanılır (Android'de localhost = 10.0.2.2).  
> **Fiziksel cihazda** `lib/services/api_service.dart` içindeki `_baseUrl`'i bilgisayarın LAN IP'si ile değiştir.
> Alternatif olarak API adresi derleme sırasında `--dart-define=API_BASE_URL=http://<adres>:<port>` ile verilebilir.


## Kullanılan Paketler

| Paket | Amaç |
|-------|------|
| `http` | REST API istekleri |
| `flutter_secure_storage` | JWT token güvenli saklama |
| `go_router` | Sayfa yönlendirme |
| `intl` | Türkçe tarih formatı |

---

## Bağlantılar

- **GitHub:** https://github.com/lalkasikci/BLM4587-Bandirma-Cepte
- **Google Drive:** https://drive.google.com/drive/folders/1-PFSvzjrx0Jr2y5skh7MIzS4KDxCvjBr

# BLM4587 — Bandırma Cepte (Flutter)

> **BLM4587 iOS ile Mobil Uygulama Geliştirme I** — 2026–2027 Güz Yarıyılı  
> Öğrenci: Zeynep Lal Kaşıkçı · 22290070 · [@lalkasikci](https://github.com/lalkasikci)

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

> **Backend (blm4581):** ASP.NET Core Web API + PostgreSQL (`BandirmaCepteDb`)  
> Bu Flutter projesi, blm4581 API'sini **değiştirmeden** kullanır.

---

## Haftalık Gelişim

| Hafta | Tamamlanan | Dosyalar |
|-------|-----------|---------|
| **1** | Ortam kurulumu, ana sayfa iskeleti, go_router, README | `main.dart`, `app_router.dart`, `home_screen.dart`, `placeholder_screen.dart` |
| **2** | HTTP servis katmanı, Dart modelleri, JWT giriş ekranı, Haber + Otobüs ekranları | `api_service.dart`, `auth_service.dart`, `news.dart`, `bus_line.dart`, `auth_response.dart`, `login_screen.dart`, `news_screen.dart`, `bus_lines_screen.dart` |
| 3–9 | (İlerleyen haftalarda) | — |

---

## Kurulum & Çalıştırma

### Ön Koşullar
- Flutter 3.29+ (`flutter --version`)
- Android emülatörü veya fiziksel Android cihaz
- blm4581 API'sinin çalışır durumda olması: `dotnet run` → `http://localhost:5000`

### Adımlar

```bash
cd mobile
flutter pub get
flutter run
```

> **Emülatörde** API'ye `10.0.2.2:5000` üzerinden bağlanılır (Android'de localhost = 10.0.2.2).  
> **Fiziksel cihazda** `lib/services/api_service.dart` içindeki `_baseUrl`'i bilgisayarın LAN IP'si ile değiştir.

### Varsayılan Kullanıcılar (SeedData)

| Kullanıcı | Şifre | Rol |
|-----------|-------|-----|
| `admin` | `Admin123!` | Admin |
| `user` | `User123!` | User |

---

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

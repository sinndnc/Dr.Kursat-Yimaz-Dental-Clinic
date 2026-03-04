# 🦷 DentCare — Firebase Entegrasyonlu SwiftUI Uygulaması

## 📁 Dosya Yapısı

| Dosya | Açıklama |
|-------|----------|
| `DentCareApp.swift` | Firebase init, AppDelegate (FCM), RootView |
| `AppState.swift` | Merkezi state — realtime listeners, CRUD yönetimi |
| `AuthService.swift` | Firebase Auth (giriş, kayıt, şifre sıfırlama) |
| `FirestoreService.swift` | Tüm Firestore CRUD + realtime listener'lar |
| `FirebaseSetup.swift` | Kurulum adımları + Security Rules + veri şeması |
| `AuthFlowView.swift` | Login / Register / ForgotPassword ekranları |
| `Models.swift` | Codable modeller (@DocumentID ile) |
| `ContentView.swift` | MainTabView (Firebase'e bağlı) |
| `HomeView.swift` | Dashboard (Firebase verisiyle) |
| `AppointmentsView.swift` | Randevu CRUD (Firestore'a yazar/okur) |
| `ServicesAndDoctorsView.swift` | Hizmetler & Doktorlar (Firestore'dan) |
| `ProfileView.swift` | Profil güncelleme + bildirimler (realtime) |

## 🚀 Kurulum (5 adım)

### 1. Firebase Projesi Oluştur
- https://console.firebase.google.com → Add project → "DentCare"
- iOS uygulaması ekle (Bundle ID: com.sirketadi.DentCare)
- `GoogleService-Info.plist` indir → Xcode'a ekle

### 2. Swift Package Manager
Xcode → File → Add Package Dependencies:
```
https://github.com/firebase/firebase-ios-sdk
```
Seç: FirebaseAuth, FirebaseFirestore, FirebaseStorage, FirebaseMessaging

### 3. Firebase Console'da Servisleri Aç
- Authentication → Email/Password ✅
- Firestore Database → Production mode ✅
- Storage ✅
- Cloud Messaging ✅

### 4. Firestore Security Rules
`FirebaseSetup.swift` içindeki kuralları kopyala → Firestore Rules'a yapıştır

### 5. Xcode'da Çalıştır
iOS 16+ simulator veya gerçek cihaz

---

## ✨ Firebase Entegrasyon Özellikleri

### 🔐 Authentication
- E-posta/şifre ile kayıt & giriş
- Şifre sıfırlama (e-posta ile)
- Otomatik oturum yönetimi
- Türkçe hata mesajları

### 🔥 Firestore Realtime
- Randevular anlık senkronize (addSnapshotListener)
- Doktor listesi canlı güncelleme
- Bildirimler realtime
- Profil değişiklikleri anında yansır

### 📱 Cloud Messaging (FCM)
- Push bildirim altyapısı hazır
- FCM token Firestore'a kaydedilir
- Randevu hatırlatıcıları gönderilebilir

### 🗄️ Firestore Koleksiyonlar
```
/users/{uid}          → Kullanıcı profili
/appointments/{id}    → Randevular (userId ile filtrelenir)
/doctors/{id}         → Doktor listesi (admin yazar)
/services/{id}        → Hizmetler (admin yazar)
/notifications/{id}   → Bildirimler (userId ile filtrelenir)
```

### 🌱 Seed Verisi
İlk açılışta `FirestoreService.seedDoctorsIfNeeded()` çağrılır;
doctors ve services koleksiyonlarına örnek veri eklenir.

## 🎨 Ekranlar
- **Onboarding** — 3 sayfalı animasyonlu giriş (ilk açılış)
- **Login / Register / ForgotPassword** — Firebase Auth
- **Home** — Dashboard, sağlık skoru, ipuçları
- **Appointments** — Firestore CRUD, 4 adımlı yeni randevu
- **Services** — Firestore'dan servis listesi
- **Doctors** — Realtime doktor listesi, filtreleme
- **Profile** — Profil güncelleme, bildirim merkezi, logout

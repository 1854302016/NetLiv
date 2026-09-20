# NetLiv Mobile & TV OTT App 📱📺

A state-of-the-art Flutter OTT Streaming, Shorts & Audition Application connected with the NetLiv Laravel Backend.

---

## 🌟 Feature Coverage Matrix

| Feature Module | Status | Description |
| :--- | :---: | :--- |
| **Netflix-Grade Landing Screen** | ✅ Covered | Dynamic ₹49 hero pricing, trust badges, FAQ accordion & smart auto-login |
| **Seamless In-App Mobile Login** | ✅ Covered | 6-digit OTP verification with instant state persistence & Sanctum auth |
| **Full Video Player (HLS & MP4)**| ✅ Covered | Custom controls, quality selector, 10s seek, double-tap zoom & auto-resume |
| **Shorts / Reels Feed** | ✅ Covered | Vertical TikTok-style infinite scrolling video shorts with double-tap like |
| **Auditions Talent Hub** | ✅ Covered | In-modal OTP login, ₹199 Razorpay paywall, video upload & status tracker |
| **VIP Subscription Paywall** | ✅ Covered | ₹49 All-Access plan with Razorpay UPI, Cards, NetBanking & Promo Code input |
| **Continue Watching Row** | ✅ Covered | Resumes playback from exact second offset across all devices |
| **Live TV Channels** | ✅ Covered | 24x7 HLS live streaming channels playback |
| **Multi-Profile & Kids Safe Mode**| ✅ Covered | Avatar selector, Kids mode toggle hiding mature 18+ content |
| **Push Notifications (OneSignal)**| ✅ Covered | In-app alerts + background notifications for shortlist announcements |
| **DRM / Offline Encrypted Download**| ⏳ Roadmap | AES-128 secure offline storage playback with encrypted chunks |
| **Picture-in-Picture (PiP) Mode** | ⏳ Roadmap | Background mini-floating player while browsing other apps |

---

## 🚀 Running the Flutter App

```bash
flutter pub get
flutter run
```

### Production APK Build:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔗 Backend Connection
* **Live API Base URL**: `https://netliveplus.com/api`
* **Admin Dashboard**: `https://netliveplus.com/admin`

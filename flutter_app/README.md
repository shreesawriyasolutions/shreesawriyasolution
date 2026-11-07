# Shree Sawriya Shop App (Flutter)

Website ke Shop App (`app.html`) ka naya Flutter version: naya gold/black design, wahi Supabase data aur wahi login.

| Section | Kya hota hai |
|---|---|
| Home | Aaj ki sale, chalu repairs, pickup ready, stock alert, quick buttons |
| Status | Repair banao, status badlo, WhatsApp par status bhejo, history |
| Sales | Sale entry (stock se parts), 7 din ka chart, staff-wise, CSV share |
| Bills | Photo/PDF upload (camera, gallery, PDF), register, CSV share |
| Stock | Add, jodo/ghatao, kam/khatam alert, history |
| Staff | Naya staff account, role, sales dekhne ki permission (sirf Admin) |

Admin / Staff permissions website jaisi hi hain (Supabase row-level security wahi hai).

## APK kaise milega

Har push par GitHub Actions (`.github/workflows/flutter-app.yml`) app ko check karta hai aur APK banata hai:
GitHub → Actions → **Flutter Shop App** → latest run → **sss-shop-apk** download karo → phone par install.

> Abhi APK Flutter ki debug key se sign hota hai: phone par seedha install ho jayega, lekin Play Store ke liye apni release key lagani padegi.

## Apne computer par chalana

```bash
cd flutter_app
flutter pub get
flutter run                       # asli data (login chahiye)
flutter run --dart-define=DEMO=true   # nakli data, bina login (design dekhne ke liye)
flutter test
```

`android/` aur `web/` folder pehli CI run me `flutter create` se bane hain; `tool/patch_platforms.py` unme internet permission, app naam aur links (WhatsApp, call) jodta hai.

## Code ka dhaancha

```
lib/
  core/        config, theme (AppColors, AppTheme), models, data (Supabase + Demo repository),
               providers (Riverpod), routing (GoRouter + shell), widgets (cards, sheets, toast)
  features/    auth, home, repairs, sales, bills, stock, staff
test/          models, providers (demo + mock repo), widgets
```

Riverpod + Hooks, GoRouter, Supabase client. Code generation (Freezed/Retrofit/riverpod_generator) jaan-boojh kar nahi lagaya: backend Supabase hai to Retrofit ki zaroorat nahi, aur bina build_runner ke app seedha build hota hai.

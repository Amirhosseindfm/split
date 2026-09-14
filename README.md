# هم‌حساب (HamHesab)

اپلیکیشن اندروید مدیریت و تقسیم هزینه‌های گروهی (مشابه Splitwise)، مخصوص کاربران فارسی‌زبان.
ساخته‌شده با **Flutter + Clean Architecture + Riverpod**.

> ⚠️ این ریپازیتوری در مرحله **اسکلت معماری (Architecture Skeleton)** است.
> هسته‌ی منطق مالی (Balance Engine, Debt Simplification, Split Calculator) کامل، تست‌شده،
> و production-ready است. لایه‌ی UI/Repository برای بسیاری از Featureها فعلاً placeholder است
> (به‌صورت `TODO` در کد مشخص شده) و باید طبق روش گفته‌شده (`Development Process`) مرحله‌به‌مرحله تکمیل شود.

## چرا اینجوریه؟

طبق قانونی که در پرامپت اصلی مشخص شده («همه چیز را یک‌باره تولید نکن؛ مرحله‌ای بساز»)،
ابتدا معماری + هسته‌ی بیزینس‌لاجیک (که پرریسک‌ترین بخش برنامه‌های مالی است) ساخته و تست شده،
و بقیه‌ی Featureها به‌عنوان اسکلت آماده‌ی توسعه‌ی تدریجی گذاشته شده‌اند.

## Setup

```bash
flutter --version   # حداقل 3.19، پیشنهادی 3.24+
flutter pub get
```

اگر بعداً از Drift/Freezed/JSON codegen استفاده کردید:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Run

```bash
flutter devices          # لیست دستگاه/شبیه‌ساز موجود
flutter run
```

## Build

```bash
# APK دیباگ (برای تست سریع)
flutter build apk --debug

# APK ریلیز
flutter build apk --release

# App Bundle برای انتشار در Google Play
flutter build appbundle --release
```

خروجی APK در مسیر: `build/app/outputs/flutter-apk/`

## اجرای خودکار روی GitHub (CI)

با هر `push` یا `pull_request` به شاخه‌ی `main`، ورک‌فلو `.github/workflows/flutter-ci.yml`
به‌صورت خودکار:

1. `flutter analyze` اجرا می‌کند
2. تمام تست‌های Unit/Widget را اجرا می‌کند (`flutter test --coverage`)
3. یک APK دیباگ می‌سازد و به‌عنوان Artifact قابل دانلود در تب Actions قرار می‌دهد

برای دیدن نتیجه: بعد از push کردن این ریپازیتوری به گیت‌هاب، به تب **Actions** بروید.

## Architecture

**Clean Architecture + Feature-based**، هر Feature سه لایه دارد:

```
lib/
 ├─ core/                     منطق و زیرساخت مشترک
 │   ├─ money/                Money value object (int-only, بدون double)
 │   ├─ domain_services/      BalanceEngine, DebtSimplifier, SplitCalculator (pure, تست‌شده)
 │   ├─ theme/                Design System مرکزی (رنگ، تایپوگرافی، اسپیسینگ)
 │   ├─ error/                Failure classes + پیام‌های فارسی
 │   ├─ routing/              go_router config
 │   └─ database/             (جای Drift schema - در حال تکمیل)
 │
 ├─ features/
 │   ├─ auth/                 ورود با موبایل + OTP (data/domain/presentation)
 │   ├─ groups/                گروه‌ها
 │   ├─ expenses/              ثبت هزینه + Split
 │   ├─ balances/              محاسبه و نمایش بدهی/طلب
 │   ├─ settlements/           تسویه‌حساب
 │   ├─ profile/               پروفایل کاربر
 │   └─ onboarding/            آموزش اولیه
 │
 └─ shared/
     └─ widgets/               کامپوننت‌های مشترک (Loading/Empty/Error state)
```

قوانین وابستگی:
- `presentation` فقط به `domain` وابسته است.
- `domain` هیچ وابستگی خارجی ندارد (pure Dart).
- منطق مالی **فقط و فقط** در `core/domain_services` قرار دارد؛ UI و Database هرگز
  خودشان balance محاسبه نمی‌کنند (No Duplicate Business Logic).

## Database

فعلاً Repositoryها با پیاده‌سازی **In-Memory** جایگزین شده‌اند (`InMemoryExpensesRepository`,
`InMemorySettlementsRepository`) تا اسکلت برنامه قابل اجرا و تست باشد.

قدم بعدی طبق پلن: اضافه‌کردن `Drift` schema واقعی در `core/database/` و پیاده‌سازی
`DriftExpensesRepository` / `DriftSettlementsRepository` که همان interfaceهای `domain/` را
پیاده‌سازی می‌کنند — بدون نیاز به تغییر در presentation یا domain services.

جدول‌های پیشنهادی: `users`, `groups`, `group_members`, `expenses`, `expense_payers`,
`expense_shares`, `settlements`, `sync_log` (برای Offline-First).

## Environment Variables

فعلاً بدون نیاز به Environment Variable (MVP کاملاً local/offline است).
وقتی Backend/Firebase اضافه شود، یک فایل `.env` (با `flutter_dotenv`) یا
`--dart-define` برای کلیدهای API اضافه خواهد شد؛ نمونه در `README` وقت آن به‌روزرسانی می‌شود.

## Testing

```bash
flutter test                     # همه‌ی Unit + Widget testها
flutter test --coverage          # با گزارش پوشش
flutter test test/unit/          # فقط تست‌های Unit
```

تست‌های موجود:
- `test/unit/balance_engine_test.dart` — شامل سناریوی اصلی سند (Ali/Reza/Mohammad، 900,000 تومان)
- `test/unit/debt_simplifier_test.dart` — شامل مثال زنجیره A→B→C
- `test/unit/split_calculator_test.dart` — هر 4 روش تقسیم (Equal/Exact/Percentage/Shares) + Validation
- `test/widget/app_smoke_test.dart` — بوت شدن اپ و مسیر Onboarding → Login

Integration test کامل (User A → Create Group → ... → Verify balance) در مرحله‌ی بعدی
پس از تکمیل Repositoryهای واقعی اضافه می‌شود.

## نقشه‌ی راه (طبق MVP Roadmap)

- [x] Project setup + Design System
- [x] Architecture skeleton + Routing + DI
- [x] Core Business Logic (Balance Engine, Debt Simplification, Split Calculator) + تست
- [ ] Local Database (Drift) کامل
- [ ] Authentication واقعی (OTP)
- [ ] Groups (Create/Add Member/QR)
- [ ] Expenses (فرم کامل + اتصال به Repository)
- [ ] Settlements + Group Dashboard واقعی
- [ ] Search, Statistics
- [ ] Integration tests کامل
- [ ] Polish: RTL edge cases, Dark mode, بررسی نهایی

## لایسنس

خصوصی / داخلی — برای انتشار عمومی لایسنس مناسب اضافه کنید.

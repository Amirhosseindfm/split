# هم‌حساب (HamHesab)

اپلیکیشن اندروید مدیریت و تقسیم هزینه‌های گروهی (مشابه Splitwise)، مخصوص کاربران فارسی‌زبان.
ساخته‌شده با **Flutter + Clean Architecture + Riverpod + Drift**.

## وضعیت فعلی

MVP کامل طبق بخش 50 سند پیاده‌سازی شده و روی دیتابیس محلی واقعی (Drift/SQLite) کار می‌کند:

- ✅ Authentication (ساده، بدون Backend OTP واقعی - جزئیات پایین)
- ✅ Profile (نمایش نام/شماره، خروج از حساب)
- ✅ Create Group / Add Members
- ✅ Add Expense با هر ۴ روش تقسیم (Equal / Exact / Percentage / Shares)
- ✅ Balance Calculation + Debt Simplification (Greedy Max-Min)
- ✅ Settlement
- ✅ Expense History (Timeline با برچسب امروز/دیروز/تاریخ شمسی)
- ✅ Group Dashboard (وضعیت من + چه کسی به چه کسی بدهکار است)
- ✅ Local Database (Drift/SQLite)
- ✅ RTL کامل + اعداد و تاریخ فارسی
- ✅ Statistics پایه (مجموع + بر اساس دسته‌بندی)
- ✅ Unit + Integration Tests روی هسته‌ی مالی

### آنچه هنوز placeholder/ساده‌سازی‌شده است (شفاف اعلام می‌شود، نه پنهان)

| بخش سند | وضعیت فعلی |
|---|---|
| OTP واقعی (بخش 7) | ورود با نام+موبایل بدون کد تأیید واقعی؛ معماری برای جایگزینی با OTP/Backend آماده است (`AuthRepository`) |
| Google/Apple Login | اضافه نشده (Future Feature طبق خود سند) |
| QR Code / لینک دعوت (بخش 10) | فقط route دیپ‌لینک `/invite/:code` آماده است؛ UI کامل ندارد |
| Receipt عکس فاکتور (بخش 46) | ستون `receiptPath` در دیتابیس هست؛ UI دوربین/گالری اضافه نشده |
| Search (بخش 21) | اضافه نشده |
| Offline Sync واقعی با Backend (بخش 23-25) | جدول `sync_log` برای این منظور در دیتابیس هست؛ اپ کاملاً local-first است اما به Backend وصل نیست (طبق MVP Scope، Backend اختیاری است) |
| Notifications واقعی (بخش 22) | اضافه نشده (Future Feature طبق خود سند) |
| Error Handling مرکزی (بخش 37) | کلاس `Failure`/`mapExceptionToFailure` در `core/error/failure.dart` نوشته شده اما هنوز در همه‌ی call siteها wire نشده؛ صفحات فعلاً پیام خطای فارسی مستقیم نمایش می‌دهند |
| چند Payer در UI (بخش 58) | Domain/Database از چند payer پشتیبانی می‌کند؛ فرم Add Expense فعلاً فقط یک payer در UI می‌گیرد |
| ویرایش/حذف Expense در UI | متد `softDeleteExpense` در Repository هست؛ دکمه‌ی ویرایش/حذف در UI اضافه نشده |
| AI Features، OCR، Bank Integration و... | طبق خود سند (بخش 51-52) Future Feature هستند و در MVP اجباری نبودند |

این جدول عمداً برای شفافیت نگه داشته شده تا مشخص باشد چه چیزی واقعاً کار می‌کند و چه چیزی قدم بعدی است.

## Setup

```bash
flutter --version   # حداقل 3.32 (به دلیل استفاده از CardThemeData)
flutter pub get
```

### اجرای Code Generation (الزامی، قبل از اجرا)

دیتابیس با Drift ساخته شده و به کدِ تولیدشده نیاز دارد:

```bash
dart run build_runner build --delete-conflicting-outputs
```

این دستور فایل `lib/core/database/app_database.g.dart` را می‌سازد. بدون این مرحله پروژه build نمی‌شود.

## Run

```bash
flutter devices
flutter run
```

## Build

```bash
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

خروجی APK: `build/app/outputs/flutter-apk/`

## اجرای خودکار روی GitHub (CI)

`.github/workflows/flutter-ci.yml` با هر push/PR به `main`:

1. `dart run build_runner build` (تولید کد Drift)
2. `flutter analyze`
3. `flutter test --coverage` (Unit + Widget + Integration-level tests)
4. ساخت APK دیباگ و آپلود آن به‌عنوان Artifact قابل دانلود در تب Actions

## Architecture

**Clean Architecture + Feature-based**:

```
lib/
 ├─ core/
 │   ├─ money/                Money value object (int/rial-only، بدون double)
 │   ├─ domain_services/      BalanceEngine, DebtSimplifier, SplitCalculator (pure, تست‌شده)
 │   ├─ database/             Drift schema (tables.dart) + AppDatabase
 │   ├─ theme/                Design System مرکزی
 │   ├─ utils/                فرمت اعداد و تاریخ فارسی (شمسی)
 │   ├─ error/                Failure classes (آماده برای wiring کامل)
 │   └─ routing/               go_router config
 │
 ├─ features/
 │   ├─ auth/                  ورود، Session (Secure Storage)، Splash
 │   ├─ groups/                CRUD گروه، افزودن عضو، Drift Repository
 │   ├─ expenses/              ثبت هزینه (۴ روش تقسیم)، تاریخچه
 │   ├─ balances/              Balance/Debt Providerها (فقط مصرف‌کننده‌ی core/domain_services)
 │   ├─ settlements/           تسویه‌حساب
 │   ├─ statistics/            آمار پایه
 │   ├─ profile/                پروفایل
 │   └─ onboarding/             آموزش اولیه
 │
 └─ shared/widgets/            Loading/Empty/Error state مشترک
```

قوانین وابستگی: `presentation` فقط به `domain` وابسته است؛ `domain` هیچ وابستگی خارجی ندارد؛
منطق مالی **فقط** در `core/domain_services` است — UI و Database هرگز خودشان balance محاسبه نمی‌کنند.

## Database (Drift/SQLite)

جدول‌ها: `users`, `groups`, `group_members`, `expenses`, `expense_payers`, `expense_shares`,
`settlements`, `sync_log`. همه‌ی مبالغ `INTEGER` (ریال) هستند — هرگز `REAL`/double.

Repository Pattern رعایت شده: `GroupsRepository` / `ExpensesRepository` / `SettlementsRepository`
همگی interface هستند و پیاده‌سازی فعلی (`Drift...Repository`) بدون تغییر در UI قابل تعویض
با Firebase/Supabase/Backend اختصاصی است.

## Testing

```bash
flutter test                     # همه‌ی تست‌ها
flutter test test/unit/          # فقط Unit
flutter test test/integration/   # تست یکپارچه‌ی Repository + Domain Services
```

- `test/unit/balance_engine_test.dart` — سناریوی Ali/Reza/Mohammad (بخش 43 سند) + چند payer + چند هزینه
- `test/unit/debt_simplifier_test.dart` — زنجیره A→B→C (بخش 17 سند)
- `test/unit/split_calculator_test.dart` — هر ۴ روش تقسیم + Validation
- `test/integration/full_flow_test.dart` — سناریوی کامل بخش 42 سند، روی دیتابیس Drift واقعی
  (in-memory): Create Group → Add Member → Add Expense → Calculate Balance → Settle → Verify.
  این تست در سطح Repository+Domain است (نه UI)؛ یک `integration_test` کامل با `flutter drive`
  روی دستگاه/شبیه‌ساز واقعی می‌تواند بعداً به پوشه‌ی `integration_test/` اضافه شود.
- `test/widget/app_smoke_test.dart` — بوت شدن اپ، رد شدن از Splash، مسیر Onboarding → Login

## نقشه‌ی راه

- [x] Architecture + Design System + Routing
- [x] Core Business Logic (Balance Engine, Debt Simplification, Split Calculator) + تست
- [x] Local Database (Drift) کامل و متصل
- [x] Groups / Members / Expenses / Settlements / Dashboard / History / Statistics
- [ ] OTP واقعی + Backend Auth
- [ ] چند Payer در UI Add Expense
- [ ] ویرایش/حذف Expense در UI
- [ ] Receipt (دوربین/گالری) + QR Invite
- [ ] Search
- [ ] wiring کامل `core/error/failure.dart` در همه‌ی Repositoryها
- [ ] Offline Sync با Backend واقعی
- [ ] Integration test سطح UI با `flutter drive`

## لایسنس

خصوصی / داخلی — برای انتشار عمومی لایسنس مناسب اضافه کنید.

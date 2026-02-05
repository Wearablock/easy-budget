# Easy Budget

A feature-rich personal finance management app built with Flutter for iOS and Android.

## Features

### Core Functionality
- **Transaction Management** - Add, edit, and delete income/expense transactions
- **Category System** - Customizable categories with icons and colors
- **Monthly Overview** - View transactions grouped by month with summary cards
- **Soft Delete** - Restore accidentally deleted transactions

### Statistics & Analytics
- **Monthly Summary** - Income, expense, and balance overview
- **Category Breakdown** - Pie charts showing spending distribution
- **Trend Analysis** - Bar charts for 6-month spending trends
- **Balance Tracking** - Line charts for cumulative balance over time

### Internationalization
**15 Languages Supported:**
- English, Korean, Japanese
- Chinese (Simplified & Traditional)
- German, French, Spanish, Portuguese, Italian
- Russian, Arabic, Thai, Vietnamese, Indonesian

### Multi-Currency Support
**16+ Currencies:**
- Americas: USD, MXN, BRL
- Europe: EUR, GBP, CHF, RUB
- Asia: KRW, JPY, CNY, TWD, HKD, INR
- Southeast Asia: VND, THB, IDR
- Middle East: SAR

### Customization
- **Light/Dark/System Theme** - Adapts to user preference
- **Custom Categories** - Create personalized expense/income categories
- **Language Selection** - Switch languages within the app

### Premium Features
- **Ad-Free Experience** - Remove ads via in-app purchase
- **Purchase Restoration** - Restore purchases on new devices

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.10+ |
| Database | Drift (SQLite ORM) |
| Charts | fl_chart |
| Ads | Google Mobile Ads (AdMob) |
| IAP | in_app_purchase |
| Fonts | Google Fonts (Poppins) |
| Icons | Phosphor Flutter |

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget (theme/locale)
├── database/                 # Drift ORM database layer
├── screens/                  # UI screens
│   ├── home/                 # Home & transaction list
│   ├── statistics/           # Charts & analytics
│   ├── transaction/          # Add/edit transactions
│   ├── category/             # Category management
│   ├── settings/             # App settings
│   └── onboarding/           # First-run setup
├── services/                 # Business logic
│   ├── transaction_service.dart
│   ├── statistics_service.dart
│   ├── preferences_service.dart
│   ├── ad_service.dart
│   └── iap_service.dart
├── models/                   # Data models
├── widgets/                  # Reusable UI components
├── utils/                    # Utility functions
├── constants/                # App constants
├── theme/                    # Theme definitions
└── l10n/                     # Localization files (ARB)
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Xcode (for iOS)
- Android Studio (for Android)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/easy_budget.git
   cd easy_budget
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate database code**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ipa --release
```

## Configuration

### AdMob Setup
Update ad unit IDs in `lib/services/ad_service.dart`:
```dart
static const String _androidBannerAdUnitId = 'your-android-ad-unit-id';
static const String _iosBannerAdUnitId = 'your-ios-ad-unit-id';
```

### In-App Purchase
Configure product ID in `lib/services/iap_service.dart`:
```dart
static const String removeAdsProductId = 'your-product-id';
```

## Architecture

- **Service-Based Architecture** - Business logic separated from UI
- **Drift ORM** - Type-safe database queries with code generation
- **Stream-Based Updates** - Real-time UI updates via database streams
- **Observer Pattern** - Cross-screen communication via notifiers
- **Minor Units Storage** - Amounts stored as integers for precision

## License

This project is private and not published to pub.dev.

## Support

For issues and feature requests, please contact support.

# Purchase Service

A comprehensive Flutter package designed to **simplify pro user status checks** with automatic real-time handling. This package automatically manages and provides up-to-date status of whether a user is free or pro, handling subscription changes, renewals, and expirations seamlessly in the background.

**🎯 Main Purpose:** Eliminate the complexity of manually tracking user subscription status. Once initialized, you get real-time updates when users subscribe to pro, when subscriptions expire, or when purchases are restored - all handled automatically without any manual intervention required.

[![pub package](https://img.shields.io/pub/v/purchase_service.svg)](https://pub.dartlang.org/packages/purchase_service)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🎯 **Simplified Pro Status Checks** - Get instant, up-to-date user status (free/pro)
- ⚡ **Automatic Status Management** - No manual handling needed for subscription changes
- 🔄 **Real-time Updates** - Automatic subscription status tracking and live updates
- 🚀 **Easy RevenueCat Integration** - Simple setup and configuration
- 💳 **Purchase Management** - Handle purchases, restores, and offerings
- 📱 **Paywall Support** - Built-in RevenueCat UI paywall integration
- 👤 **User Management** - Login/logout with user ID association
- 📊 **Pro Status Tracking** - Smart pro user detection with live updates
- 🎯 **Entitlement Checking** - Check specific or any active entitlements
- 📡 **Stream-based** - Reactive programming with status streams

## Why Use This Package?

**Set it and forget it!** Once you initialize the purchase service, you get:

✅ **Automatic Pro Status Tracking** - Always know if your user is free or pro without manual checks  
✅ **Real-time Subscription Changes** - When users subscribe, renew, or cancel, status updates automatically  
✅ **Zero Manual Handling** - No need to manually track subscription states or handle renewal logic  
✅ **Instant Status Updates** - Get notified immediately when subscription status changes  
✅ **Background Processing** - All subscription validations happen automatically in the background

**Example:** User subscribes to pro → `isPro` automatically becomes `true` → Pro features unlock instantly  
**Example:** User's subscription expires → `isPro` automatically becomes `false` → App gracefully handles downgrade

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  purchase_service: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### RevenueCat Setup

1. Create a RevenueCat account at [revenuecat.com](https://www.revenuecat.com/)
2. Configure your products and entitlements in the RevenueCat dashboard
3. Get your API key from the RevenueCat dashboard

## Usage

### Basic Setup

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchase_service/purchase_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Purchases service instance
  final PurchasesService purchasesService = PurchasesService();

  @override
  void initState() {
    super.initState();
    _initializePurchases();
  }

  Future<void> _initializePurchases() async {
    try {
      // Get platform-specific API key
      final purchasesApiKey = Platform.isIOS
          ? dotenv.env['REVENUECAT_IOS_KEY'] ?? ''
          : dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';

      await purchasesService.initialize(
        apiKey: purchasesApiKey,
        observerMode: false, // Set to true for testing
        userId: 'optional_user_id', // Optional
      );
      print('Purchase service initialized');
    } catch (e) {
      print('Error initializing purchases: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Purchase Service Demo')),
      body: Column(
        children: [
          // Check pro status
          Text(purchasesService.isPro ? 'PRO USER' : 'FREE USER'),
          // Your app content
        ],
      ),
    );
  }
}
```

### Environment Setup (.env file)

Create a `.env` file in your project root:

```env
# RevenueCat API Keys
REVENUECAT_IOS_KEY=your_ios_api_key_here
REVENUECAT_ANDROID_KEY=your_android_api_key_here
```

Don't forget to add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
  purchase_service: ^1.0.0
```

And load the environment in your `main()`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

### Check Pro Status (Automatic Updates)

The beauty of this package is that you get real-time pro status without any manual work:

```dart
// Simple pro status check - always up-to-date automatically
bool isPro = purchasesService.isPro;
if (isPro) {
  print('User is pro!');
  // Enable pro features automatically
} else {
  print('User is free');
  // Show free tier experience
}

// Listen to pro status changes in real-time (automatic updates)
purchasesService.proStatusStream.listen((isPro) {
  if (isPro) {
    print('User just became pro! 🎉');
    // Pro features automatically enabled - no manual handling needed
    _enableProFeatures();
  } else {
    print('User subscription expired');
    // Automatically handle downgrade - no manual tracking needed
    _showFreeTierMessage();
  }
});

// The package automatically handles:
// ✅ New subscriptions
// ✅ Subscription renewals
// ✅ Subscription cancellations
// ✅ Subscription expirations
// ✅ Purchase restorations
// ✅ Refunds and downgrades
```

### Present Paywall

```dart
Future<void> showPaywall() async {
  try {
    final result = await purchasesService.presentPaywallIfNeeded(
      entitlement: 'pro', // Your entitlement ID
      showCloseButton: true,
    );

    switch (result) {
      case PaywallResult.purchased:
        print('Purchase successful!');
        break;
      case PaywallResult.restored:
        print('Purchases restored!');
        break;
      case PaywallResult.cancelled:
        print('User cancelled');
        break;
      case PaywallResult.error:
        print('Error occurred');
        break;
    }
  } catch (e) {
    print('Error presenting paywall: $e');
  }
}
```

### Manual Purchase Flow

```dart
Future<void> makePurchase() async {
  try {
    // Get available offerings
    final offerings = await purchaseService.getOfferings();

    if (offerings.current != null) {
      final package = offerings.current!.monthly; // or weekly, annual, etc.

      if (package != null) {
        // Make the purchase
        final customerInfo = await purchaseService.purchasePackage(package);
        print('Purchase successful! Active entitlements: ${customerInfo.entitlements.active.keys}');
      }
    }
  } catch (e) {
    print('Purchase failed: $e');
  }
}
```

### Restore Purchases

```dart
Future<void> restorePurchases() async {
  try {
    final customerInfo = await purchaseService.restorePurchases();
    print('Purchases restored! Active entitlements: ${customerInfo.entitlements.active.keys}');
  } catch (e) {
    print('Restore failed: $e');
  }
}
```

### Check Specific Entitlements

```dart
// Check if user has a specific entitlement
bool hasProAccess = purchaseService.hasActiveEntitlement('pro');

// Get all active entitlements
List<String> activeEntitlements = purchaseService.activeEntitlements;
print('Active entitlements: $activeEntitlements');
```

### User Management

```dart
// Login user
await purchaseService.updateUserId('user123');

// Logout user
await purchaseService.updateUserId(null);
```

### Listen to Customer Info Changes

```dart
purchaseService.customerInfoStream.listen((customerInfo) {
  print('Customer info updated: ${customerInfo.entitlements.active.keys}');
  // Update UI based on new customer info
});
```

## Advanced Usage

### Complete Integration Example

```dart
class PurchaseManager {
  final PurchasesService _purchaseService = PurchasesService();
  StreamSubscription<bool>? _proStatusSubscription;
  StreamSubscription<CustomerInfo>? _customerInfoSubscription;

  Future<void> initialize(String apiKey, {String? userId}) async {
    await _purchaseService.initialize(apiKey: apiKey, userId: userId);
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to pro status changes
    _proStatusSubscription = _purchaseService.proStatusStream.listen((isPro) {
      if (isPro) {
        _enableProFeatures();
      } else {
        _disableProFeatures();
      }
    });

    // Listen to customer info changes
    _customerInfoSubscription = _purchaseService.customerInfoStream.listen((customerInfo) {
      _updateUserInterface(customerInfo);
    });
  }

  void _enableProFeatures() {
    // Enable premium features in your app
    print('Enabling pro features...');
  }

  void _disableProFeatures() {
    // Disable premium features
    print('Disabling pro features...');
  }

  void _updateUserInterface(CustomerInfo customerInfo) {
    // Update UI based on customer info
    print('Updating UI with customer info...');
  }

  bool get isPro => _purchaseService.isPro;

  Future<void> showPaywall(String entitlement) async {
    final result = await _purchaseService.presentPaywallIfNeeded(
      entitlement: entitlement,
    );
    // Handle result
  }

  void dispose() {
    _proStatusSubscription?.cancel();
    _customerInfoSubscription?.cancel();
    _purchaseService.dispose();
  }
}
```

## API Reference

### PurchasesService

#### Methods

- `initialize({required String apiKey, String? userId, bool observerMode = false})` - Initialize RevenueCat SDK
- `updateUserId(String? userId)` - Login/logout user
- `getOfferings()` - Get available offerings
- `purchasePackage(Package package)` - Purchase a package
- `restorePurchases()` - Restore previous purchases
- `presentPaywallIfNeeded({required String entitlement, bool showCloseButton = true})` - Show paywall
- `hasActiveEntitlement(String entitlementId)` - Check specific entitlement
- `getCustomerInfo()` - Get latest customer info
- `dispose()` - Clean up resources

#### Properties

- `isPro` - Boolean indicating if user has any active entitlement
- `customerInfo` - Current customer info
- `activeEntitlements` - List of active entitlement IDs
- `customerInfoStream` - Stream of customer info updates
- `proStatusStream` - Stream of pro status changes

#### Exported Types

- `PaywallResult` - Result of paywall presentation
- `EntitlementInfo` - Information about entitlements

## Error Handling

```dart
try {
  await purchaseService.initialize(apiKey: 'your_api_key');
} catch (e) {
  if (e.toString().contains('network')) {
    // Handle network errors
  } else if (e.toString().contains('configuration')) {
    // Handle configuration errors
  } else {
    // Handle other errors
  }
}
```

## Testing

The package includes comprehensive error handling and logging. For testing:

1. Use RevenueCat's sandbox environment
2. Set `observerMode: true` during initialization for testing
3. Use test products configured in your RevenueCat dashboard

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you find this package helpful, please give it a ⭐ on [GitHub](https://github.com/yourusername/purchase_service)!

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/yourusername/purchase_service/issues).

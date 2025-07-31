# Purchase Service - Usage Examples

This document provides comprehensive examples of how to use the Purchase Service package in your Flutter app.

## Complete Working Example

Here's a complete Flutter app that demonstrates all the features of the Purchase Service package:

```dart
import 'package:flutter/material.dart';
import 'package:purchase_service/purchase_service.dart';
import 'dart:async';

void main() {
  runApp(const PurchaseServiceDemo());
}

class PurchaseServiceDemo extends StatelessWidget {
  const PurchaseServiceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purchase Service Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PurchaseHomePage(),
    );
  }
}

class PurchaseHomePage extends StatefulWidget {
  const PurchaseHomePage({super.key});

  @override
  State<PurchaseHomePage> createState() => _PurchaseHomePageState();
}

class _PurchaseHomePageState extends State<PurchaseHomePage> {
  final PurchasesService _purchaseService = PurchasesService();

  // State variables
  bool _isInitialized = false;
  bool _isLoading = false;
  String _statusMessage = 'Not initialized';
  List<String> _logs = [];

  // Stream subscriptions
  StreamSubscription<bool>? _proStatusSubscription;
  StreamSubscription<CustomerInfo>? _customerInfoSubscription;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
    _setupListeners();
  }

  @override
  void dispose() {
    _proStatusSubscription?.cancel();
    _customerInfoSubscription?.cancel();
    _purchaseService.dispose();
    super.dispose();
  }

  // Initialize the purchase service
  Future<void> _initializePurchaseService() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing...';
    });

    try {
      await _purchaseService.initialize(
        apiKey: 'YOUR_REVENUECAT_API_KEY', // Replace with your actual API key
        userId: 'demo_user_123', // Optional - replace with actual user ID
      );

      setState(() {
        _isInitialized = true;
        _statusMessage = 'Initialized successfully';
      });

      _addLog('✅ Purchase service initialized successfully');
    } catch (e) {
      setState(() {
        _statusMessage = 'Initialization failed: $e';
      });
      _addLog('❌ Initialization failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Setup stream listeners
  void _setupListeners() {
    // Listen to pro status changes
    _proStatusSubscription = _purchaseService.proStatusStream.listen((isPro) {
      _addLog(isPro ? '🎉 User became PRO!' : '📱 User is now FREE');

      if (isPro) {
        _showSnackBar('Welcome to PRO! 🎉', Colors.green);
      } else {
        _showSnackBar('PRO subscription ended', Colors.orange);
      }
    });

    // Listen to customer info changes
    _customerInfoSubscription = _purchaseService.customerInfoStream.listen((customerInfo) {
      final activeEntitlements = customerInfo.entitlements.active.keys.toList();
      _addLog('📊 Customer info updated. Active entitlements: ${activeEntitlements.isEmpty ? "None" : activeEntitlements.join(", ")}');
    });
  }

  // Helper methods
  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)} $message');
      if (_logs.length > 10) {
        _logs.removeLast();
      }
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Purchase actions
  Future<void> _presentPaywall() async {
    if (!_isInitialized) {
      _showSnackBar('Service not initialized', Colors.red);
      return;
    }

    try {
      _addLog('📱 Presenting paywall...');

      final result = await _purchaseService.presentPaywallIfNeeded(
        entitlement: 'pro', // Replace with your entitlement ID
        showCloseButton: true,
      );

      String message;
      Color color;

      switch (result) {
        case PaywallResult.purchased:
          message = 'Purchase successful! 🎉';
          color = Colors.green;
          _addLog('✅ Purchase completed successfully');
          break;
        case PaywallResult.restored:
          message = 'Purchases restored! ✅';
          color = Colors.blue;
          _addLog('♻️ Purchases restored successfully');
          break;
        case PaywallResult.cancelled:
          message = 'Purchase cancelled by user';
          color = Colors.grey;
          _addLog('❌ Purchase cancelled by user');
          break;
        case PaywallResult.error:
          message = 'Purchase error occurred';
          color = Colors.red;
          _addLog('❌ Purchase error occurred');
          break;
        default:
          message = 'Unknown result: $result';
          color = Colors.grey;
          _addLog('❓ Unknown paywall result: $result');
      }

      _showSnackBar(message, color);
    } catch (e) {
      _addLog('❌ Paywall error: $e');
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _restorePurchases() async {
    if (!_isInitialized) {
      _showSnackBar('Service not initialized', Colors.red);
      return;
    }

    try {
      _addLog('♻️ Restoring purchases...');
      await _purchaseService.restorePurchases();
      _addLog('✅ Restore completed successfully');
      _showSnackBar('Restore completed', Colors.blue);
    } catch (e) {
      _addLog('❌ Restore failed: $e');
      _showSnackBar('Restore failed: $e', Colors.red);
    }
  }

  Future<void> _checkOfferings() async {
    if (!_isInitialized) {
      _showSnackBar('Service not initialized', Colors.red);
      return;
    }

    try {
      _addLog('📦 Fetching offerings...');
      final offerings = await _purchaseService.getOfferings();

      if (offerings.current != null) {
        final current = offerings.current!;
        _addLog('📦 Current offering: ${current.identifier}');
        _addLog('📦 Available packages: ${current.availablePackages.map((p) => p.identifier).join(", ")}');
        _showSnackBar('Offerings loaded successfully', Colors.green);
      } else {
        _addLog('📦 No current offering available');
        _showSnackBar('No offerings available', Colors.orange);
      }
    } catch (e) {
      _addLog('❌ Failed to fetch offerings: $e');
      _showSnackBar('Failed to fetch offerings: $e', Colors.red);
    }
  }

  Future<void> _updateUserId() async {
    if (!_isInitialized) {
      _showSnackBar('Service not initialized', Colors.red);
      return;
    }

    try {
      final newUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _addLog('👤 Updating user ID to: $newUserId');
      await _purchaseService.updateUserId(newUserId);
      _addLog('✅ User ID updated successfully');
      _showSnackBar('User ID updated', Colors.blue);
    } catch (e) {
      _addLog('❌ Failed to update user ID: $e');
      _showSnackBar('Failed to update user ID: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Service Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.warning,
                          color: _isInitialized ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Service Status',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _purchaseService.isPro ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _purchaseService.isPro ? "PRO ✅" : "FREE",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (_purchaseService.activeEntitlements.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Entitlements: ${_purchaseService.activeEntitlements.join(", ")}',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isInitialized && !_isLoading ? _presentPaywall : null,
                  icon: const Icon(Icons.star),
                  label: const Text('Show Paywall'),
                ),
                ElevatedButton.icon(
                  onPressed: _isInitialized && !_isLoading ? _restorePurchases : null,
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore'),
                ),
                ElevatedButton.icon(
                  onPressed: _isInitialized && !_isLoading ? _checkOfferings : null,
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Offerings'),
                ),
                ElevatedButton.icon(
                  onPressed: _isInitialized && !_isLoading ? _updateUserId : null,
                  icon: const Icon(Icons.person),
                  label: const Text('Update User'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Activity Log
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text(
                            'Activity Log',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _logs.isEmpty
                            ? const Center(
                                child: Text(
                                  'No activity yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      _logs[index],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Setup Instructions
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Setup Instructions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Replace "YOUR_REVENUECAT_API_KEY" with your actual RevenueCat API key\n'
                      '2. Replace "pro" with your actual entitlement ID\n'
                      '3. Configure your products in RevenueCat dashboard\n'
                      '4. Test with RevenueCat sandbox environment',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Simple Usage Examples

### 1. Basic Initialization

```dart
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchase_service/purchase_service.dart';

class PurchaseManager {
  /// Purchases service instance
  final PurchasesService _purchaseService = PurchasesService();

  Future<void> initialize() async {
    // Get platform-specific API key
    final purchasesApiKey = Platform.isIOS
        ? dotenv.env['REVENUECAT_IOS_KEY'] ?? ''
        : dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';

    await _purchaseService.initialize(
      apiKey: purchasesApiKey,
      observerMode: false, // Set to true for testing
      userId: 'optional_user_id',
    );
  }

  bool get isPro => _purchaseService.isPro;

  void dispose() => _purchaseService.dispose();
}
```

### 2. Real-time Pro Status Tracking

```dart
class ProStatusWidget extends StatefulWidget {
  @override
  _ProStatusWidgetState createState() => _ProStatusWidgetState();
}

class _ProStatusWidgetState extends State<ProStatusWidget> {
  final PurchasesService _purchaseService = PurchasesService();
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _purchaseService.proStatusStream.listen((isPro) {
      setState(() {
        // Update UI based on pro status
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _purchaseService.isPro ? Colors.gold : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _purchaseService.isPro ? 'PRO USER ⭐' : 'FREE USER',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

### 3. Paywall Integration

```dart
class PaywallButton extends StatelessWidget {
  final PurchasesService purchaseService;

  const PaywallButton({required this.purchaseService});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await purchaseService.presentPaywallIfNeeded(
          entitlement: 'pro',
          showCloseButton: true,
        );

        switch (result) {
          case PaywallResult.purchased:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Purchase successful! 🎉')),
            );
            break;
          case PaywallResult.cancelled:
            // Handle cancellation
            break;
          default:
            // Handle other results
        }
      },
      child: Text('Upgrade to Pro'),
    );
  }
}
```

### 4. Feature Gating

```dart
class FeatureGate extends StatelessWidget {
  final Widget child;
  final Widget fallback;
  final PurchasesService purchaseService;

  const FeatureGate({
    required this.child,
    required this.fallback,
    required this.purchaseService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: purchaseService.proStatusStream,
      initialData: purchaseService.isPro,
      builder: (context, snapshot) {
        return snapshot.data == true ? child : fallback;
      },
    );
  }
}

// Usage:
FeatureGate(
  purchaseService: purchaseService,
  child: PremiumFeatureWidget(),
  fallback: UpgradePromptWidget(),
)
```

### 5. Manual Purchase Flow

```dart
Future<void> purchaseSpecificProduct() async {
  try {
    final offerings = await purchaseService.getOfferings();

    if (offerings.current != null) {
      final package = offerings.current!.monthly;

      if (package != null) {
        final customerInfo = await purchaseService.purchasePackage(package);
        print('Purchase successful: ${customerInfo.entitlements.active.keys}');
      }
    }
  } catch (e) {
    print('Purchase failed: $e');
  }
}
```

## Error Handling Best Practices

```dart
class RobustPurchaseManager {
  /// Purchases service instance
  final PurchasesService _purchaseService = PurchasesService();

  Future<bool> initializeWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        // Get platform-specific API key
        final purchasesApiKey = Platform.isIOS
            ? dotenv.env['REVENUECAT_IOS_KEY'] ?? ''
            : dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';

        await _purchaseService.initialize(
          apiKey: purchasesApiKey,
          observerMode: false,
        );
        return true;
      } catch (e) {
        if (i == maxRetries - 1) {
          print('Failed to initialize after $maxRetries attempts: $e');
          return false;
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return false;
  }

  Future<PaywallResult?> safeShowPaywall(String entitlement) async {
    try {
      return await _purchaseService.presentPaywallIfNeeded(
        entitlement: entitlement,
      );
    } on PlatformException catch (e) {
      print('Platform error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }
}
```

## Testing

For testing your integration:

1. **Use RevenueCat Sandbox**: Configure test products in your RevenueCat dashboard
2. **Test Accounts**: Use test Apple ID / Google Play test accounts
3. **Mock Responses**: Create mock implementations for unit tests

```dart
// Example test helper
class MockPurchaseService implements PurchasesService {
  bool _mockIsPro = false;

  @override
  bool get isPro => _mockIsPro;

  void setMockProStatus(bool isPro) {
    _mockIsPro = isPro;
    // Emit to stream if needed
  }

  // Implement other methods for testing
}
```

## Tips for Production

1. **Handle Network Errors**: Always wrap purchase calls in try-catch
2. **User Feedback**: Show loading states and clear error messages
3. **Offline Handling**: Cache entitlement status for offline scenarios
4. **Analytics**: Track purchase funnel and conversion rates
5. **A/B Testing**: Test different paywall presentations

This package makes it easy to integrate RevenueCat into your Flutter app with minimal boilerplate code while providing powerful features like real-time status tracking and automatic paywall handling.

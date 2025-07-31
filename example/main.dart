import 'package:flutter/material.dart';
import 'package:purchase_service/purchase_service.dart';
import 'dart:async';

// Note: For a complete setup, add flutter_dotenv to pubspec.yaml and load .env file
// import 'dart:io';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Uncomment these lines when using flutter_dotenv:
  // WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  runApp(const PurchaseServiceExampleApp());
}

class PurchaseServiceExampleApp extends StatelessWidget {
  const PurchaseServiceExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purchase Service Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const PurchaseExampleHomePage(),
    );
  }
}

class PurchaseExampleHomePage extends StatefulWidget {
  const PurchaseExampleHomePage({super.key});

  @override
  State<PurchaseExampleHomePage> createState() =>
      _PurchaseExampleHomePageState();
}

class _PurchaseExampleHomePageState extends State<PurchaseExampleHomePage> {
  /// Purchases service instance
  final PurchasesService _purchaseService = PurchasesService();

  // State variables
  bool _isInitialized = false;
  bool _isLoading = false;
  String _statusMessage = 'Not initialized';
  final List<String> _activityLog = [];

  // Stream subscriptions
  StreamSubscription<bool>? _proStatusSubscription;
  StreamSubscription<CustomerInfo>? _customerInfoSubscription;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
    _setupStreamListeners();
  }

  @override
  void dispose() {
    _proStatusSubscription?.cancel();
    _customerInfoSubscription?.cancel();
    _purchaseService.dispose();
    super.dispose();
  }

  /// Initialize the RevenueCat purchase service
  Future<void> _initializePurchaseService() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing...';
    });

    try {
      // IMPORTANT: Use platform-specific API keys
      // Replace with your actual RevenueCat API keys from .env file or constants

      // Example with dotenv (recommended):
      // final purchasesApiKey = Platform.isIOS
      //     ? dotenv.env['REVENUECAT_IOS_KEY'] ?? ''
      //     : dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';

      // For this example, using placeholder - replace with your keys:
      const purchasesApiKey = 'YOUR_PLATFORM_SPECIFIC_API_KEY_HERE';

      await _purchaseService.initialize(
        apiKey: purchasesApiKey,
        observerMode: false, // Set to true for testing
        userId:
            'example_user_${DateTime.now().millisecondsSinceEpoch}', // Optional
      );

      setState(() {
        _isInitialized = true;
        _statusMessage = 'Ready for purchases! 🎉';
      });

      _addToLog('✅ Purchase service initialized successfully');
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to initialize: $e';
      });
      _addToLog('❌ Initialization failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Setup stream listeners for real-time updates
  void _setupStreamListeners() {
    // Listen to pro status changes
    _proStatusSubscription = _purchaseService.proStatusStream.listen((isPro) {
      _addToLog(isPro ? '🎉 User became PRO!' : '📱 User is now FREE');

      if (isPro) {
        _showSnackBar(
          'Welcome to PRO! All features unlocked! 🎉',
          Colors.green,
        );
      } else {
        _showSnackBar('Pro subscription ended', Colors.orange);
      }
    });

    // Listen to customer info updates
    _customerInfoSubscription = _purchaseService.customerInfoStream.listen((
      customerInfo,
    ) {
      final entitlements = customerInfo.entitlements.active.keys.toList();
      _addToLog(
        '📊 Customer info updated. Active: ${entitlements.isEmpty ? "None" : entitlements.join(", ")}',
      );
    });
  }

  /// Add message to activity log
  void _addToLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _activityLog.insert(0, '[$timestamp] $message');
      // Keep only last 15 entries
      if (_activityLog.length > 15) {
        _activityLog.removeLast();
      }
    });
  }

  /// Show snackbar message
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Present the RevenueCat paywall
  Future<void> _showPaywall() async {
    if (!_isInitialized) {
      _showSnackBar('Please wait for initialization to complete', Colors.red);
      return;
    }

    try {
      _addToLog('📱 Presenting paywall...');

      // IMPORTANT: Replace 'pro' with your actual entitlement ID from RevenueCat dashboard
      final result = await _purchaseService.presentPaywallIfNeeded(
        entitlement: 'pro',
        showCloseButton: true,
      );

      // Handle the result
      switch (result) {
        case PaywallResult.purchased:
          _addToLog('✅ Purchase completed successfully!');
          _showSnackBar('Purchase successful! Thank you! 🎉', Colors.green);
          break;
        case PaywallResult.restored:
          _addToLog('♻️ Purchases restored successfully!');
          _showSnackBar('Purchases restored! ✅', Colors.blue);
          break;
        case PaywallResult.cancelled:
          _addToLog('❌ User cancelled the purchase');
          _showSnackBar('Purchase cancelled', Colors.grey);
          break;
        case PaywallResult.error:
          _addToLog('❌ Paywall error occurred');
          _showSnackBar('Purchase error occurred', Colors.red);
          break;
        default:
          _addToLog('❓ Unknown paywall result: $result');
      }
    } catch (e) {
      _addToLog('❌ Paywall error: $e');
      _showSnackBar('Error presenting paywall: $e', Colors.red);
    }
  }

  /// Restore previous purchases
  Future<void> _restorePurchases() async {
    if (!_isInitialized) {
      _showSnackBar('Please wait for initialization to complete', Colors.red);
      return;
    }

    try {
      _addToLog('♻️ Restoring purchases...');
      final customerInfo = await _purchaseService.restorePurchases();

      final activeEntitlements = customerInfo.entitlements.active.keys.toList();
      if (activeEntitlements.isNotEmpty) {
        _addToLog('✅ Restored entitlements: ${activeEntitlements.join(", ")}');
        _showSnackBar('Purchases restored successfully!', Colors.blue);
      } else {
        _addToLog('ℹ️ No previous purchases found to restore');
        _showSnackBar('No previous purchases found', Colors.orange);
      }
    } catch (e) {
      _addToLog('❌ Restore failed: $e');
      _showSnackBar('Restore failed: $e', Colors.red);
    }
  }

  /// Check available offerings from RevenueCat
  Future<void> _checkOfferings() async {
    if (!_isInitialized) {
      _showSnackBar('Please wait for initialization to complete', Colors.red);
      return;
    }

    try {
      _addToLog('📦 Fetching available offerings...');
      final offerings = await _purchaseService.getOfferings();

      if (offerings.current != null) {
        final current = offerings.current!;
        _addToLog('📦 Current offering: ${current.identifier}');

        final packages = current.availablePackages;
        if (packages.isNotEmpty) {
          _addToLog(
            '📦 Available packages: ${packages.map((p) => '${p.identifier} (${p.storeProduct.priceString})').join(", ")}',
          );
          _showSnackBar(
            'Found ${packages.length} available packages',
            Colors.green,
          );
        } else {
          _addToLog('📦 No packages available in current offering');
          _showSnackBar('No packages available', Colors.orange);
        }
      } else {
        _addToLog('📦 No current offering configured');
        _showSnackBar('No offerings configured in RevenueCat', Colors.orange);
      }
    } catch (e) {
      _addToLog('❌ Failed to fetch offerings: $e');
      _showSnackBar('Failed to fetch offerings: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Service Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(),

            const SizedBox(height: 16),

            // Activity Log
            _buildActivityLog(),

            const SizedBox(height: 16),

            // Setup Instructions
            _buildSetupInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isInitialized
                      ? Icons.check_circle
                      : (_isLoading ? Icons.hourglass_empty : Icons.warning),
                  color:
                      _isInitialized
                          ? Colors.green
                          : (_isLoading ? Colors.blue : Colors.orange),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Service Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 14,
                color:
                    _isInitialized
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _purchaseService.isPro ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _purchaseService.isPro ? Icons.star : Icons.person,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _purchaseService.isPro ? "PRO USER" : "FREE USER",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_purchaseService.activeEntitlements.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Active: ${_purchaseService.activeEntitlements.join(", ")}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      (_isInitialized && !_isLoading) ? _showPaywall : null,
                  icon: const Icon(Icons.star),
                  label: const Text('Show Paywall'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      (_isInitialized && !_isLoading)
                          ? _restorePurchases
                          : null,
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      (_isInitialized && !_isLoading) ? _checkOfferings : null,
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Offerings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLog() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Activity Log',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_activityLog.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _activityLog.clear()),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  _activityLog.isEmpty
                      ? const Center(
                        child: Text(
                          'No activity yet\nTry initializing or using the buttons above',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _activityLog.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              _activityLog[index],
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
    );
  }

  Widget _buildSetupInstructions() {
    return Card(
      color: Colors.amber.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Setup Instructions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '🔧 To make this example work:\n\n'
              '1. Create a RevenueCat account at revenuecat.com\n'
              '2. Get separate API keys for iOS and Android from RevenueCat dashboard\n'
              '3. Create a .env file with:\n'
              '   REVENUECAT_IOS_KEY=your_ios_key\n'
              '   REVENUECAT_ANDROID_KEY=your_android_key\n'
              '4. Add flutter_dotenv to pubspec.yaml\n'
              '5. Use Platform.isIOS to get correct key\n'
              '6. Create an entitlement called "pro" in your dashboard\n'
              '7. Configure your products and offerings\n'
              '8. Test with sandbox/test accounts\n\n'
              '💡 Example shows purchasesService.isPro usage\n'
              '📱 Use observerMode: true for testing',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

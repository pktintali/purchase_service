import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// A service that handles integration with the RevenueCat purchases system.
///
/// This service provides methods to initialize the RevenueCat SDK, manage user IDs,
/// fetch products, process purchases, and check subscription status.
class PurchasesService {
  static final PurchasesService _instance = PurchasesService._internal();

  /// Factory constructor that returns the singleton instance
  factory PurchasesService() => _instance;

  PurchasesService._internal();

  bool _isInitialized = false;
  CustomerInfo? _customerInfo;
  bool _isPro = false;

  /// Stream controller for customer info updates
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();

  /// Stream controller for pro status updates
  final _proStatusController = StreamController<bool>.broadcast();

  /// Stream of customer info updates
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// Stream of pro status changes (true when user becomes pro, false when subscription expires)
  Stream<bool> get proStatusStream => _proStatusController.stream;

  /// Current customer info
  CustomerInfo? get customerInfo => _customerInfo;

  /// Initialize the RevenueCat SDK
  ///
  /// Must be called before using any other methods of this service.
  ///
  /// [apiKey] - Your RevenueCat API key
  /// [userId] - The user ID to associate purchases with (optional)
  /// [observerMode] - If true, the SDK will not make any purchases (testing mode)
  Future<void> initialize({
    required String apiKey,
    String? userId,
    bool observerMode = false,
  }) async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (userId != null && userId.isNotEmpty) {
        configuration = PurchasesConfiguration(apiKey)..appUserID = userId;
      } else {
        configuration = PurchasesConfiguration(apiKey);
      }

      // configuration.observerMode = observerMode;
      await Purchases.configure(configuration);

      _isInitialized = true;
      await _updateCustomerInfo();

      // Set up listener for customer info changes
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo = info;
        _customerInfoController.add(info);
        _updateProStatus(info);
      });
    } catch (e) {
      debugPrint('Error initializing purchases service: $e');
      rethrow;
    }
  }

  /// Update user ID (for login/logout scenarios)
  ///
  /// Call this method when a user logs in or logs out to associate purchases with the correct account.
  ///
  /// [userId] - The user ID to associate purchases with, or null to logout
  Future<void> updateUserId(String? userId) async {
    if (!_isInitialized) {
      throw Exception(
        'PurchasesService must be initialized before updating user ID',
      );
    }

    try {
      if (userId != null && userId.isNotEmpty) {
        await Purchases.logIn(userId);
      } else {
        await Purchases.logOut();
      }

      await _updateCustomerInfo();
    } catch (e) {
      debugPrint('Error updating user ID: $e');
      rethrow;
    }
  }

  /// Get available offerings
  ///
  /// Returns the available offerings configured in the RevenueCat dashboard.
  Future<Offerings> getOfferings() async {
    if (!_isInitialized) {
      throw Exception(
        'PurchasesService must be initialized before getting offerings',
      );
    }

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error getting offerings: $e');
      rethrow;
    }
  }

  /// Purchase a package
  ///
  /// Initiates the purchase flow for a package and returns the updated customer info.
  ///
  /// [package] - The package to purchase
  Future<CustomerInfo> purchasePackage(Package package) async {
    if (!_isInitialized) {
      throw Exception(
        'PurchasesService must be initialized before making purchases',
      );
    }

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _customerInfo = customerInfo;
      _customerInfoController.add(_customerInfo!);
      return _customerInfo!;
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      rethrow;
    }
  }

  /// Restore purchases
  ///
  /// Restores previously purchased entitlements for the current user.
  Future<CustomerInfo> restorePurchases() async {
    if (!_isInitialized) {
      throw Exception(
        'PurchasesService must be initialized before restoring purchases',
      );
    }

    try {
      _customerInfo = await Purchases.restorePurchases();
      _customerInfoController.add(_customerInfo!);
      return _customerInfo!;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// Check if user has active subscription to a specific entitlement
  ///
  /// [entitlementId] - The ID of the entitlement to check
  bool hasActiveEntitlement(String entitlementId) {
    if (_customerInfo == null) return false;

    final entitlement = _customerInfo!.entitlements.active[entitlementId];
    return entitlement != null;
  }

  /// Get all active entitlements
  List<String> get activeEntitlements {
    if (_customerInfo == null) return [];

    return _customerInfo!.entitlements.active.keys.toList();
  }

  /// Get customer info from the server
  Future<CustomerInfo> getCustomerInfo() async {
    if (!_isInitialized) {
      throw Exception(
        'PurchasesService must be initialized before getting customer info',
      );
    }

    return await _updateCustomerInfo();
  }

  /// Update customer info
  Future<CustomerInfo> _updateCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _customerInfoController.add(_customerInfo!);
      _updateProStatus(_customerInfo!);
      return _customerInfo!;
    } catch (e) {
      debugPrint('Error updating customer info: $e');
      rethrow;
    }
  }

  /// Update pro status based on customer info and emit changes
  void _updateProStatus(CustomerInfo customerInfo) {
    final wasProBefore = _isPro;
    _isPro = customerInfo.entitlements.active.isNotEmpty;

    // Only emit pro status change if it actually changed
    if (wasProBefore != _isPro) {
      _proStatusController.add(_isPro);
      debugPrint('Pro status changed: $wasProBefore -> $_isPro');
      debugPrint(
        'Active entitlements: ${customerInfo.entitlements.active.keys.toList()}',
      );
    }
  }

  /// Check if the customer is pro (has any active entitlements)
  ///
  /// This method returns true if the user has ANY active entitlement,
  /// making them a "pro" user. It automatically updates in real-time
  /// when purchases are made or subscriptions expire.
  ///
  /// Returns true if user has active entitlements, false otherwise.
  bool get isPro => _isPro;

  /// Dispose the service
  void dispose() {
    _customerInfoController.close();
    _proStatusController.close();
  }

  Future<PaywallResult> presentPaywallIfNeeded({
    required String entitlement,
    bool showCloseButton = true,
  }) async {
    return await RevenueCatUI.presentPaywallIfNeeded(
      entitlement,
      displayCloseButton: showCloseButton,
    );
  }
}

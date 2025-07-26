## 1.0.0

### Initial Release

- ✨ **Core Features**

  - Complete RevenueCat SDK integration
  - Singleton service pattern for easy access
  - Automatic SDK initialization with configuration options

- 💳 **Purchase Management**

  - Purchase packages with error handling
  - Restore previous purchases
  - Get available offerings from RevenueCat dashboard

- 🎨 **Paywall Integration**

  - Built-in RevenueCat UI paywall support
  - Customizable paywall presentation with close button option
  - Automatic result handling (purchased, restored, cancelled, error)

- 🔄 **Real-time Updates**

  - Live customer info updates via streams
  - Automatic pro status tracking
  - Smart entitlement detection

- 👤 **User Management**

  - Login/logout functionality with user ID association
  - Seamless user switching support

- 📊 **Status Tracking**

  - `isPro` getter for instant pro status checking
  - `proStatusStream` for real-time pro status changes
  - Individual entitlement checking with `hasActiveEntitlement()`
  - Complete active entitlements list

- 🛠 **Developer Experience**

  - Comprehensive error handling and logging
  - Stream-based reactive programming support
  - Proper resource cleanup with `dispose()`
  - Extensive documentation and examples

- 📦 **Exports**
  - `PaywallResult` enum from RevenueCat UI
  - `EntitlementInfo` class from RevenueCat core
  - Clean API surface with essential types

### Dependencies

- `purchases_flutter: ^8.9.0` - RevenueCat core SDK
- `purchases_ui_flutter: ^8.9.0` - RevenueCat UI components
- Requires Flutter SDK `>=3.0.0`
- Requires Dart SDK `^3.7.0`

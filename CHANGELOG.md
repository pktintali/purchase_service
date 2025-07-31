## 1.0.1

### Documentation & Examples Update

- 📝 **Enhanced Documentation**

  - Updated README.md to clearly emphasize the package's main purpose: simplifying pro status checks with automatic real-time handling
  - Added "Why Use This Package?" section highlighting the "set it and forget it" philosophy
  - Enhanced feature descriptions to emphasize automation benefits

- 🔧 **Corrected Usage Examples**

  - Fixed all examples to show proper platform-specific API key usage (separate iOS/Android keys)
  - Added comprehensive dotenv environment variable setup instructions
  - Updated initialization patterns to use `Platform.isIOS` for correct key selection
  - Enhanced error handling examples with platform-specific considerations

- 📖 **Improved Setup Instructions**

  - Added step-by-step environment configuration guide
  - Updated security best practices (`.env` file usage, `.gitignore` recommendations)
  - Enhanced troubleshooting section with environment variable issues
  - Corrected example app documentation

- ✨ **Code Examples Enhancement**
  - Updated main README.md with production-ready patterns
  - Fixed EXAMPLE.md with correct initialization code
  - Updated example/main.dart with proper dotenv integration
  - Enhanced example/README.md with complete setup workflow

### Files Updated

- `README.md` - Enhanced purpose description and corrected examples
- `EXAMPLE.md` - Fixed initialization and error handling examples
- `example/main.dart` - Updated to show platform-specific API key usage
- `example/README.md` - Comprehensive setup and troubleshooting guide

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

# Purchase Service Example

This example demonstrates how to use the Purchase Service package in a Flutter app.

## Features Demonstrated

- ✅ Service initialization with error handling
- ✅ Real-time pro status tracking with streams
- ✅ Paywall presentation and result handling
- ✅ Purchase restoration
- ✅ Offerings management
- ✅ Activity logging
- ✅ Proper UI state management
- ✅ Error handling and user feedback

## Setup Instructions

1. **RevenueCat Account Setup**

   - Create an account at [revenuecat.com](https://www.revenuecat.com/)
   - Create a new app in the RevenueCat dashboard
   - Get separate API keys for iOS and Android from the dashboard

2. **Environment Configuration**

   - Add `flutter_dotenv: ^5.1.0` to your `pubspec.yaml`
   - Create a `.env` file in your project root:

   ```env
   REVENUECAT_IOS_KEY=your_ios_api_key_here
   REVENUECAT_ANDROID_KEY=your_android_api_key_here
   ```

   - Add `.env` to your `.gitignore` file

3. **Configure Products**

   - Add your app to Apple App Store Connect / Google Play Console
   - Create in-app purchase products
   - Configure the products in RevenueCat dashboard
   - Create an entitlement called "pro"

4. **Update the Code**

   - Use platform-specific API keys with `Platform.isIOS`
   - Load environment variables in `main()`:

   ```dart
   await dotenv.load(fileName: ".env");
   ```

   - Initialize with correct pattern:

   ```dart
   final purchasesApiKey = Platform.isIOS
       ? dotenv.env['REVENUECAT_IOS_KEY'] ?? ''
       : dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';

   await purchasesService.initialize(
     apiKey: purchasesApiKey,
     observerMode: false, // Set to true for testing
   );
   ```

5. **Test with Sandbox**
   - Use test accounts (Apple ID test accounts / Google Play test accounts)
   - Test in sandbox environment before going live

## Running the Example

1. Make sure you have Flutter installed
2. Clone or download this example
3. Add `flutter_dotenv: ^5.1.0` to your `pubspec.yaml`
4. Create a `.env` file with your RevenueCat API keys
5. Update the code to load environment variables and use platform-specific keys
6. Run the app:

```bash
flutter run
```

## Code Structure

### Main Components

- **PurchaseServiceExampleApp**: Main app widget
- **PurchaseExampleHomePage**: Main page with all functionality
- **Stream Listeners**: Real-time updates for pro status and customer info
- **Action Methods**: Handle paywall, restore, and offerings
- **UI Components**: Status card, action buttons, activity log, setup instructions

### Key Methods

- `_initializePurchaseService()`: Initialize RevenueCat with API key
- `_setupStreamListeners()`: Listen to real-time status changes
- `_showPaywall()`: Present the RevenueCat paywall UI
- `_restorePurchases()`: Restore previous purchases
- `_checkOfferings()`: Fetch available offerings from RevenueCat

## Testing

1. **Sandbox Testing**

   - Use test Apple ID / Google Play test accounts
   - Test purchase flows without real money
   - Verify entitlements are properly granted

2. **Feature Testing**
   - Test pro status changes in real-time
   - Verify paywall presentation and dismissal
   - Test purchase restoration
   - Check error handling scenarios

## Common Issues

1. **API Key Issues**

   - Make sure you're using platform-specific API keys (separate for iOS and Android)
   - Check that the keys match your app configuration in RevenueCat dashboard
   - Verify your `.env` file is properly loaded and not committed to git

2. **Environment Variable Issues**

   - Ensure `flutter_dotenv` is added to your `pubspec.yaml`
   - Check that `.env` file is in the project root
   - Verify environment variables are loaded before service initialization

3. **Entitlement Not Found**

   - Verify your entitlement ID in RevenueCat dashboard
   - Make sure products are properly configured for both iOS and Android

4. **Sandbox Issues**
   - Use test accounts for sandbox testing
   - Clear app data if testing gets stuck

## Production Considerations

1. **Error Handling**: The example includes comprehensive error handling
2. **User Feedback**: Clear messages and loading states
3. **Offline Handling**: Consider caching entitlement status
4. **Analytics**: Track purchase funnel and conversion rates

## Package Documentation

For complete package documentation, see the main [README.md](../README.md) and [EXAMPLE.md](../EXAMPLE.md) files.

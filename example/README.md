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
   - Get your API key from the dashboard

2. **Configure Products**

   - Add your app to Apple App Store Connect / Google Play Console
   - Create in-app purchase products
   - Configure the products in RevenueCat dashboard
   - Create an entitlement called "pro"

3. **Update the Code**

   - Replace `YOUR_REVENUECAT_API_KEY_HERE` with your actual API key
   - Make sure your entitlement ID matches what you configured ("pro" by default)

4. **Test with Sandbox**
   - Use test accounts (Apple ID test accounts / Google Play test accounts)
   - Test in sandbox environment before going live

## Running the Example

1. Make sure you have Flutter installed
2. Clone or download this example
3. Update the API key in `main.dart`
4. Run the app:

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

   - Make sure you're using the correct API key
   - Check that the key matches your app configuration

2. **Entitlement Not Found**

   - Verify your entitlement ID in RevenueCat dashboard
   - Make sure products are properly configured

3. **Sandbox Issues**
   - Use test accounts for sandbox testing
   - Clear app data if testing gets stuck

## Production Considerations

1. **Error Handling**: The example includes comprehensive error handling
2. **User Feedback**: Clear messages and loading states
3. **Offline Handling**: Consider caching entitlement status
4. **Analytics**: Track purchase funnel and conversion rates

## Package Documentation

For complete package documentation, see the main [README.md](../README.md) and [EXAMPLE.md](../EXAMPLE.md) files.

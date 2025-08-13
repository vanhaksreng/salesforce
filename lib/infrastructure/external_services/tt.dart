// import 'package:salesforce/infrastructure/background/app_background_service.dart';
// import 'package:salesforce/infrastructure/background/native_flutter_background_service.dart';
// import 'package:salesforce/infrastructure/background/native_background_service_manager.dart';
// import 'package:salesforce/core/utils/logger.dart';

// /// Usage Examples for the Native Flutter Background Service
// class BackgroundServiceUsageExamples {
//   /// Example 1: Simple usage (same as before)
//   static Future<void> simpleUsage() async {
//     try {
//       // This will work exactly as before
//       await AppBackgroundService.startService();
//       Logger.log('Simple background service started');
//     } catch (e) {
//       Logger.log('Error in simple usage: $e');
//     }
//   }

//   /// Example 2: Using the service manager (recommended)
//   static Future<void> serviceManagerUsage() async {
//     try {
//       // This handles everything automatically
//       await NativeBackgroundServiceManager().initializeService();
//       Logger.log('Service manager started background service');
//     } catch (e) {
//       Logger.log('Error in service manager usage: $e');
//     }
//   }

//   /// Example 3: Using the native Flutter service (exact same pattern as original)
//   static Future<void> nativeFlutterServiceUsage() async {
//     try {
//       // This follows the exact same pattern as your original background_service_initializer.dart
//       await NativeFlutterBackgroundServiceHelper.start();
//       Logger.log('Native Flutter background service started');
//     } catch (e) {
//       Logger.log('Error in native Flutter service usage: $e');
//     }
//   }

//   /// Example 4: Complete lifecycle management
//   static Future<void> completeLifecycleExample() async {
//     try {
//       // Start the service
//       await NativeFlutterBackgroundServiceHelper.start();

//       // Check if running
//       if (NativeFlutterBackgroundServiceHelper.isRunning) {
//         Logger.log('Background service is running');

//         // Test manual execution
//         await NativeFlutterBackgroundServiceHelper.executeGpsService();
//         await NativeFlutterBackgroundServiceHelper.executeHeartbeatService();
//         await NativeFlutterBackgroundServiceHelper.executeSyncService();
//       }

//       // Later, restart when settings change
//       await NativeFlutterBackgroundServiceHelper.restart();

//       // Finally, stop when user logs out
//       NativeFlutterBackgroundServiceHelper.stop();
//     } catch (e) {
//       Logger.log('Error in complete lifecycle example: $e');
//     }
//   }

//   /// Example 5: Integration with your app lifecycle
//   static Future<void> appLifecycleIntegration() async {
//     try {
//       // After user login
//       await onUserLogin();

//       // When app goes to background
//       onAppBackground();

//       // When app comes to foreground
//       onAppForeground();

//       // When user changes settings
//       await onSettingsChanged();

//       // When user logs out
//       onUserLogout();
//     } catch (e) {
//       Logger.log('Error in app lifecycle integration: $e');
//     }
//   }

//   // Helper methods for app lifecycle
//   static Future<void> onUserLogin() async {
//     Logger.log('User logged in - starting background service');
//     await NativeFlutterBackgroundServiceHelper.start();
//   }

//   static void onAppBackground() {
//     Logger.log('App went to background - service continues running');
//     // The native service will continue running in the background
//   }

//   static void onAppForeground() {
//     Logger.log('App came to foreground');
//     if (NativeFlutterBackgroundServiceHelper.isRunning) {
//       Logger.log('Background service is still running');
//     } else {
//       Logger.log('Background service is not running');
//     }
//   }

//   static Future<void> onSettingsChanged() async {
//     Logger.log('Settings changed - restarting service');
//     await NativeFlutterBackgroundServiceHelper.restart();
//   }

//   static void onUserLogout() {
//     Logger.log('User logged out - stopping background service');
//     NativeFlutterBackgroundServiceHelper.stop();
//   }

//   /// Example 6: Testing individual services
//   static Future<void> testIndividualServices() async {
//     try {
//       Logger.log('Testing individual services...');

//       // Test GPS service
//       await NativeFlutterBackgroundServiceHelper.executeGpsService();

//       // Test heartbeat service
//       await NativeFlutterBackgroundServiceHelper.executeHeartbeatService();

//       // Test sync service
//       await NativeFlutterBackgroundServiceHelper.executeSyncService();

//       Logger.log('All individual services tested successfully');
//     } catch (e) {
//       Logger.log('Error testing individual services: $e');
//     }
//   }

//   /// Example 7: Service status monitoring
//   static void monitorServiceStatus() {
//     // Check if service is running
//     if (NativeFlutterBackgroundServiceHelper.isRunning) {
//       Logger.log('✅ Background service is running');
//     } else {
//       Logger.log('❌ Background service is not running');
//     }
//   }

//   /// Example 8: Cleanup on app termination
//   static void cleanup() {
//     Logger.log('Cleaning up background service resources');
//     NativeFlutterBackgroundServiceHelper.dispose();
//   }
// }

// /// Main usage example - you can call this from your main.dart
// class MainBackgroundServiceExample {
//   /// Initialize background service in your main.dart
//   static Future<void> initializeInMain() async {
//     try {
//       Logger.log('Initializing background service in main...');

//       // Choose one of these approaches:

//       // Approach 1: Simple (backward compatible)
//       // await AppBackgroundService.startService();

//       // Approach 2: Service manager (recommended)
//       // await NativeBackgroundServiceManager().initializeService();

//       // Approach 3: Native Flutter service (exact same pattern as original)
//       await NativeFlutterBackgroundServiceHelper.start();

//       Logger.log('Background service initialized successfully');
//     } catch (e) {
//       Logger.log('Error initializing background service: $e');
//     }
//   }

//   /// Example usage in your main.dart
//   static Future<void> mainExample() async {
//     // Your existing initialization code...

//     // Initialize background service
//     await initializeInMain();

//     // Your existing runApp() call...
//     // runApp(MyApp());
//   }
// }

// import 'package:flutter/services.dart';
// import 'package:salesforce/features/more/presentation/pages/imin_device/imin_printer_service.dart';

// class PrinterDiagnosticService {
//   static const MethodChannel _channel = MethodChannel('com.imin.printersdk');

//   // Test different density levels to find optimal setting
//   static Future<void> testPrintDensityLevels() async {
//     try {
//       await IminPrinterService.initializeSDK();

//       print("=== TESTING PRINT DENSITY LEVELS ===");

//       // Test different density levels
//       List<int> densityLevels = [5, 8, 10, 12, 15];

//       for (int density in densityLevels) {
//         print("Testing density level: $density");

//         // Set density
//         await IminPrinterService.setPrintDensity(density);
//         await Future.delayed(Duration(milliseconds: 500));

//         // Print test text
//         String testText = "Density $density: ABCDEFGH 12345678\n";
//         testText += "Special chars: @#\$%^&*()\n";
//         testText += "Lower case: abcdefgh\n";
//         testText += "Numbers: 0123456789\n";
//         testText += "------------------------\n";

//         await IminPrinterService.printText(testText);
//         await Future.delayed(Duration(milliseconds: 1000));
//       }

//       // Feed paper to see all results
//       await IminPrinterService.feedPaper(5);
//       print("=== DENSITY TEST COMPLETE ===");
//     } catch (e) {
//       print("Error in density test: $e");
//     }
//   }

//   // Test if it's a hardware issue
//   static Future<Map<String, dynamic>> diagnoseHardwareIssues() async {
//     Map<String, dynamic> diagnosis = {
//       'thermalHeadTemp': 'unknown',
//       'paperQuality': 'unknown',
//       'printerAge': 'unknown',
//       'recommendations': <String>[],
//     };

//     try {
//       // Check printer temperature (if available)
//       try {
//         final String? temp = await _channel.invokeMethod(
//           'getThermalHeadTemperature',
//         );
//         diagnosis['thermalHeadTemp'] = temp ?? 'not_supported';
//       } catch (e) {
//         diagnosis['thermalHeadTemp'] = 'not_supported';
//       }

//       // Print diagnostic pattern to check hardware
//       await IminPrinterService.initializeSDK();

//       String diagnosticText = "=== HARDWARE DIAGNOSTIC ===\n";
//       diagnosticText += "Full Black Line: ████████████████\n";
//       diagnosticText += "Half Tone: ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n";
//       diagnosticText += "Light Tone: ░░░░░░░░░░░░░░░░\n";
//       diagnosticText += "Text Test: The Quick Brown Fox\n";
//       diagnosticText += "Numbers: 0123456789\n";
//       diagnosticText += "Symbols: !@#\$%^&*()_+-=\n";
//       diagnosticText += "===========================\n\n";

//       // Test with maximum settings
//       await IminPrinterService.setPrintDensity(15);
//       await Future.delayed(Duration(milliseconds: 500));
//       await IminPrinterService.printTextWithFeed(diagnosticText);

//       // Add recommendations based on common issues
//       diagnosis['recommendations'].addAll([
//         'Check if text above is clearly visible',
//         'Compare black blocks - should be solid black',
//         'If faded: Clean thermal print head with alcohol',
//         'If uneven: Replace thermal paper',
//         'If all faded: Increase print density to 15',
//         'Let printer cool between heavy print jobs',
//       ]);
//     } catch (e) {
//       print("Error in hardware diagnosis: $e");
//     }

//     return diagnosis;
//   }

//   // Test different print settings combinations
//   static Future<void> testAllPrintSettings() async {
//     try {
//       await IminPrinterService.initializeSDK();

//       print("=== TESTING ALL PRINT SETTINGS ===");

//       // Test combinations of settings
//       List<Map<String, int>> settingsCombinations = [
//         {'density': 10, 'speed': 3, 'name': 0},
//         {'density': 15, 'speed': 3, 'name': 1},
//         {'density': 15, 'speed': 1, 'name': 2},
//         {'density': 12, 'speed': 2, 'name': 3},
//         {'density': 8, 'speed': 4, 'name': 4},
//       ];

//       for (var settings in settingsCombinations) {
//         print("Testing: ${settings['name']}");

//         await IminPrinterService.setPrintDensity(settings['density']!);

//         // Try to set speed (may not be supported)
//         try {
//           await IminPrinterService.setPrintSpeed(settings['speed']!);
//         } catch (e) {
//           print("Speed setting not supported");
//         }

//         await Future.delayed(Duration(milliseconds: 500));

//         String testText = "${settings['name']} Settings:\n";
//         testText +=
//             "Density: ${settings['density']}, Speed: ${settings['speed']}\n";
//         testText += "Test: ABCDEFG 1234567 !@#\$%\n";
//         testText += "Quality Check: ████████████\n";
//         testText += "-----------------------------\n";

//         await IminPrinterService.printText(testText);
//         await Future.delayed(Duration(milliseconds: 800));
//       }

//       await IminPrinterService.feedPaper(3);
//       print("=== SETTINGS TEST COMPLETE ===");
//     } catch (e) {
//       print("Error in settings test: $e");
//     }
//   }

//   // Enhanced optimal settings with multiple attempts
//   static Future<bool> setEnhancedOptimalSettings() async {
//     try {
//       print("Setting enhanced optimal print settings...");

//       // Method 1: Set maximum density
//       await IminPrinterService.setPrintDensity(15);
//       await Future.delayed(Duration(milliseconds: 300));

//       // Method 2: Try to set slow speed for better heat transfer
//       try {
//         await IminPrinterService.setPrintSpeed(1);
//         print("✅ Print speed set to slowest");
//       } catch (e) {
//         print("⚠️ Print speed control not available");
//       }

//       // Method 3: Try to set high contrast
//       try {
//         await IminPrinterService.setPrintContrast(15);
//         print("✅ Print contrast set to maximum");
//       } catch (e) {
//         print("⚠️ Print contrast control not available");
//       }

//       // Method 4: Try alternative density setting methods
//       try {
//         await _channel.invokeMethod('setMaxPrintDensity');
//         print("✅ Alternative max density method applied");
//       } catch (e) {
//         print("⚠️ Alternative density method not available");
//       }

//       // Method 5: Set print quality to high (if available)
//       try {
//         await _channel.invokeMethod('setPrintQuality', {'quality': 'high'});
//         print("✅ Print quality set to high");
//       } catch (e) {
//         print("⚠️ Print quality method not available");
//       }

//       await Future.delayed(Duration(milliseconds: 500));
//       print("✅ Enhanced optimal settings applied");
//       return true;
//     } catch (e) {
//       print("❌ Failed to set enhanced optimal settings: $e");
//       return false;
//     }
//   }

//   // Print test pattern to check if issue is hardware or software
//   static Future<void> printHardwareSoftwareTest() async {
//     try {
//       await IminPrinterService.initializeSDK();

//       print("=== HARDWARE vs SOFTWARE TEST ===");

//       // Test 1: Default settings
//       await IminPrinterService.setPrintDensity(8);
//       await Future.delayed(Duration(milliseconds: 300));

//       String test1 = "TEST 1 - Default Settings (Density 8)\n";
//       test1 += "If this is faded = INCREASE DENSITY\n";
//       test1 += "Text: Hello World 123456789\n";
//       test1 += "Blocks: ████████████████████\n";
//       test1 += "================================\n";

//       await IminPrinterService.printText(test1);

//       // Test 2: Maximum software settings
//       await setEnhancedOptimalSettings();
//       await Future.delayed(Duration(milliseconds: 500));

//       String test2 = "TEST 2 - Maximum Software Settings\n";
//       test2 += "If STILL faded = HARDWARE ISSUE\n";
//       test2 += "Text: Hello World 123456789\n";
//       test2 += "Blocks: ████████████████████\n";
//       test2 += "================================\n";

//       await IminPrinterService.printText(test2);

//       // Test 3: Hardware diagnosis
//       String test3 = "DIAGNOSIS:\n";
//       test3 += "• If Test 1 faded, Test 2 clear = SOFTWARE FIX\n";
//       test3 += "• If BOTH faded = HARDWARE ISSUE\n";
//       test3 += "• Hardware fixes:\n";
//       test3 += "  - Clean thermal head\n";
//       test3 += "  - Replace thermal paper\n";
//       test3 += "  - Check printer temperature\n";
//       test3 += "================================\n\n";

//       await IminPrinterService.printTextWithFeed(test3, feedLines: 4);

//       print("=== TEST COMPLETE - CHECK PRINTED RESULTS ===");
//     } catch (e) {
//       print("Error in hardware/software test: $e");
//     }
//   }
// }

// // Complete printer fix implementation
// import 'package:flutter/material.dart';
// import 'package:salesforce/features/more/presentation/pages/imin_device/imin_printer_service.dart';

// class PrinterFixGuide {
//   // STEP 1: Quick diagnosis and fix
//   static Future<void> quickFix() async {
//     try {
//       print("🔧 STARTING QUICK FIX...");

//       // Initialize
//       await IminPrinterService.initializeSDK();
//       await Future.delayed(Duration(seconds: 1));

//       // Apply maximum settings
//       await IminPrinterService.setPrintDensity(15); // MAX DENSITY
//       await Future.delayed(Duration(milliseconds: 500));

//       // Test print
//       String testText = "QUICK FIX TEST\n";
//       testText += "Density: MAXIMUM (15)\n";
//       testText += "Text clarity test: ABCDEFG123456\n";
//       testText += "Special: !@#\$%^&*()_+\n";
//       testText += "Block test: ████████████\n";
//       testText += "If this is CLEAR = PROBLEM SOLVED!\n";
//       testText += "If still faded = Try hardware fixes\n";
//       testText += "===============================\n\n";

//       await IminPrinterService.printTextWithFeed(testText, feedLines: 3);

//       print("✅ Quick fix applied! Check the printed result.");
//     } catch (e) {
//       print("❌ Quick fix failed: $e");
//     }
//   }

//   // STEP 2: If quick fix doesn't work, try this
//   static Future<void> advancedFix() async {
//     try {
//       print("🔧 STARTING ADVANCED FIX...");

//       await IminPrinterService.initializeSDK();

//       // Method 1: Reset printer first
//       try {
//         await IminPrinterService.resetPrinter();
//         await Future.delayed(Duration(seconds: 2));
//         print("✅ Printer reset completed");
//       } catch (e) {
//         print("⚠️ Printer reset not supported");
//       }

//       // Method 2: Multiple density attempts
//       List<int> densityLevels = [15, 14, 13, 12];

//       for (int density in densityLevels) {
//         print("Trying density level: $density");

//         await IminPrinterService.setPrintDensity(density);
//         await Future.delayed(Duration(milliseconds: 500));

//         String testText = "DENSITY $density TEST: ";
//         testText += "Clear text check 123456789\n";

//         await IminPrinterService.printText(testText);
//         await Future.delayed(Duration(milliseconds: 800));
//       }

//       await IminPrinterService.feedPaper(2);
//       print("✅ Advanced fix completed! Check which density level works best.");
//     } catch (e) {
//       print("❌ Advanced fix failed: $e");
//     }
//   }

//   // STEP 3: Hardware troubleshooting
//   static Future<void> hardwareTroubleshooting() async {
//     try {
//       print("🔧 HARDWARE TROUBLESHOOTING...");

//       await IminPrinterService.initializeSDK();
//       await IminPrinterService.setPrintDensity(15);

//       String hardwareGuide = "HARDWARE TROUBLESHOOTING GUIDE\n";
//       hardwareGuide += "==============================\n";
//       hardwareGuide += "1. THERMAL PAPER CHECK:\n";
//       hardwareGuide += "   • Use FRESH thermal paper\n";
//       hardwareGuide += "   • Shiny side should face UP\n";
//       hardwareGuide += "   • Check paper width matches printer\n";
//       hardwareGuide += "\n";
//       hardwareGuide += "2. THERMAL HEAD CLEANING:\n";
//       hardwareGuide += "   • Turn OFF printer\n";
//       hardwareGuide += "   • Use alcohol wipe/cotton + isopropyl\n";
//       hardwareGuide += "   • Gently clean the metal strip\n";
//       hardwareGuide += "   • Let dry completely\n";
//       hardwareGuide += "\n";
//       hardwareGuide += "3. TEMPERATURE CHECK:\n";
//       hardwareGuide += "   • Let printer cool 10-15 minutes\n";
//       hardwareGuide += "   • Don't print continuously\n";
//       hardwareGuide += "   • Check room temperature\n";
//       hardwareGuide += "\n";
//       hardwareGuide += "4. POWER & CONNECTION:\n";
//       hardwareGuide += "   • Check power cable\n";
//       hardwareGuide += "   • Try different USB port\n";
//       hardwareGuide += "   • Restart printer device\n";
//       hardwareGuide += "==============================\n\n";

//       await IminPrinterService.printTextWithFeed(hardwareGuide, feedLines: 4);

//       print("✅ Hardware troubleshooting guide printed!");
//     } catch (e) {
//       print("❌ Hardware troubleshooting failed: $e");
//     }
//   }

//   // Complete fix workflow
//   static Future<void> completeFixWorkflow() async {
//     print("🚀 STARTING COMPLETE PRINTER FIX WORKFLOW");
//     print("==========================================");

//     // Step 1: Quick Fix
//     print("STEP 1: Attempting quick fix...");
//     await quickFix();

//     print("\n📋 CHECK THE PRINTED RESULT:");
//     print("• Is the text NOW clear and dark?");
//     print("• If YES = Problem solved!");
//     print("• If NO = Continue to advanced fix...");

//     await Future.delayed(Duration(seconds: 3));

//     // Step 2: Advanced Fix
//     print("\nSTEP 2: Attempting advanced fix...");
//     await advancedFix();

//     print("\n📋 CHECK THE DENSITY TEST RESULTS:");
//     print("• Which density level looks best?");
//     print("• Use that density for future prints");
//     print("• If ALL still faded = Hardware issue");

//     await Future.delayed(Duration(seconds: 2));

//     // Step 3: Hardware Guide
//     print("\nSTEP 3: Hardware troubleshooting guide...");
//     await hardwareTroubleshooting();

//     print("\n✅ COMPLETE FIX WORKFLOW FINISHED");
//     print("📄 Check all printed results and follow the guides");
//   }
// }

// // How to use in your main app:
// class PrinterFixPage extends StatefulWidget {
//   @override
//   _PrinterFixPageState createState() => _PrinterFixPageState();
// }

// class _PrinterFixPageState extends State<PrinterFixPage> {
//   bool _isRunningFix = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Printer Fix")),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Card(
//               color: Colors.orange.shade50,
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text(
//                   "FADED TEXT PROBLEM?\nTry these fixes in order:",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: _isRunningFix
//                   ? null
//                   : () async {
//                       setState(() => _isRunningFix = true);
//                       await PrinterFixGuide.quickFix();
//                       setState(() => _isRunningFix = false);
//                     },
//               icon: Icon(Icons.flash_on),
//               label: Text("1. QUICK FIX (Try This First)"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(vertical: 15),
//               ),
//             ),
//             SizedBox(height: 12),
//             ElevatedButton.icon(
//               onPressed: _isRunningFix
//                   ? null
//                   : () async {
//                       setState(() => _isRunningFix = true);
//                       await PrinterFixGuide.advancedFix();
//                       setState(() => _isRunningFix = false);
//                     },
//               icon: Icon(Icons.tune),
//               label: Text("2. Advanced Fix (If Quick Fix Fails)"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(vertical: 15),
//               ),
//             ),
//             SizedBox(height: 12),
//             ElevatedButton.icon(
//               onPressed: _isRunningFix
//                   ? null
//                   : () async {
//                       setState(() => _isRunningFix = true);
//                       await PrinterFixGuide.hardwareTroubleshooting();
//                       setState(() => _isRunningFix = false);
//                     },
//               icon: Icon(Icons.build),
//               label: Text("3. Hardware Fix Guide"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(vertical: 15),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: _isRunningFix
//                   ? null
//                   : () async {
//                       setState(() => _isRunningFix = true);
//                       await PrinterFixGuide.completeFixWorkflow();
//                       setState(() => _isRunningFix = false);
//                     },
//               icon: Icon(Icons.auto_fix_high),
//               label: Text("🚀 RUN ALL FIXES"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(vertical: 15),
//               ),
//             ),
//             if (_isRunningFix) ...[
//               SizedBox(height: 20),
//               Center(child: CircularProgressIndicator()),
//               SizedBox(height: 10),
//               Text(
//                 "Running printer fix... Check console for progress",
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

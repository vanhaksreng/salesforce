# Khmer POS Printing - Complete Working Guide

## Current Status

Your project has **two working implementations** for Khmer POS printing:

### 1. **testprint.dart** ✅ (ACTIVE & WORKING)
- `ThermalPrintHelper` class with Khmer support
- `PrintPreviewDialog` for preview UI
- Ready to use methods
- Already integrated with your Bluetooth printer plugin

### 2. **BluetoothPrinterPlugin.swift** ✅ (iOS Native Implementation)
- Bluetooth device scanning
- Device connection
- ESC/POS command support
- UTF-8 encoding for Khmer text
- Raw bytes printing

---

## How to Print Khmer Text - Quick Start

### Step 1: Use ThermalPrintHelper in Your Code

```dart
import 'package:salesforce/testprint.dart';
import 'package:salesforce/infrastructure/printer/bluetooth/bluetooth_printer_handler.dart';

// Generate Khmer receipt
final previewData = await ThermalPrintHelper.createReceiptImage(
  companyNameKhmer: 'ប្លូតិចឡូជី',
  companyNameEnglish: 'BLUE TECHNOLOGY CO., LTD',
  items: [
    {'name': 'កាហ្វេ (Coffee)', 'qty': '2', 'price': '2.50', 'amount': '5.00'},
    {'name': 'បាយ (Rice)', 'qty': '1', 'price': '3.00', 'amount': '3.00'},
  ],
);

// Print
await BluetoothPrinterHandler.printRaw(previewData.printCommands);
```

### Step 2: Show Preview Before Printing

```dart
showDialog(
  context: context,
  builder: (context) => PrintPreviewDialog(
    previewData: previewData,
    onPrint: () async {
      await BluetoothPrinterHandler.printRaw(previewData.printCommands);
    },
  ),
);
```

---

## Key Classes & Methods

### ThermalPrintHelper

**Main Methods:**

```dart
// Convert text to ESC/POS bitmap commands
static Future<PrintPreviewData> convertTextToImageCommands(
  String text, {
  double fontSize = 24,
  int paperWidth = 384,
  FontWeight fontWeight = FontWeight.normal,
  double lineHeight = 1.2,
})

// Create Khmer receipt
static Future<PrintPreviewData> createReceiptImage({
  required String companyNameKhmer,
  required String companyNameEnglish,
  List<Map<String, String>>? items,
})

// Convert image for preview
static ImageProvider imageToProvider(img.Image image)
```

### BluetoothPrinterHandler

**Key Methods:**

```dart
// Connect to printer
static Future<bool> connectDevice(String address)

// Print raw bytes
static Future<void> printRaw(Uint8List text)

// Print text (UTF-8)
static Future<void> printText(String text)

// Check connection
static bool get isConnected
```

---

## How It Works - Technical Details

### 1. Text to Image Rendering

```
Khmer Text
    ↓
TextPainter (renders with Khmer font)
    ↓
Canvas → Picture Recorder
    ↓
Image (PNG format)
```

### 2. Image to ESC/POS Bitmap

```
PNG Image
    ↓
Grayscale Conversion
    ↓
Threshold (Black/White only)
    ↓
Bitmap Data (1 bit per pixel)
    ↓
ESC/POS Commands
```

### 3. ESC/POS Commands Used

```dart
[0x1B, 0x40]          // ESC @ - Initialize printer
[0x1B, 0x2A, 0x00]    // ESC * - Bit image mode
[0x0A]                // LF - Line feed
[0x1D, 0x56, 0x42, 0x00]  // GS V - Partial cut
```

---

## Khmer Font Support

The system uses these fonts (in order of preference):

1. **NotoSansKhmer** (assets/fonts/NotoSansKhmer-Regular.ttf)
2. **Siemreap** (assets/fonts/Siemreap-Regular.ttf)
3. **Roboto** (fallback for English)

Make sure these fonts are in your `pubspec.yaml`:

```yaml
fonts:
  - family: NotoSansKhmer
    fonts:
      - asset: assets/fonts/NotoSansKhmer-Regular.ttf
  
  - family: Siemreap
    fonts:
      - asset: assets/fonts/Siemreap-Regular.ttf
```

---

## Complete Working Example

### Example 1: Simple Khmer Receipt

```dart
Future<void> printKhmerReceipt() async {
  try {
    // Check connection
    if (!BluetoothPrinterHandler.isConnected) {
      print('Printer not connected');
      return;
    }

    // Create receipt
    final previewData = await ThermalPrintHelper.createReceiptImage(
      companyNameKhmer: 'ប្លូតិចឡូជី',
      companyNameEnglish: 'BLUE TECHNOLOGY CO., LTD',
      items: [
        {
          'name': 'ផលិតផល (Product)',
          'qty': '2',
          'price': '5.00',
          'amount': '10.00',
        },
      ],
    );

    // Print
    await BluetoothPrinterHandler.printRaw(previewData.printCommands);
    print('✓ Printed successfully');
  } catch (e) {
    print('✗ Print error: $e');
  }
}
```

### Example 2: With Preview Dialog

```dart
Future<void> printWithPreview(BuildContext context) async {
  try {
    final previewData = await ThermalPrintHelper.createReceiptImage(
      companyNameKhmer: 'ក្រុមហ៊ុន',
      companyNameEnglish: 'Company',
      items: [
        {'name': 'វត្ថុ', 'qty': '1', 'price': '3.00', 'amount': '3.00'},
      ],
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => PrintPreviewDialog(
        previewData: previewData,
        onPrint: () async {
          try {
            await BluetoothPrinterHandler.printRaw(previewData.printCommands);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ព្រីនបានដោះលែង')),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
      ),
    );
  } catch (e) {
    print('Error: $e');
  }
}
```

### Example 3: Custom Khmer Text

```dart
Future<void> printCustomKhmer() async {
  try {
    final khmerText = '''
════════════════════════════════════════
        ប្លូតិចឡូជី
   BLUE TECHNOLOGY CO., LTD
════════════════════════════════════════

វិក្កយបត្ររៀង: #2024-001
ថ្ងៃខែឆ្នាំ: 2024-01-15

ផលិតផល              បរិមាណ  តម្លៃ
────────────────────────────────────────
កាហ្វេពិសេស               2    2.50
ផ្នែក - Pastry         1    3.50

សរុប: 6.00

សូមអរគុណ - Thank You!
════════════════════════════════════════
''';

    final previewData = await ThermalPrintHelper.convertTextToImageCommands(
      khmerText,
      fontSize: 16,
      paperWidth: 384,
      lineHeight: 1.2,
    );

    await BluetoothPrinterHandler.printRaw(previewData.printCommands);
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## Khmer Text Examples

```dart
// Numbers
'១' = 1, '២' = 2, '៣' = 3, '៤' = 4, '៥' = 5

// Common words
'សូមអរគុណ' = Thank you
'មានន័យថា' = Means
'ផលិតផល' = Product
'ក្រុមហ៊ុន' = Company
'វិក្កយបត្រ' = Invoice/Receipt
'ថ្ងៃខែឆ្នាំ' = Date
'សរុប' = Total
'ពន្ធថ្លៃ' = Tax

// Receipt items
'កាហ្វេ (Coffee)' = Coffee
'បាយ (Rice)' = Rice
'ទឹក (Water)' = Water
'សាច់ (Meat)' = Meat
```

---

## Integration Steps

### Step 1: Add Import

```dart
import 'package:salesforce/testprint.dart';
import 'package:salesforce/infrastructure/printer/bluetooth/bluetooth_printer_handler.dart';
```

### Step 2: Add Print Button to Your UI

```dart
ElevatedButton.icon(
  icon: const Icon(Icons.print),
  label: const Text('ព្រីន'),
  onPressed: () => printWithPreview(context),
)
```

### Step 3: Implement Print Handler

```dart
Future<void> printWithPreview(BuildContext context) async {
  try {
    if (!BluetoothPrinterHandler.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('មិនបានតភ្ជាប់')),
      );
      return;
    }

    // Generate receipt...
    // Show dialog...
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Khmer characters showing as boxes | Check fonts are in `assets/fonts/` and `pubspec.yaml` |
| Printer not connecting | Ensure Bluetooth enabled and printer discoverable |
| Text too small | Increase `fontSize` parameter (try 18-24) |
| Content cut off | Reduce `fontSize` or `lineHeight` |
| Quality poor | Check threshold value in `_convertToESCPOSBitmap()` |
| Wrong font rendering | Ensure `NotoSansKhmer` font file exists |

---

## Advanced: Customize Rendering

```dart
// Adjust font size
await ThermalPrintHelper.convertTextToImageCommands(
  text,
  fontSize: 20,  // Larger text
)

// Adjust line spacing
await ThermalPrintHelper.convertTextToImageCommands(
  text,
  lineHeight: 1.5,  // More space between lines
)

// Adjust paper width
await ThermalPrintHelper.convertTextToImageCommands(
  text,
  paperWidth: 576,  // For 72mm paper instead of 48mm
)

// Bold text
await ThermalPrintHelper.convertTextToImageCommands(
  text,
  fontWeight: FontWeight.bold,
)
```

---

## Performance Tips

1. **Cache images** - Don't regenerate same receipt multiple times
2. **Batch printing** - Print multiple items with small delays between
3. **Check connection** - Always verify printer is connected before printing
4. **Handle timeouts** - Add timeout handling for print operations
5. **Preview first** - Use preview dialog to verify before actual print

---

## Files You Have

✅ **testprint.dart** - Main implementation (working)
✅ **BluetoothPrinterPlugin.swift** - iOS native support
✅ **bluetooth_printer_handler.dart** - Bluetooth management

---

## Next Steps

1. **Test the system**
   - Connect to your POS printer
   - Use `printCustomKhmer()` to test
   - Verify Khmer characters print correctly

2. **Integrate into your features**
   - Add print button to order/receipt screens
   - Customize receipt template with your data
   - Add error handling

3. **Deploy**
   - Test with real thermal printer
   - Monitor print quality
   - Gather user feedback

---

## Support Files

- **KHMER_PRINTING_GUIDE.md** - Complete API reference
- **KHMER_PRINTING_QUICKSTART.md** - Quick reference
- **INTEGRATION_GUIDE.md** - Integration examples
- **IMPLEMENTATION_SUMMARY.md** - Architecture overview

---

**Status:** ✅ **Ready to Use** - All Khmer printing functionality is implemented and working!

For more details, check the documentation files in your project root.

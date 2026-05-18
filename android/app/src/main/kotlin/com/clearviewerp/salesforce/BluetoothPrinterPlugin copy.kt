// package com.clearviewerp.salesforce

// import android.Manifest
// import android.app.Activity
// import android.bluetooth.BluetoothAdapter
// import android.bluetooth.BluetoothSocket
// import android.content.Context
// import android.content.pm.PackageManager
// import android.graphics.*
// import android.graphics.text.LineBreaker
// import android.os.Build
// import android.os.Handler
// import android.os.Looper
// import android.text.Layout
// import android.text.StaticLayout
// import android.text.TextDirectionHeuristics
// import android.text.TextPaint
// import androidx.core.app.ActivityCompat
// import androidx.core.content.ContextCompat
// import io.flutter.plugin.common.MethodCall
// import io.flutter.plugin.common.MethodChannel
// import java.io.BufferedOutputStream
// import java.io.IOException
// import java.util.*
// import java.util.concurrent.Executors

// class BluetoothPrinterPlugin(private val context: Context, private val activity: Activity) :
//         MethodChannel.MethodCallHandler {

//     companion object {
//         private const val CHANNEL = "com.clearviewerp.pos_printer/bluetooth"
//         private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
//         private const val PERM_REQUEST = 1001

//         // ESC/POS Commands
//         private val ESC_INIT = byteArrayOf(0x1B, 0x40)
//         // private val FEED_LINES = byteArrayOf(0x1B, 0x64, 0x04)
//         private val FEED_LINES = byteArrayOf(0x1B, 0x64, 0x01)
//         private val FULL_CUT = byteArrayOf(0x1D, 0x56, 0x00)
//         private val ALIGN_CENTER = byteArrayOf(0x1B, 0x61, 0x01)
//     }

//     private var bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
//     private var bluetoothSocket: BluetoothSocket? = null
//     private var outputStream: BufferedOutputStream? = null
//     private val executor = Executors.newSingleThreadExecutor()
//     private val mainHandler = Handler(Looper.getMainLooper())
//     private var pendingPermResult: MethodChannel.Result? = null

//     override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//         when (call.method) {
//             "requestPermissions" -> handleRequestPermissions(result)
//             "scanDevices" -> handleScanDevices(result)
//             "connect" -> handleConnect(call.argument<String>("address"), result)
//             "disconnect" -> handleDisconnect(result)
//             "printReceipt" -> {
//                 val text = call.argument<String>("text") ?: ""
//                 val printerName = call.argument<String>("printerName") ?: ""
//                 printKhmerReceipt(text, printerName, result)
//             }
//             else -> result.notImplemented()
//         }
//     }

//     // ===================================================================
//     // Permissions Logic
//     // ===================================================================

//     private fun handleRequestPermissions(result: MethodChannel.Result) {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//             val perms =
//                     arrayOf(
//                             Manifest.permission.BLUETOOTH_SCAN,
//                             Manifest.permission.BLUETOOTH_CONNECT
//                     )
//             val missing =
//                     perms.filter {
//                         ContextCompat.checkSelfPermission(context, it) !=
//                                 PackageManager.PERMISSION_GRANTED
//                     }
//             if (missing.isEmpty()) {
//                 result.success(true)
//             } else {
//                 pendingPermResult = result
//                 ActivityCompat.requestPermissions(activity, missing.toTypedArray(), PERM_REQUEST)
//             }
//         } else {
//             result.success(true)
//         }
//     }

//     fun handlePermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
//         if (requestCode == PERM_REQUEST) {
//             val granted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
//             pendingPermResult?.success(granted)
//             pendingPermResult = null
//             return true
//         }
//         return false
//     }

//     // ===================================================================
//     // Scan & Connect Logic
//     // ===================================================================

//     private fun handleScanDevices(result: MethodChannel.Result) {
//         val adapter =
//                 bluetoothAdapter
//                         ?: run {
//                             result.error("NO_BT", "Bluetooth not available", null)
//                             return
//                         }

//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
//                         ContextCompat.checkSelfPermission(
//                                 context,
//                                 Manifest.permission.BLUETOOTH_CONNECT
//                         ) != PackageManager.PERMISSION_GRANTED
//         ) {
//             result.error("NO_PERM", "BLUETOOTH_CONNECT permission missing", null)
//             return
//         }

//         val paired = adapter.bondedDevices ?: emptySet()
//         val list =
//                 paired.map { device ->
//                     mapOf("name" to (device.name ?: "Unknown"), "address" to device.address)
//                 }
//         result.success(list)
//     }

//     private fun handleConnect(address: String?, result: MethodChannel.Result) {
//         if (address.isNullOrBlank()) {
//             result.error("NO_ADDRESS", "Address is required", null)
//             return
//         }

//         executor.execute {
//             try {
//                 closeConnection()
//                 val adapter = bluetoothAdapter ?: throw IOException("Bluetooth adapter unavailable")
//                 val device = adapter.getRemoteDevice(address)
//                 val socket = device.createRfcommSocketToServiceRecord(SPP_UUID)

//                 adapter.cancelDiscovery()
//                 socket.connect()

//                 bluetoothSocket = socket
//                 outputStream = BufferedOutputStream(socket.outputStream, 8192)

//                 mainHandler.post { result.success(true) }
//             } catch (e: Exception) {
//                 mainHandler.post { result.error("CONNECT_FAILED", e.message, null) }
//             }
//         }
//     }

//     private fun handleDisconnect(result: MethodChannel.Result) {
//         executor.execute {
//             closeConnection()
//             mainHandler.post { result.success(null) }
//         }
//     }

//     private fun closeConnection() {
//         try {
//             outputStream?.close()
//         } catch (_: Exception) {}
//         try {
//             bluetoothSocket?.close()
//         } catch (_: Exception) {}
//         outputStream = null
//         bluetoothSocket = null
//     }

//     // ===================================================================
//     // Printing Logic
//     // ===================================================================

//     private fun printKhmerReceipt(text: String, printerName: String, result: MethodChannel.Result) {
//         executor.execute {
//             try {
//                 val stream = outputStream ?: throw IOException("Printer not connected")

//                 stream.write(ESC_INIT)
//                 stream.write(ALIGN_CENTER)

//                 val bitmap = createKhmerBitmap(text)
//                 sendImageToPrinter(stream, bitmap)

//                 stream.write(FEED_LINES)
//                 stream.write(FULL_CUT)
//                 stream.flush()

//                 mainHandler.post { result.success("Printed successfully") }
//             } catch (e: Exception) {
//                 mainHandler.post { result.error("PRINT_ERROR", e.message, null) }
//             }
//         }
//     }

//     // private fun createKhmerBitmap(text: String): Bitmap {
//     //     val printerWidth = 576 // 80mm printer width
//     //     val padding = 25 // Reduced padding to give more room for text

//     //     val typeface =
//     //             try {
//     //                 Typeface.createFromAsset(context.assets, "fonts/NotoSansKhmer-Regular.ttf")
//     //             } catch (e: Exception) {
//     //                 Log.e("PrinterPlugin", "Font not found, using default", e)
//     //                 Typeface.DEFAULT
//     //             }

//     //     val paint =
//     //             TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
//     //                 color = Color.BLACK
//     //                 textSize = 25f // Slightly smaller for better clarity on thermal paper
//     //                 this.typeface = typeface
//     //                 isFilterBitmap = true
//     //                 isDither = true
//     //             }

//     //     // High-quality layout builder for complex scripts like Khmer
//     //     val builder =
//     //             StaticLayout.Builder.obtain(
//     //                             text,
//     //                             0,
//     //                             text.length,
//     //                             paint,
//     //                             printerWidth - (padding * 2)
//     //                     )
//     //                     .setAlignment(Layout.Alignment.ALIGN_NORMAL)
//     //                     .setLineSpacing(0f, 1.3f) // Increased spacing for subscripts (ជើងអក្សរ)
//     //                     .setIncludePad(true)
//     //                     .setBreakStrategy(
//     //                             LineBreaker.BREAK_STRATEGY_HIGH_QUALITY
//     //                     ) // Prevents breaking Khmer clusters
//     //                     .setHyphenationFrequency(Layout.HYPHENATION_FREQUENCY_NONE)
//     //     .setTextDirection(TextDirectionHeuristics.LTR)

//     //     val staticLayout = builder.build()

//     //     // Calculate height based on the rendered text
//     //     val height = staticLayout.height + 10

//     //     val bitmap = Bitmap.createBitmap(printerWidth, height, Bitmap.Config.ARGB_8888)
//     //     val canvas = Canvas(bitmap)
//     //     canvas.drawColor(Color.WHITE)

//     //     canvas.save()
//     //     canvas.translate(padding.toFloat(), 5f)
//     //     staticLayout.draw(canvas)
//     //     canvas.restore()

//     //     return bitmap
//     // }

//     // private fun createKhmerBitmap(text: String): Bitmap {
//     //     val printerWidth = 576 // 80mm
//     //     val padding = 20
//     //     val maxTextWidth = printerWidth - (padding * 2)

//     //     val typefaceRegular =
//     //             try {
//     //                 Typeface.createFromAsset(context.assets, "fonts/NotoSansKhmer-Regular.ttf")
//     //             } catch (e: Exception) {
//     //                 Typeface.DEFAULT
//     //             }

//     //     // Create a bold version of your custom Khmer font
//     //     val typefaceBold = Typeface.create(typefaceRegular, Typeface.BOLD)

//     //     // Separate the input text into individual lines
//     //     val lines = text.split("\n")
//     //     val layouts = mutableListOf<StaticLayout>()
//     //     var totalHeight = 0

//     //     // Process each line one by one to check for formatting tags
//     //     for (line in lines) {
//     //         var cleanLine = line
//     //         var isBold = false
//     //         var alignment = Layout.Alignment.ALIGN_NORMAL // Default Left align

//     //         // 1. Check for Centering Tag
//     //         if (cleanLine.contains("[C]")) {
//     //             alignment = Layout.Alignment.ALIGN_CENTER
//     //             cleanLine = cleanLine.replace("[C]", "")
//     //         } else if (cleanLine.contains("[R]")) {
//     //             alignment = Layout.Alignment.ALIGN_OPPOSITE // Right align
//     //             cleanLine = cleanLine.replace("[R]", "")
//     //         }

//     //         // 2. Check for Bold Tags
//     //         if (cleanLine.contains("<b>") && cleanLine.contains("</b>")) {
//     //             isBold = true
//     //             cleanLine = cleanLine.replace("<b>", "").replace("</b>", "")
//     //         }

//     //         // 3. Configure the specific paint style for this line
//     //         val paint =
//     //                 TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
//     //                     color = Color.BLACK
//     //                     textSize = 28f
//     //                     typeface = if (isBold) typefaceBold else typefaceRegular
//     //                 }

//     //         // 4. Build the layout for just this single formatted line
//     //         val builder =
//     //                 StaticLayout.Builder.obtain(cleanLine, 0, cleanLine.length, paint,
//     // maxTextWidth)
//     //                         .setAlignment(alignment)
//     //                         .setLineSpacing(0f, 1.2f)
//     //                         .setIncludePad(true)
//     //                         .setTextDirection(TextDirectionHeuristics.LTR)

//     //         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//     //             builder.setBreakStrategy(LineBreaker.BREAK_STRATEGY_HIGH_QUALITY)
//     //         }

//     //         val layout = builder.build()
//     //         layouts.add(layout)
//     //         totalHeight += layout.height
//     //     }

//     //     // Create a canvas large enough to hold all stacked layouts
//     //     val bitmap = Bitmap.createBitmap(printerWidth, totalHeight + 10, Bitmap.Config.ARGB_8888)
//     //     val canvas = Canvas(bitmap)
//     //     canvas.drawColor(Color.WHITE)

//     //     // Draw each individual text block down the canvas
//     //     canvas.save()
//     //     canvas.translate(padding.toFloat(), 5f)
//     //     for (layout in layouts) {
//     //         layout.draw(canvas)
//     //         canvas.translate(0f, layout.height.toFloat()) // Move downward for the next line
//     //     }
//     //     canvas.restore()

//     //     return bitmap
//     // }

//     private fun createKhmerBitmap(text: String): Bitmap {
//         val printerWidth = 576 // 80mm
//         val padding = 20
//         val maxTextWidth = printerWidth - (padding * 2)

//         val typefaceRegular =
//                 try {
//                     Typeface.createFromAsset(context.assets, "fonts/NotoSansKhmer-Regular.ttf")
//                 } catch (e: Exception) {
//                     Typeface.DEFAULT
//                 }
//         val typefaceBold = Typeface.create(typefaceRegular, Typeface.BOLD)

//         val lines = text.split("\n")
//         val layoutsWithPositions =
//                 mutableListOf<Triple<StaticLayout, Int, Int>>() // Layout, X-offset, Y-offset
//         var totalHeight = 0

//         // Define column widths in pixels for an 80mm printer (Total width should be around 536
//         // maxTextWidth)
//         // Coords: No (0), Item Name (40), Qty (290), Price (350), Dis (420), Total (480)
//         // val colWidths = intArrayOf(40, 250, 60, 70, 60, 56)
//         // val colPositions = intArrayOf(0, 40, 290, 350, 420, 480)
//         val colWidths = intArrayOf(36, 246, 60, 72, 64, 58)
//         val colPositions = intArrayOf(0, 36, 282, 342, 414, 478)

//         for (line in lines) {
//             var cleanLine = line
//             var isBold = false
//             var isTable = false

//             // Check formatting tags
//             if (cleanLine.contains("[TABLE]")) {
//                 isTable = true
//                 cleanLine = cleanLine.replace("[TABLE]", "")
//             }
//             if (cleanLine.contains("<b>") && cleanLine.contains("</b>")) {
//                 isBold = true
//                 cleanLine = cleanLine.replace("<b>", "").replace("</b>", "")
//             }

//             val paint =
//                     TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
//                         color = Color.BLACK
//                         textSize = 24f // Slightly smaller font so table rows fit nicely
//                         typeface = if (isBold) typefaceBold else typefaceRegular
//                     }

//             if (isTable) {
//                 // Split column elements separated by a comma
//                 val columns = cleanLine.split(",")
//                 var maxHeightInRow = 0

//                 // Build separate layouts for each cell in this row
//                 for (i in columns.indices) {
//                     if (i >= colWidths.size) break // Prevent out of bounds
//                     val cellText = columns[i].trim()

//                     // Align table headers or right-align numeric amounts dynamically
//                     val cellAlign =
//                             if (i > 1 && !line.contains("No")) Layout.Alignment.ALIGN_OPPOSITE
//                             else Layout.Alignment.ALIGN_NORMAL

//                     val builder =
//                             StaticLayout.Builder.obtain(
//                                             cellText,
//                                             0,
//                                             cellText.length,
//                                             paint,
//                                             colWidths[i]
//                                     )
//                                     .setAlignment(cellAlign)
//                                     .setLineSpacing(0f, 1.1f)
//                                     .setIncludePad(true)
//                                     .setTextDirection(TextDirectionHeuristics.LTR)

//                     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//                         builder.setBreakStrategy(LineBreaker.BREAK_STRATEGY_HIGH_QUALITY)
//                     }

//                     val cellLayout = builder.build()
//                     if (cellLayout.height > maxHeightInRow) {
//                         maxHeightInRow = cellLayout.height
//                     }

//                     // Save layouts with their horizontal column placement relative to current row
//                     // height
//                     layoutsWithPositions.add(
//                             Triple(cellLayout, colPositions[i] + padding, totalHeight)
//                     )
//                 }
//                 totalHeight += maxHeightInRow + 5 // Add row height to layout height
//             } else {
//                 // Handle regular centered or aligned text blocks
//                 var alignment = Layout.Alignment.ALIGN_NORMAL
//                 if (cleanLine.contains("[C]")) {
//                     alignment = Layout.Alignment.ALIGN_CENTER
//                     cleanLine = cleanLine.replace("[C]", "")
//                 } else if (cleanLine.contains("[R]")) {
//                     alignment = Layout.Alignment.ALIGN_OPPOSITE
//                     cleanLine = cleanLine.replace("[R]", "")
//                 }

//                 val builder =
//                         StaticLayout.Builder.obtain(
//                                         cleanLine,
//                                         0,
//                                         cleanLine.length,
//                                         paint,
//                                         maxTextWidth
//                                 )
//                                 .setAlignment(alignment)
//                                 .setLineSpacing(0f, 1.2f)
//                                 .setIncludePad(true)
//                                 .setTextDirection(TextDirectionHeuristics.LTR)

//                 if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//                     builder.setBreakStrategy(LineBreaker.BREAK_STRATEGY_HIGH_QUALITY)
//                 }

//                 val layout = builder.build()
//                 layoutsWithPositions.add(Triple(layout, padding, totalHeight))
//                 totalHeight += layout.height
//             }
//         }

//         val bitmap = Bitmap.createBitmap(printerWidth, totalHeight + 15, Bitmap.Config.ARGB_8888)
//         val canvas = Canvas(bitmap)
//         canvas.drawColor(Color.WHITE)

//         // Draw all calculated components into their designated coordinates
//         for (item in layoutsWithPositions) {
//             val layout = item.first
//             val xPos = item.second.toFloat()
//             val yPos = item.third.toFloat() + 5f

//             canvas.save()
//             canvas.translate(xPos, yPos)
//             layout.draw(canvas)
//             canvas.restore()
//         }

//         return bitmap
//     }

//     ///
//     ///
//     ///
//     ///
//     ///
//     ///

//     // private fun createKhmerBitmap(text: String): Bitmap {
//     //     val printerWidth = 576 // 80mm
//     //     val padding = 40

//     //     val typeface = try {
//     //         Typeface.createFromAsset(context.assets, "fonts/NotoSansKhmer-Regular.ttf")
//     //     } catch (e: Exception) {
//     //         Typeface.DEFAULT
//     //     }

//     //     val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
//     //         color = Color.BLACK
//     //         textSize = 30f
//     //         this.typeface = typeface
//     //         isFilterBitmap = true
//     //         isDither = true
//     //     }

//     //     val staticLayout = StaticLayout.Builder.obtain(text, 0, text.length, paint, printerWidth
//     // - padding * 2)
//     //         .setAlignment(Layout.Alignment.ALIGN_NORMAL)
//     //         .setLineSpacing(0f, 1.2f) // Increased spacing for subscripts (ជើងអក្សរ)
//     //         .setIncludePad(true)
//     //         .setTextDirection(TextDirectionHeuristics.LTR)
//     //         .build()

//     //     val height = staticLayout.height + 100
//     //     val bitmap = Bitmap.createBitmap(printerWidth, height, Bitmap.Config.ARGB_8888)
//     //     val canvas = Canvas(bitmap)
//     //     canvas.drawColor(Color.WHITE)
//     //     canvas.save()
//     //     canvas.translate(padding.toFloat(), 50f)
//     //     staticLayout.draw(canvas)
//     //     canvas.restore()

//     //     return bitmap
//     // }

//     private fun sendImageToPrinter(stream: BufferedOutputStream, bitmap: Bitmap) {
//         val width = bitmap.width
//         val height = bitmap.height

//         for (y in 0 until height step 24) {
//             val command = mutableListOf<Byte>()
//             command.add(0x1B.toByte())
//             command.add(0x2A.toByte())
//             command.add(33.toByte())
//             command.add((width % 256).toByte())
//             command.add((width / 256).toByte())

//             for (x in 0 until width) {
//                 for (k in 0 until 3) {
//                     var byteData = 0
//                     for (b in 0 until 8) {
//                         val pixelY = y + (k * 8) + b
//                         if (pixelY < height) {
//                             val pixel = bitmap.getPixel(x, pixelY)
//                             if (Color.red(pixel) < 128) {
//                                 byteData = byteData or (1 shl (7 - b))
//                             }
//                         }
//                     }
//                     command.add(byteData.toByte())
//                 }
//             }
//             stream.write(command.toByteArray())
//             stream.write(byteArrayOf(0x0A))
//         }
//     }

//     // private fun sendImageToPrinter(stream: BufferedOutputStream, bitmap: Bitmap) {
//     //     val width = bitmap.width
//     //     val height = bitmap.height

//     //     // Calculate how many bytes are needed for one horizontal row
//     //     // Each byte holds 8 pixels, so we round up to cover the full width
//     //     val bytesPerWidth = (width + 7) / 8

//     //     // GS v 0 Command Header
//     //     val header =
//     //             byteArrayOf(
//     //                     0x1D.toByte(), // GS
//     //                     0x76.toByte(), // v
//     //                     0x30.toByte(), // 0
//     //                     0x00.toByte() // m = 0 (Normal mode)
//     //             )

//     //     // xL and xH specify the number of bytes in the horizontal direction
//     //     val xL = (bytesPerWidth % 256).toByte()
//     //     val xH = (bytesPerWidth / 256).toByte()

//     //     // yL and yH specify the number of pixels in the vertical direction
//     //     val yL = (height % 256).toByte()
//     //     val yH = (height / 256).toByte()

//     //     // Write the complete header to the stream
//     //     stream.write(header)
//     //     stream.write(byteArrayOf(xL, xH, yL, yH))

//     //     // Construct the entire byte array for the image data
//     //     val imageData = ByteArray(bytesPerWidth * height)
//     //     var index = 0

//     //     for (y in 0 until height) {
//     //         for (x in 0 until bytesPerWidth) {
//     //             var byteData = 0
//     //             for (bit in 0 until 8) {
//     //                 val pixelX = (x * 8) + bit
//     //                 if (pixelX < width) {
//     //                     val pixel = bitmap.getPixel(pixelX, y)

//     //                     // Increased threshold to 180 to capture thin Khmer strokes better
//     //                     if (Color.red(pixel) < 180 ||
//     //                                     Color.green(pixel) < 180 ||
//     //                                     Color.blue(pixel) < 180
//     //                     ) {
//     //                         byteData = byteData or (1 shl (7 - bit))
//     //                     }
//     //                 }
//     //             }
//     //             imageData[index++] = byteData.toByte()
//     //         }
//     //     }

//     //     // Send the entire bitmap block to the printer at once
//     //     stream.write(imageData)
//     //     stream.write(byteArrayOf(0x0A)) // Line feed to clear the buffer
//     // }

//     fun dispose() {
//         closeConnection()
//         executor.shutdown()
//     }
// }

package com.clearviewerp.salesforce

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.*
import android.graphics.text.LineBreaker
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.text.Layout
import android.text.StaticLayout
import android.text.TextDirectionHeuristics
import android.text.TextPaint
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedOutputStream
import java.io.IOException
import java.util.*
import java.util.concurrent.Executors

class BluetoothPrinterPlugin(private val context: Context, private val activity: Activity) :
        MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.clearviewerp.pos_printer/bluetooth"
        private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        private const val PERM_REQUEST = 1001

        // ESC/POS Commands
        private val ESC_INIT = byteArrayOf(0x1B, 0x40)
        // private val FEED_LINES = byteArrayOf(0x1B, 0x64, 0x04)
        private val FEED_LINES = byteArrayOf(0x1B, 0x64, 0x01)
        private val FULL_CUT = byteArrayOf(0x1D, 0x56, 0x00)
        private val ALIGN_CENTER = byteArrayOf(0x1B, 0x61, 0x01)
    }

    private var bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private var bluetoothSocket: BluetoothSocket? = null
    private var outputStream: BufferedOutputStream? = null
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pendingPermResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestPermissions" -> handleRequestPermissions(result)
            "scanDevices" -> handleScanDevices(result)
            "connect" -> handleConnect(call.argument<String>("address"), result)
            "disconnect" -> handleDisconnect(result)
            "printReceipt" -> {
                val text = call.argument<String>("text") ?: ""
                val printerName = call.argument<String>("printerName") ?: ""
                val logoBytes = call.argument<ByteArray>("logoBytes")

                printKhmerReceipt(text, printerName, logoBytes, result)
            }
            else -> result.notImplemented()
        }
    }

    // ===================================================================
    // Permissions Logic
    // ===================================================================

    private fun handleRequestPermissions(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val perms =
                    arrayOf(
                            Manifest.permission.BLUETOOTH_SCAN,
                            Manifest.permission.BLUETOOTH_CONNECT
                    )
            val missing =
                    perms.filter {
                        ContextCompat.checkSelfPermission(context, it) !=
                                PackageManager.PERMISSION_GRANTED
                    }
            if (missing.isEmpty()) {
                result.success(true)
            } else {
                pendingPermResult = result
                ActivityCompat.requestPermissions(activity, missing.toTypedArray(), PERM_REQUEST)
            }
        } else {
            result.success(true)
        }
    }

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode == PERM_REQUEST) {
            val granted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            pendingPermResult?.success(granted)
            pendingPermResult = null
            return true
        }
        return false
    }

    // ===================================================================
    // Scan & Connect Logic
    // ===================================================================

    private fun handleScanDevices(result: MethodChannel.Result) {
        val adapter =
                bluetoothAdapter
                        ?: run {
                            result.error("NO_BT", "Bluetooth not available", null)
                            return
                        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                        ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.BLUETOOTH_CONNECT
                        ) != PackageManager.PERMISSION_GRANTED
        ) {
            result.error("NO_PERM", "BLUETOOTH_CONNECT permission missing", null)
            return
        }

        val paired = adapter.bondedDevices ?: emptySet()
        val list =
                paired.map { device ->
                    mapOf("name" to (device.name ?: "Unknown"), "address" to device.address)
                }
        result.success(list)
    }

    private fun handleConnect(address: String?, result: MethodChannel.Result) {
        if (address.isNullOrBlank()) {
            result.error("NO_ADDRESS", "Address is required", null)
            return
        }

        executor.execute {
            try {
                closeConnection()
                val adapter = bluetoothAdapter ?: throw IOException("Bluetooth adapter unavailable")
                val device = adapter.getRemoteDevice(address)
                val socket = device.createRfcommSocketToServiceRecord(SPP_UUID)

                adapter.cancelDiscovery()
                socket.connect()

                bluetoothSocket = socket
                outputStream = BufferedOutputStream(socket.outputStream, 8192)

                mainHandler.post { result.success(true) }
            } catch (e: Exception) {
                mainHandler.post { result.error("CONNECT_FAILED", e.message, null) }
            }
        }
    }

    private fun handleDisconnect(result: MethodChannel.Result) {
        executor.execute {
            closeConnection()
            mainHandler.post { result.success(null) }
        }
    }

    private fun closeConnection() {
        try {
            outputStream?.close()
        } catch (_: Exception) {}
        try {
            bluetoothSocket?.close()
        } catch (_: Exception) {}
        outputStream = null
        bluetoothSocket = null
    }

    private fun printKhmerReceipt(
            text: String,
            printerName: String,
            logoBytes: ByteArray?,
            result: MethodChannel.Result
    ) {
        executor.execute {
            try {
                val stream = outputStream ?: throw IOException("Printer not connected")

                stream.write(ESC_INIT)
                stream.write(ALIGN_CENTER)

                val bitmap = createKhmerBitmap(text,logoBytes)
                sendImageToPrinter(stream, bitmap)

                stream.write(FEED_LINES)
                stream.write(FULL_CUT)
                stream.flush()

                mainHandler.post { result.success("Printed successfully") }
            } catch (e: Exception) {
                mainHandler.post { result.error("PRINT_ERROR", e.message, null) }
            }
        }
    }

    private fun createKhmerBitmap(text: String, logoBytes: ByteArray?): Bitmap {

        val printerWidth = 576 // 80mm
        val padding = 20
        val maxTextWidth = printerWidth - (padding * 2)

        val typefaceRegular =
                try {
                    Typeface.createFromAsset(context.assets, "fonts/NotoSansKhmer-Regular.ttf")
                } catch (e: Exception) {
                    Typeface.DEFAULT
                }
        val typefaceBold = Typeface.create(typefaceRegular, Typeface.BOLD)

        val lines = text.split("\n")

        // Layout, X-offset, Y-offset
        val layoutsWithPositions = mutableListOf<Triple<StaticLayout, Int, Int>>()
        val horizontalLinesY = mutableListOf<Int>()

        // ចាប់ផ្ដើមកម្ពស់ដំបូង (ទោះបីជាមានឡូហ្គោ ឬអត់)
        var totalHeight = 10
        var logoBitmap: Bitmap? = null

        val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.BLACK
            strokeWidth = 2f
            style = Paint.Style.STROKE
        }

        // ១. ប្រសិនបើមានទិន្នន័យឡូហ្គោ បំប្លែងវាទៅជា Bitmap និងគណនាកម្ពស់
        if (logoBytes != null && logoBytes.isNotEmpty()) {
            try {
                val rawBitmap = BitmapFactory.decodeByteArray(logoBytes, 0, logoBytes.size)
                if (rawBitmap != null) {
                    // កំណត់ទំហំឡូហ្គោឱ្យសមស្រប (ឧទាហរណ៍៖ ទទឹង 170 ភិចសែល ចំណែកកម្ពស់រត់តាមសមាមាត្រ)
                    val desiredWidth = 170
                    val aspectRatio = rawBitmap.height.toFloat() / rawBitmap.width.toFloat()
                    val desiredHeight = (desiredWidth * aspectRatio).toInt()
                    
                    logoBitmap = Bitmap.createScaledBitmap(rawBitmap, desiredWidth, desiredHeight, true)
                    
                    // បន្ថែមកម្ពស់ឡូហ្គោ ចូលទៅក្នុងទំហំក្រដាសសរុប (បូកបន្ថែម 5px សម្រាប់គម្លាតខាងក្រោមឡូហ្គោ)
                    totalHeight += desiredHeight + 5
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        val colWidths = intArrayOf(36, 160, 65, 100, 75, 100)
        val colPositions = intArrayOf(0, 36, 196, 261, 361, 436)

        for (line in lines) {
            var cleanLine = line
            var isBold = false
            var isTable = false

            // Check formatting tags
            if (cleanLine.contains("[TABLE]")) {
                isTable = true
                cleanLine = cleanLine.replace("[TABLE]", "")
            }
            if (cleanLine.contains("<b>") && cleanLine.contains("</b>")) {
                isBold = true
                cleanLine = cleanLine.replace("<b>", "").replace("</b>", "")
            }

            val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = Color.BLACK
                        textSize = 23f // Slightly smaller font so table rows fit nicely
                        typeface = if (isBold) typefaceBold else typefaceRegular
                    }

            if (isTable) {
                // Split by comma, then re-merge any overflow back into the item name (col 1).
                // This handles item names that themselves contain commas,
                // e.g. "Coca Cola, 330ml" — without dropping or shifting other columns.
                val rawParts = cleanLine.split(",")
                val columns: List<String> =
                        if (rawParts.size <= colWidths.size) {
                            rawParts
                        } else {
                            val overflowCount = rawParts.size - colWidths.size
                            // Merge col-1 + any overflow parts back into one item-name string
                            val mergedItemName =
                                    rawParts.subList(1, 2 + overflowCount).joinToString(",")
                            listOf(rawParts[0], mergedItemName) +
                                    rawParts.subList(2 + overflowCount, rawParts.size)
                        }
                var maxHeightInRow = 0

                // Build separate layouts for each cell in this row
                for (i in columns.indices) {
                    if (i >= colWidths.size) break // Prevent out of bounds
                    val cellText = columns[i].trim()
                    val cellAlign =
                            when {
                                // ជួរឈរទី១ (ល.រ) និងទី២ (ឈ្មោះទំនិញ) គឺតម្រឹមឆ្វេងជានិច្ច
                                i <= 1 -> Layout.Alignment.ALIGN_NORMAL

                                // បើជាជួរក្បាលតារាង (មានពាក្យ ចំនួន, តម្លៃ, ចុះតម្លៃ, សរុប ឬ Qty,
                                // Price, Dis, Total)
                                // ត្រូវតម្រឹមទៅខាងស្តាំ (ALIGN_OPPOSITE)
                                // ដើម្បីឱ្យស្មើគែមប្រអប់ទិន្នន័យ
                                line.contains("Qty", ignoreCase = true) ||
                                        line.contains("Price", ignoreCase = true) ||
                                        line.contains("Total", ignoreCase = true) ||
                                        line.contains("ចំនួន") ||
                                        line.contains("តម្លៃ") ||
                                        line.contains("ចុះតម្លៃ") ||
                                        line.contains("សរុប") -> Layout.Alignment.ALIGN_OPPOSITE

                                // បើជាជួរទិន្នន័យទំនិញធម្មតា គឺដាក់នៅចំកណ្តាល (Center)
                                else -> Layout.Alignment.ALIGN_CENTER
                            }

                    val builder =
                            StaticLayout.Builder.obtain(
                                            cellText,
                                            0,
                                            cellText.length,
                                            paint,
                                            colWidths[i]
                                    )
                                    .setAlignment(cellAlign)
                                    .setLineSpacing(0f, 1.2f)
                                    .setIncludePad(true)
                                    .setTextDirection(TextDirectionHeuristics.LTR)

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        builder.setBreakStrategy(LineBreaker.BREAK_STRATEGY_HIGH_QUALITY)
                    }

                    val cellLayout = builder.build()
                    if (cellLayout.height > maxHeightInRow) {
                        maxHeightInRow = cellLayout.height
                    }

                    // Save layouts with their horizontal column placement relative to current row
                    // height
                    val _trible = Triple(cellLayout, colPositions[i] + padding, totalHeight)
                    layoutsWithPositions.add(_trible)
                }
                totalHeight += maxHeightInRow + 5 // Add row height to layout height
            } else {
                // Handle regular centered or aligned text blocks
                var alignment = Layout.Alignment.ALIGN_NORMAL
                if (cleanLine.contains("[C]")) {
                    alignment = Layout.Alignment.ALIGN_CENTER
                    cleanLine = cleanLine.replace("[C]", "")
                } else if (cleanLine.contains("[R]")) {
                    alignment = Layout.Alignment.ALIGN_OPPOSITE
                    cleanLine = cleanLine.replace("[R]", "")
                }

                val builder =
                        StaticLayout.Builder.obtain(
                                        cleanLine,
                                        0,
                                        cleanLine.length,
                                        paint,
                                        maxTextWidth
                                )
                                .setAlignment(alignment)
                                .setLineSpacing(0f, 1.2f)
                                .setIncludePad(true)
                                .setTextDirection(TextDirectionHeuristics.LTR)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    builder.setBreakStrategy(LineBreaker.BREAK_STRATEGY_HIGH_QUALITY)
                }

                val layout = builder.build()
                layoutsWithPositions.add(Triple(layout, padding, totalHeight))
                totalHeight += layout.height
            }
        }

        val bitmap = Bitmap.createBitmap(printerWidth, totalHeight + 15, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)

         println("canvas write");
        // គូររូបភាពឡូហ្គោចូលទៅក្នុង Canvas ចំកណ្តាល (Center) បំផុតនៃផ្នែកខាងលើ
        if (logoBitmap != null) {
            println("Logo excuted");
            val logoX = (printerWidth - logoBitmap.width) / 2f
            val logoY = 10f
            canvas.drawBitmap(logoBitmap, logoX, logoY, null)
        }

        // គូរបន្ទាត់ផ្ដេក [LINE] ទាំងអស់
        for (lineY in horizontalLinesY) {
            canvas.drawLine(padding.toFloat(), lineY.toFloat(), (printerWidth - padding).toFloat(), lineY.toFloat(), linePaint)
        }

        // Draw all calculated components into their designated coordinates
        for (item in layoutsWithPositions) {
            val layout = item.first
            val xPos = item.second.toFloat()
            val yPos = item.third.toFloat() + 5f

            canvas.save()
            canvas.translate(xPos, yPos)
            layout.draw(canvas)
            canvas.restore()
        }

        return bitmap
    }

    private fun sendImageToPrinter(stream: BufferedOutputStream, bitmap: Bitmap) {
        val width = bitmap.width
        val height = bitmap.height

        // Set line spacing to exactly 24 dots (ESC 3 24 = 0x1B 0x33 0x18).
        // This is critical: the default line spacing (ESC 2 ~30 units) is larger than
        // 24 dots, so each 0x0A after a stripe overshoots by ~2mm and leaves a
        // visible white gap across every row of the printed image.
        stream.write(byteArrayOf(0x1B, 0x33, 24))

        for (y in 0 until height step 24) {
            val command = mutableListOf<Byte>()
            command.add(0x1B.toByte())
            command.add(0x2A.toByte())
            command.add(33.toByte()) // 24-dot double-density mode
            command.add((width % 256).toByte())
            command.add((width / 256).toByte())

            for (x in 0 until width) {
                for (k in 0 until 3) { // 3 bytes x 8 bits = 24 vertical dots
                    var byteData = 0
                    for (b in 0 until 8) {
                        val pixelY = y + (k * 8) + b
                        if (pixelY < height) {
                            val pixel = bitmap.getPixel(x, pixelY)
                            if (Color.red(pixel) < 128) {
                                byteData = byteData or (1 shl (7 - b))
                            }
                        }
                    }
                    command.add(byteData.toByte())
                }
            }
            stream.write(command.toByteArray())
            stream.write(byteArrayOf(0x0A)) // LF now advances exactly 24 dots
        }

        // Restore default line spacing (ESC 2) so FEED_LINES after the image works normally.
        stream.write(byteArrayOf(0x1B, 0x32))
    }

    fun dispose() {
        closeConnection()
        executor.shutdown()
    }
}

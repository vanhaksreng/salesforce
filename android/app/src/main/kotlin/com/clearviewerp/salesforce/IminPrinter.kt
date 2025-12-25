package com.clearviewerp.salesforce

import android.content.Context
import android.graphics.*
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.Log
import com.imin.library.IminSDKManager
import com.imin.library.SystemPropManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.util.Locale
import java.util.Locale.getDefault

class IminPrinter(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.imin.printersdk"
        private const val TAG = "IminPrinter"

        // Printer width in pixels - 58mm thermal paper (384px)
        private const val PRINTER_WIDTH_PX = 384

        // ESC/POS Commands
        private val ESC: Byte = 0x1B.toByte()
        private val GS: Byte = 0x1D.toByte()
        private val LF: Byte = 0x0A.toByte()
        private val CMD_INIT = byteArrayOf(ESC, 0x40)
        private val CMD_LINE_FEED = byteArrayOf(LF)
        private val CMD_CUT_PAPER = byteArrayOf(GS, 0x56, 0x00)
        private val CMD_CUT_PAPER_PARTIAL = byteArrayOf(GS, 0x56, 0x01)

        // Bitmap printing command
        private fun CMD_BITMAP(width: Int, height: Int): ByteArray {
            val widthL = (width and 0xFF).toByte()
            val widthH = ((width shr 8) and 0xFF).toByte()
            val heightL = (height and 0xFF).toByte()
            val heightH = ((height shr 8) and 0xFF).toByte()
            return byteArrayOf(GS, 0x76, 0x30, 0x00, widthL, widthH, heightL, heightH)
        }

        // Character widths for 58mm paper (384px)
        private const val CHARS_PER_LINE_SMALL = 42
        private const val CHARS_PER_LINE_NORMAL = 32
        private const val CHARS_PER_LINE_LARGE = 24

        /**
         * Generate comprehensive list of printer device paths
         */
        private fun generateDevicePaths(): Array<String> {
            val paths = mutableListOf<String>()

            paths.addAll(arrayOf(
                "/dev/spidev32765.0",
                "/dev/ttyMT0",
                "/dev/ttyMT1",
                "/dev/ttyS1",
                "/dev/ttyS0",
                "/dev/spidev1.0",
                "/dev/spidev0.0",
                "/dev/usb/lp0",
                "/dev/imin_printer",
            ))

            for (i in 0..10) {
                paths.add("/dev/ttyMT$i")
                paths.add("/dev/ttyS$i")
                paths.add("/dev/spidev$i.0")
                paths.add("/dev/usb/lp$i")
                paths.add("/dev/lp$i")
            }

            paths.addAll(arrayOf("/dev/printer0", "/dev/printer"))

            val model = try {
                SystemPropManager.getModel()
            } catch (e: Exception) {
                Build.MODEL
            }

            when {
                model.contains("M2-203", ignoreCase = true) -> {
                    paths.remove("/dev/spidev32765.0")
                    paths.add(0, "/dev/spidev32765.0")
                }
                model.contains("M2-202", ignoreCase = true) -> {
                    paths.remove("/dev/ttyMT0")
                    paths.add(0, "/dev/ttyMT0")
                }
                model.contains("M2-Max", ignoreCase = true) -> {
                    paths.remove("/dev/spidev1.0")
                    paths.add(0, "/dev/spidev1.0")
                }
                model.contains("D4", ignoreCase = true) ||
                        model.contains("D3", ignoreCase = true) ||
                        model.contains("D2", ignoreCase = true) ||
                        model.contains("D1", ignoreCase = true) -> {
                    paths.remove("/dev/usb/lp0")
                    paths.add(0, "/dev/usb/lp0")
                }
            }

            return paths.distinct().toTypedArray()
        }

        private val PRINTER_DEVICE_PATHS = generateDevicePaths()
    }

    private var isPrinterInitialized = false
    private var devicePath: String? = null
    private var deviceModel: String = "Unknown"
    private var printerWidth: Int = PRINTER_WIDTH_PX

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Thread {
            try {
                when (call.method) {
                    "sdkInit" -> initializePrinter(result)
                    "scanDevices" -> scanDevices(result)
                    "getStatus" -> getPrinterStatus(result)

                    "printText" -> {
                        val text = call.argument<String>("text")
                        val fontSize = call.argument<Int>("fontSize") ?: 20
                        val bold = call.argument<Boolean>("bold") ?: false
                        val align = call.argument<String>("align") ?: "left"
                        val maxCharsPerLine = call.argument<Int>("maxCharsPerLine") ?: 0
                        if (text != null) {
                            printText(text, fontSize, bold, align, maxCharsPerLine, result)
                        } else {
                            runOnMainThread {
                                result.error("INVALID_ARGS", "Missing text", null)
                            }
                        }
                    }

                    "printTextAsImage" -> printTextAsImage(call, result)

                    "printRow" -> {
                        val columns = call.argument<List<Map<String, Any>>>("columns") ?: emptyList()
                        val fontSize = call.argument<Int>("fontSize") ?: 20
                        printRow(columns, fontSize, result)
                    }

                    "printSeparator" -> {
                        val width = call.argument<Int>("width") ?: 32
                        printSeparator(width, result)
                    }

                    "printImage" -> {
                        val imageBytes = call.argument<ByteArray>("imageBytes")
                        val width = call.argument<Int>("width") ?: printerWidth
                        val align = call.argument<Int>("align") ?: 1
                        if (imageBytes != null) {
                            printImage(imageBytes, width, align, result)
                        } else {
                            runOnMainThread {
                                result.error("INVALID_ARGS", "Missing imageBytes", null)
                            }
                        }
                    }

                    "printImageWithPadding" -> {
                        val imageBytes = call.argument<ByteArray>("imageBytes")
                        val width = call.argument<Int>("width") ?: 256
                        val align = call.argument<Int>("align") ?: 1
                        val paperWidth = call.argument<Int>("paperWidth") ?: 384

                        if (imageBytes == null) {
                            runOnMainThread {
                                result.error("INVALID_ARGUMENT", "imageBytes is required", null)
                            }
                            return@Thread
                        }

                        printImageWithPadding(imageBytes, width, align, paperWidth, result)
                    }

                    "printBitmap" -> printBitmap(call, result)

                    "feedPaper" -> {
                        val lines = call.argument<Int>("lines") ?: 1
                        feedPaper(lines, result)
                    }

                    "cutPaper" -> cutPaper(result)

                    "printReceipt" -> printReceipt(call, result)

                    "getSn" -> getSerialNumber(result)
                    "opencashBox" -> openCashBox(result)
                    "resetPrinter" -> resetPrinter(result)
                    "getDeviceInfo" -> getDeviceInfo(result)
                    "testPrint" -> testPrint(result)

                    else -> runOnMainThread { result.notImplemented() }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Method ${call.method} failed", e)
                runOnMainThread {
                    result.error("METHOD_ERROR", e.message, null)
                }
            }
        }.start()
    }

    /**
     * Scan and list all potential printer devices
     */
    private fun scanDevices(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "🔍 Scanning for printer devices...")

            val foundDevices = mutableListOf<Map<String, Any>>()

            val devDir = File("/dev")
            val allFiles = devDir.listFiles() ?: emptyArray()

            val candidates = allFiles.filter { file ->
                val name = file.name.lowercase(getDefault())
                name.contains("spi") ||
                        name.contains("tty") ||
                        name.contains("usb") ||
                        name.contains("lp") ||
                        name.contains("printer") ||
                        name.contains("imin")
            }

            Log.d(TAG, "Found ${candidates.size} potential devices")

            for (file in candidates) {
                val deviceInfo = mutableMapOf<String, Any>(
                    "path" to file.absolutePath,
                    "name" to file.name,
                    "exists" to file.exists(),
                    "canRead" to file.canRead(),
                    "canWrite" to file.canWrite(),
                )

                var testWriteSuccess = false
                if (file.canWrite()) {
                    try {
                        FileOutputStream(file).use { output ->
                            output.write(CMD_INIT)
                            output.flush()
                        }
                        testWriteSuccess = true
                        Log.d(TAG, "✅ ${file.absolutePath} - Test write successful")
                    } catch (e: Exception) {
                        Log.w(TAG, "⚠️ ${file.absolutePath} - Test write failed: ${e.message}")
                    }
                }

                deviceInfo["testWriteSuccess"] = testWriteSuccess
                foundDevices.add(deviceInfo)
            }

            val sorted = foundDevices.sortedByDescending {
                (it["testWriteSuccess"] as Boolean)
            }

            Log.d(TAG, "=" .repeat(50))
            Log.d(TAG, " SCAN RESULTS:")
            sorted.forEach { device ->
                if (device["testWriteSuccess"] as Boolean) {
                    Log.d(TAG, " ${device["path"]} - WORKING!")
                }
            }
            Log.d(TAG, "=" .repeat(50))

            runOnMainThread {
                result.success(mapOf(
                    "devices" to sorted,
                    "totalScanned" to allFiles.size,
                    "potentialDevices" to candidates.size,
                    "workingDevices" to sorted.count { it["testWriteSuccess"] as Boolean }
                ))
            }

        } catch (e: Exception) {
            Log.e(TAG, "Scan failed", e)
            runOnMainThread {
                result.error("SCAN_ERROR", e.message, null)
            }
        }
    }

    /**
     * Auto-detect and initialize printer device
     */
    private fun initializePrinter(result: MethodChannel.Result) {
        try {
            deviceModel = try {
                SystemPropManager.getModel()
            } catch (e: Exception) {
                Build.MODEL ?: "Unknown"
            }

            Log.d(TAG, " Device: $deviceModel")
            Log.d(TAG, " Android: ${Build.VERSION.RELEASE} (SDK: ${Build.VERSION.SDK_INT})")
            Log.d(TAG, " Paper: 58mm (384px)")
            Log.d(TAG, " Searching for printer device...")

            var foundDevice: File? = null
            var attemptedPaths = 0

            for (path in PRINTER_DEVICE_PATHS) {
                attemptedPaths++
                val device = File(path)

                if (device.exists()) {
                    Log.d(TAG, "[$attemptedPaths/${PRINTER_DEVICE_PATHS.size}] Found: $path")

                    if (device.canWrite()) {
                        try {
                            FileOutputStream(device).use { output ->
                                output.write(CMD_INIT)
                                output.flush()
                            }

                            foundDevice = device
                            devicePath = path
                            Log.d(TAG, " Successfully initialized: $path")
                            break

                        } catch (e: Exception) {
                            Log.w(TAG, "    Write test failed: ${e.message}")
                        }
                    } else {
                        Log.d(TAG, "    Not writable")
                    }
                }
            }

            if (foundDevice == null) {
                Log.e(TAG, " No working printer device found")
                runOnMainThread {
                    result.error(
                        "INIT_ERROR",
                        "No printer device found after trying $attemptedPaths paths",
                        null
                    )
                }
                return
            }

            Thread.sleep(500)
            isPrinterInitialized = true

            Log.d(TAG, " Printer ready at: $devicePath")

            runOnMainThread {
                result.success(mapOf(
                    "status" to "init",
                    "method" to "Direct Device I/O",
                    "devicePath" to devicePath,
                    "deviceModel" to deviceModel,
                    "paperWidth" to "58mm (384px)",
                    "pathsAttempted" to attemptedPaths
                ))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Initialization failed", e)
            runOnMainThread {
                result.error("INIT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Get printer status
     */
    private fun getPrinterStatus(result: MethodChannel.Result) {
        if (!isPrinterInitialized) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        val device = devicePath?.let { File(it) }
        val isReady = device?.exists() == true && device.canWrite()

        runOnMainThread {
            result.success(mapOf(
                "status" to if (isReady) 0 else -1,
                "message" to if (isReady) "Ready" else "Device unavailable",
                "devicePath" to devicePath
            ))
        }
    }

    /**
     * Print text with formatting
     */
    private fun printText(
        text: String,
        fontSize: Int,
        bold: Boolean,
        align: String,
        maxCharsPerLine: Int,
        result: MethodChannel.Result
    ) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            if (hasKhmerOrSpecialChars(text)) {
                val bitmap = textToBitmap(
                    text = text,
                    fontSize = fontSize.toFloat(),
                    fontName = "KhmerOS",
                    align = align,
                    bold = bold
                )
                printBitmapToDevice(bitmap)
            } else {
                val lines = if (maxCharsPerLine > 0) {
                    wrapText(text, maxCharsPerLine)
                } else {
                    listOf(text)
                }

                val device = File(devicePath!!)
                FileOutputStream(device).use { output ->
                    for (line in lines) {
                        output.write(line.toByteArray(Charsets.UTF_8))
                        output.write(CMD_LINE_FEED)
                    }
                    output.flush()
                }
            }

            Log.d(TAG, " Printed text: ${text.take(50)}...")

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Print text failed", e)
            runOnMainThread {
                result.error("PRINT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Wrap text to specific character width
     */
    private fun wrapText(text: String, maxChars: Int): List<String> {
        val lines = mutableListOf<String>()
        var currentLine = ""

        for (word in text.split(" ")) {
            if (currentLine.length + word.length + 1 <= maxChars) {
                currentLine += if (currentLine.isEmpty()) word else " $word"
            } else {
                if (currentLine.isNotEmpty()) {
                    lines.add(currentLine)
                }
                currentLine = word
            }
        }

        if (currentLine.isNotEmpty()) {
            lines.add(currentLine)
        }

        return lines
    }

    /**
     * Print text as bitmap
     */
    private fun printTextAsImage(call: MethodCall, result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val text = call.argument<String>("text")
            val fontSize = call.argument<Int>("fontSize") ?: 20
            val fontName = call.argument<String>("fontName")
            val align = call.argument<String>("align") ?: "left"
            val bold = call.argument<Boolean>("bold") ?: false

            if (text.isNullOrEmpty()) {
                runOnMainThread {
                    result.error("INVALID_ARGUMENT", "Text is required", null)
                }
                return
            }

            val bitmap = textToBitmap(
                text = text,
                fontSize = fontSize.toFloat(),
                fontName = fontName,
                align = align,
                bold = bold
            )

            printBitmapToDevice(bitmap)

            Log.d(TAG, " Printed text as bitmap")

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Print text as image failed", e)
            runOnMainThread {
                result.error("PRINT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Print row with columns
     */
    /**
     * Print row with columns - FIXED VERSION
     * Properly handles fontSize for both Khmer and English text
     */
    private fun printRow(
        columns: List<Map<String, Any>>,
        fontSize: Int,
        result: MethodChannel.Result
    ) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val totalRatio = columns.sumOf { (it["width"] as? Int) ?: 1 }

            // Render as bitmap with text wrapping support
            printRowAsBitmapWithWrap(columns, fontSize, totalRatio)

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Print row failed", e)
            runOnMainThread {
                result.error("PRINT_ERROR", e.message, null)
            }
        }
    }

    private fun printRowAsBitmapWithWrap(
        columns: List<Map<String, Any?>>,
        fontSize: Int,
        totalRatio: Int
    ) {
        val paperWidthPx = PRINTER_WIDTH_PX // 384px for 58mm paper

        // Create paint for text rendering
        val paint = TextPaint().apply {
            color = Color.BLACK
            textSize = fontSize * 1.3f
            isAntiAlias = true
            style = Paint.Style.FILL_AND_STROKE
            strokeWidth = 0.5f
            // Try to load KhmerOS font
            try {
                typeface = Typeface.createFromAsset(context.assets, "fonts/NotoSansKhmer.ttf")
            } catch (e: Exception) {
                Log.w(TAG, "KhmerOS font not found, using default")
                typeface = Typeface.DEFAULT
            }
        }

        // Calculate column widths and wrap text for each column
        data class ColumnData(
            val lines: List<String>,
            val widthPx: Float,
            val startX: Float,
            val align: String
        )

        val columnsData = mutableListOf<ColumnData>()
        var currentX = 0f
        var maxLines = 1

        for (col in columns) {
            val text = (col["text"] as? String) ?: ""
            val width = (col["width"] as? Int) ?: 1
            val align = (col["align"] as? String) ?: "left"

            val colWidthPx = (paperWidthPx * width / totalRatio).toFloat()
            val availableWidth = colWidthPx - 4f // 4px padding total

            // Wrap text to fit column width
            val wrappedLines = wrapTextToWidth(text, availableWidth, paint)
            maxLines = maxOf(maxLines, wrappedLines.size)

            columnsData.add(ColumnData(wrappedLines, colWidthPx, currentX, align))
            currentX += colWidthPx
        }

        // FIXED: Better line height calculation (reduced padding)
        val fontMetrics = paint.fontMetrics
        val lineHeight = (fontMetrics.descent - fontMetrics.ascent + fontMetrics.leading).toInt()
        val totalHeight = lineHeight * maxLines + 4 // Add small top/bottom padding

        // Create bitmap
        val bitmap = Bitmap.createBitmap(paperWidthPx, totalHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)

        // Draw each column
        for (colData in columnsData) {
            for ((lineIndex, line) in colData.lines.withIndex()) {
                val textWidth = paint.measureText(line)
                val colEndX = colData.startX + colData.widthPx

                // Calculate X position based on alignment
                val x = when (colData.align.lowercase(Locale.getDefault())) {
                    "right" -> colEndX - textWidth - 2f
                    "center" -> colData.startX + (colData.widthPx - textWidth) / 2f
                    else -> colData.startX + 2f
                }

                // FIXED: Better Y position calculation
                val y = 2f + lineIndex * lineHeight - fontMetrics.ascent

                // Draw text
                canvas.drawText(line, x.coerceAtLeast(colData.startX), y, paint)
            }
        }

        val monoBitmap = convertToMonochrome(bitmap)
        printBitmapToDevice(monoBitmap)
    }

    private fun wrapTextToWidth(text: String, maxWidth: Float, paint: TextPaint): List<String> {
        if (text.isEmpty()) return listOf("")

        val words = text.split(" ")
        val lines = mutableListOf<String>()
        var currentLine = ""

        for (word in words) {
            val testLine = if (currentLine.isEmpty()) word else "$currentLine $word"
            val width = paint.measureText(testLine)

            if (width <= maxWidth) {
                currentLine = testLine
            } else {
                // Current word doesn't fit
                if (currentLine.isNotEmpty()) {
                    lines.add(currentLine)
                    currentLine = word
                } else {
                    // Single word is too long, try to break it
                    if (paint.measureText(word) > maxWidth) {
                        val brokenWord = breakLongWord(word, maxWidth, paint)
                        lines.addAll(brokenWord.dropLast(1))
                        currentLine = brokenWord.last()
                    } else {
                        currentLine = word
                    }
                }
            }
        }

        if (currentLine.isNotEmpty()) {
            lines.add(currentLine)
        }

        return lines.ifEmpty { listOf("") }
    }

    private fun breakLongWord(word: String, maxWidth: Float, paint: TextPaint): List<String> {
        val parts = mutableListOf<String>()
        var current = ""

        for (char in word) {
            val test = current + char
            if (paint.measureText(test) <= maxWidth) {
                current = test
            } else {
                if (current.isNotEmpty()) {
                    parts.add(current)
                }
                current = char.toString()
            }
        }

        if (current.isNotEmpty()) {
            parts.add(current)
        }

        return parts.ifEmpty { listOf(word) }
    }


    /**
     * Convert text to bitmap - UPDATED VERSION
     * Better fontSize scaling for consistency
     */
    private fun printRowAsBitmap(
        columns: List<Map<String, Any>>,
        fontSize: Int,
        totalRatio: Int
    ) {
        val paperWidthPx = PRINTER_WIDTH_PX  // 384px for 58mm paper

        // Create paint for text rendering
        val paint = TextPaint().apply {
            color = Color.BLACK
            textSize = fontSize * 1.3f  // Adjust multiplier as needed
            isAntiAlias = true

            // Try to load KhmerOS font for consistency
            try {
                typeface = Typeface.createFromAsset(context.assets, "fonts/NotoSansKhmer.ttf")
            } catch (e: Exception) {
                Log.w(TAG, "KhmerOS font not found, using default")
                typeface = Typeface.DEFAULT
            }
        }

        // Calculate row height with some padding
        val lineHeight = (fontSize * 1.5f).toInt()
        val bitmap = Bitmap.createBitmap(paperWidthPx, lineHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)

        var currentX = 0f

        for (col in columns) {
            val text = (col["text"] as? String) ?: ""
            val width = (col["width"] as? Int) ?: 1
            val align = (col["align"] as? String) ?: "left"

            // Calculate exact pixel width for this column
            val colWidthPx = (paperWidthPx * width / totalRatio).toFloat()
            val colEndX = currentX + colWidthPx

            // Measure text width
            val textWidth = paint.measureText(text)

            // Calculate X position based on alignment within the column
            val x = when (align.lowercase(Locale.getDefault())) {
                "right" -> colEndX - textWidth - 2f  // Small padding
                "center" -> currentX + (colWidthPx - textWidth) / 2f
                else -> currentX + 2f  // Small left padding
            }

            // Calculate Y position (baseline)
            val y = fontSize * 1.2f

            // Draw text
            canvas.drawText(text, x.coerceAtLeast(currentX), y, paint)

            // Draw column separator lines for debugging (comment out in production)
            // val linePaint = Paint().apply {
            //     color = Color.LTGRAY
            //     strokeWidth = 1f
            // }
            // canvas.drawLine(colEndX, 0f, colEndX, lineHeight.toFloat(), linePaint)

            currentX = colEndX
        }

        val monoBitmap = convertToMonochrome(bitmap)
        printBitmapToDevice(monoBitmap)
    }

    /**
     * Enhanced text to bitmap conversion
     * Better fontSize scaling for consistency
     */
    /**
     * STANDARD version - for standalone text (keeps existing spacing)
     */
    private fun textToBitmap(
        text: String,
        fontSize: Float,
        fontName: String? = null,
        align: String = "left",
        bold: Boolean = false
    ): Bitmap {
        val paint = TextPaint().apply {
            color = Color.BLACK
            textSize = fontSize * 1.3f
            isAntiAlias = true
            style = Paint.Style.FILL_AND_STROKE
            strokeWidth = 0.5f

            if (fontName != null) {
                try {
                    typeface = Typeface.createFromAsset(context.assets, "fonts/$fontName.ttf")
                } catch (e: Exception) {
                    Log.w(TAG, "Font $fontName not found, using default")
                    typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
                }
            } else {
                typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
            }
        }

        val width = PRINTER_WIDTH_PX

        val alignment = when (align.lowercase(Locale.getDefault())) {
            "center" -> Layout.Alignment.ALIGN_CENTER
            "right" -> Layout.Alignment.ALIGN_OPPOSITE
            else -> Layout.Alignment.ALIGN_NORMAL
        }

        val layout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            StaticLayout.Builder.obtain(text, 0, text.length, paint, width)
                .setAlignment(alignment)
                .setLineSpacing(fontSize * 0.15f, 1f) // Standard spacing
                .setIncludePad(false)
                .build()
        } else {
            @Suppress("DEPRECATION")
            StaticLayout(
                text,
                paint,
                width,
                alignment,
                1f,
                fontSize * 0.15f,
                false
            )
        }

        val topPadding = 4
        val bottomPadding = 4
        val height = layout.height + topPadding + bottomPadding

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)

        canvas.save()
        canvas.translate(0f, topPadding.toFloat())
        layout.draw(canvas)
        canvas.restore()

        return convertToMonochrome(bitmap)
    }


    /**
     * Get characters per line based on font size
     * For text-based printing (non-bitmap)
     */
    private fun getCharsPerLine(fontSize: Int): Int {
        return when {
            fontSize <= 12 -> 48
            fontSize <= 14 -> 42
            fontSize <= 16 -> 38
            fontSize <= 18 -> 34
            fontSize <= 20 -> 32
            fontSize <= 22 -> 30
            fontSize <= 24 -> 28
            fontSize <= 28 -> 24
            else -> 20
        }
    }

    /**
     * Print separator line
     */
    private fun printSeparator(width: Int, result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val separator = "-".repeat(width) + "\n"

            val device = File(devicePath!!)
            FileOutputStream(device).use { output ->
                output.write(separator.toByteArray(Charsets.UTF_8))
                output.flush()
            }

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Print separator failed", e)
            runOnMainThread {
                result.error("PRINT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Print image from bytes
     */
    private fun printImage(
        imageBytes: ByteArray,
        width: Int,
        align: Int,
        result: MethodChannel.Result
    ) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            if (bitmap == null) {
                runOnMainThread {
                    result.error("BITMAP_ERROR", "Failed to decode image", null)
                }
                return
            }

            val aspectRatio = bitmap.height.toFloat() / bitmap.width.toFloat()
            val newHeight = (width * aspectRatio).toInt()
            val resizedBitmap = Bitmap.createScaledBitmap(bitmap, width, newHeight, true)

            val alignedBitmap = when (align) {
                0 -> addPadding(resizedBitmap, printerWidth, "left")
                1 -> addPadding(resizedBitmap, printerWidth, "center")
                2 -> addPadding(resizedBitmap, printerWidth, "right")
                else -> resizedBitmap
            }

            printBitmapToDevice(alignedBitmap)

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Print image failed", e)
            runOnMainThread {
                result.error("PRINT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Print image with padding
     */
    private fun printImageWithPadding(
        imageBytes: ByteArray,
        width: Int,
        align: Int,
        paperWidth: Int,
        result: MethodChannel.Result
    ) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            if (bitmap == null) {
                runOnMainThread {
                    result.error("BITMAP_ERROR", "Failed to decode image", null)
                }
                return
            }

            val aspectRatio = bitmap.height.toFloat() / bitmap.width.toFloat()
            val newHeight = (width * aspectRatio).toInt()
            val resizedBitmap = Bitmap.createScaledBitmap(bitmap, width, newHeight, true)

            val alignedBitmap = when (align) {
                0 -> addPadding(resizedBitmap, paperWidth, "left")
                1 -> addPadding(resizedBitmap, paperWidth, "center")
                2 -> addPadding(resizedBitmap, paperWidth, "right")
                else -> resizedBitmap
            }

            printBitmapToDevice(alignedBitmap)

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Print image with padding failed", e)
            runOnMainThread {
                result.error("PRINT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Add padding to bitmap for alignment
     */
    private fun addPadding(bitmap: Bitmap, targetWidth: Int, align: String): Bitmap {
        if (bitmap.width >= targetWidth) return bitmap

        val paddedBitmap = Bitmap.createBitmap(targetWidth, bitmap.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(paddedBitmap)
        canvas.drawColor(Color.WHITE)

        val x = when (align) {
            "center" -> (targetWidth - bitmap.width) / 2f
            "right" -> (targetWidth - bitmap.width).toFloat()
            else -> 0f
        }

        canvas.drawBitmap(bitmap, x, 0f, null)
        return paddedBitmap
    }

    /**
     * Print bitmap from byte array
     */
    private fun printBitmap(call: MethodCall, result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val imageBytes = call.argument<ByteArray>("image")
            if (imageBytes == null) {
                runOnMainThread {
                    result.error("INVALID_ARGUMENT", "Image bytes required", null)
                }
                return
            }

            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            if (bitmap == null) {
                runOnMainThread {
                    result.error("BITMAP_ERROR", "Failed to decode bitmap", null)
                }
                return
            }

            val resizedBitmap = if (bitmap.width > printerWidth) {
                val aspectRatio = bitmap.height.toFloat() / bitmap.width.toFloat()
                val newHeight = (printerWidth * aspectRatio).toInt()
                Bitmap.createScaledBitmap(bitmap, printerWidth, newHeight, true)
            } else {
                bitmap
            }

            printBitmapToDevice(resizedBitmap)

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Bitmap print failed", e)
            runOnMainThread {
                result.error("BITMAP_PRINT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Feed paper
     */
    private fun feedPaper(lines: Int, result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val device = File(devicePath!!)
            FileOutputStream(device).use { output ->
                repeat(lines) {
                    output.write(CMD_LINE_FEED)
                }
                output.flush()
            }

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Feed paper failed", e)
            runOnMainThread {
                result.error("FEED_ERROR", e.message, null)
            }
        }
    }

    /**
     * Cut paper
     */
    private fun cutPaper(result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val device = File(devicePath!!)
            FileOutputStream(device).use { output ->
                repeat(3) {
                    output.write(CMD_LINE_FEED)
                }
                output.write(CMD_CUT_PAPER)
                output.flush()
            }

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Cut paper failed", e)
            runOnMainThread {
                result.error("CUT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Print receipt
     */
    private fun printReceipt(call: MethodCall, result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val receiptData = call.argument<Map<String, Any>>("receiptData")
            if (receiptData == null) {
                runOnMainThread {
                    result.error("INVALID_ARGUMENT", "Receipt data is required", null)
                }
                return
            }

            Log.d(TAG, "Building receipt...")

            val header = receiptData["header"] as? Map<String, Any>
            val items = receiptData["items"] as? List<Map<String, Any>>
            val footer = receiptData["footer"] as? Map<String, Any>
            val options = receiptData["options"] as? Map<String, Any> ?: emptyMap()

            buildAndPrintReceipt(header, items, footer, options)

            Log.d(TAG, " Receipt printed successfully")

            runOnMainThread {
                result.success(mapOf("status" to "success"))
            }

        } catch (e: Exception) {
            Log.e(TAG, " Failed to print receipt", e)
            runOnMainThread {
                result.error("PRINT_ERROR", e.message, null)
            }
        }
    }

    /**
     * Build and print complete receipt
     */
    private fun buildAndPrintReceipt(
        header: Map<String, Any>?,
        items: List<Map<String, Any>>?,
        footer: Map<String, Any>?,
        options: Map<String, Any>
    ) {
        val fontSize = (options["fontSize"] as? Int) ?: 20
        val fontName = options["fontName"] as? String

        header?.let {
            val title = it["title"] as? String
            val subtitle = it["subtitle"] as? String
            val info = it["info"] as? List<String>

            title?.let { text ->
                printTextLine(text, fontSize + 6, fontName, "center", true)
            }

            subtitle?.let { text ->
                printTextLine(text, fontSize, fontName, "center", false)
            }

            info?.forEach { line ->
                printTextLine(line, fontSize - 4, fontName, "left", false)
            }

            printSeparatorLine()
        }

        items?.let {
            printItemsTable(it, fontSize, fontName)
            printSeparatorLine()
        }

        footer?.let {
            val totals = it["totals"] as? List<Map<String, Any>>
            val message = it["message"] as? String

            totals?.forEach { total ->
                val label = total["label"] as? String ?: ""
                val value = total["value"] as? String ?: ""
                val bold = total["bold"] as? Boolean ?: false

                printKeyValue(label, value, fontSize, fontName, bold)
            }

            message?.let { text ->
                printTextLine("\n$text\n", fontSize, fontName, "center", false)
            }
        }

        feedPaperSilent(3)
    }

    /**
     * Print single line of text
     */
    /**
     * Print single line of text - FIXED VERSION
     */
    private fun printTextLine(
        text: String,
        fontSize: Int,
        fontName: String?,
        align: String,
        bold: Boolean
    ) {
        if (hasKhmerOrSpecialChars(text)) {
            val bitmap = textToBitmapCompact(
                text = text,
                fontSize = fontSize.toFloat(),
                fontName = fontName,
                align = align,
                bold = bold
            )
            printBitmapToDevice(bitmap)
        } else {
            val device = File(devicePath!!)
            FileOutputStream(device).use { output ->
                output.write(text.toByteArray(Charsets.UTF_8))
                output.write(CMD_LINE_FEED)
                output.flush()
            }
        }
    }

    /**
     * COMPACT version of textToBitmap - minimal spacing for receipts
     */
    private fun textToBitmapCompact(
        text: String,
        fontSize: Float,
        fontName: String? = null,
        align: String = "left",
        bold: Boolean = false
    ): Bitmap {
        val paint = TextPaint().apply {
            color = Color.BLACK
            textSize = fontSize * 1.3f
            isAntiAlias = true
            style = Paint.Style.FILL_AND_STROKE
            strokeWidth = 0.5f

            if (fontName != null) {
                try {
                    typeface = Typeface.createFromAsset(context.assets, "fonts/$fontName.ttf")
                } catch (e: Exception) {
                    Log.w(TAG, "Font $fontName not found, using default")
                    typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
                }
            } else {
                typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
            }
        }

        val width = PRINTER_WIDTH_PX

        val alignment = when (align.lowercase(Locale.getDefault())) {
            "center" -> Layout.Alignment.ALIGN_CENTER
            "right" -> Layout.Alignment.ALIGN_OPPOSITE
            else -> Layout.Alignment.ALIGN_NORMAL
        }

        // Create layout with MINIMAL spacing for compact receipts
        val layout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            StaticLayout.Builder.obtain(text, 0, text.length, paint, width)
                .setAlignment(alignment)
                .setLineSpacing(0f, 1f) // COMPACT: No extra line spacing
                .setIncludePad(false)
                .build()
        } else {
            @Suppress("DEPRECATION")
            StaticLayout(
                text,
                paint,
                width,
                alignment,
                1f,
                0f, // COMPACT: No extra line spacing
                false
            )
        }

        // COMPACT: Minimal padding (1-2px only)
        val topPadding = 1
        val bottomPadding = 1
        val height = layout.height + topPadding + bottomPadding

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)

        canvas.save()
        canvas.translate(0f, topPadding.toFloat())
        layout.draw(canvas)
        canvas.restore()

        return convertToMonochrome(bitmap)
    }

    /**
     * Print items table
     */
    private fun printItemsTable(
        items: List<Map<String, Any>>,
        fontSize: Int,
        fontName: String?
    ) {
        val headerText = buildTableRow58mm(
            no = "No",
            item = "Item",
            qty = "Qty",
            price = "Price",
            disc = "Disc",
            total = "Total",
            fontSize = fontSize
        )
        printTextLine(headerText, fontSize - 2, fontName, "left", true)
        printSeparatorLine()

        items.forEachIndexed { index, item ->
            val no = (index + 1).toString()
            val itemName = item["item"] as? String ?: ""
            val qty = item["qty"]?.toString() ?: ""
            val price = item["price"] as? String ?: ""
            val disc = item["disc"] as? String ?: "0%"
            val total = item["total"] as? String ?: ""

            val rowText = buildTableRow58mm(
                no = no,
                item = itemName,
                qty = qty,
                price = price,
                disc = disc,
                total = total,
                fontSize = fontSize
            )

            printTextLine(rowText, fontSize - 4, fontName, "left", false)
        }
    }

    /**
     * Build table row for 58mm paper
     */
    private fun buildTableRow58mm(
        no: String,
        item: String,
        qty: String,
        price: String,
        disc: String,
        total: String,
        fontSize: Int
    ): String {
        val charsPerLine = getCharsPerLine(fontSize)

        val noWidth = 2
        val qtyWidth = 3
        val priceWidth = 6
        val discWidth = 4
        val totalWidth = 6
        val itemWidth = charsPerLine - noWidth - qtyWidth - priceWidth - discWidth - totalWidth - 5

        return buildString {
            append(no.padEnd(noWidth))
            append(" ")
            append(item.take(itemWidth).padEnd(itemWidth))
            append(" ")
            append(qty.padStart(qtyWidth))
            append(" ")
            append(price.padStart(priceWidth))
            append(" ")
            append(disc.padStart(discWidth))
            append(" ")
            append(total.padStart(totalWidth))
        }
    }

    /**
     * Print key-value pair
     */
    private fun printKeyValue(
        label: String,
        value: String,
        fontSize: Int,
        fontName: String?,
        bold: Boolean
    ) {
        val text = "$label $value"
        printTextLine(text, fontSize, fontName, "right", bold)
    }

    /**
     * Print separator line
     */
    private fun printSeparatorLine() {
        val device = File(devicePath!!)
        FileOutputStream(device).use { output ->
            output.write("================================\n".toByteArray())
            output.flush()
        }
    }

    /**
     * Feed paper (silent - no result callback)
     */
    private fun feedPaperSilent(lines: Int) {
        try {
            val device = File(devicePath!!)
            FileOutputStream(device).use { output ->
                repeat(lines) {
                    output.write(CMD_LINE_FEED)
                }
                output.flush()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Feed paper failed", e)
        }
    }

    /**
     * Convert text to bitmap
     */
//
    /**
     * Convert to monochrome
     */
    private fun convertToMonochrome(bitmap: Bitmap): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        val monoBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)

        val canvas = Canvas(monoBitmap)
        canvas.drawColor(Color.WHITE)

        val paint = Paint().apply {
            colorFilter = ColorMatrixColorFilter(ColorMatrix().apply {
                setSaturation(0f)
            })
        }

        canvas.drawBitmap(bitmap, 0f, 0f, paint)

        val pixels = IntArray(width * height)
        monoBitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        for (i in pixels.indices) {
            val gray = pixels[i] and 0xFF
            pixels[i] = if (gray < 128) Color.BLACK else Color.WHITE
        }

        monoBitmap.setPixels(pixels, 0, width, 0, 0, width, height)
        return monoBitmap
    }

    /**
     * Print bitmap to device
     */
    private fun printBitmapToDevice(bitmap: Bitmap) {
        val device = File(devicePath!!)
        val bitmapData = convertBitmapToEscPos(bitmap)

        FileOutputStream(device).use { output ->
            output.write(bitmapData)
            output.flush()

        }
    }

    /**
     * Convert bitmap to ESC/POS format
     */
    private fun convertBitmapToEscPos(bitmap: Bitmap): ByteArray {
        val width = bitmap.width
        val height = bitmap.height
        val widthBytes = (width + 7) / 8

        val output = ByteArrayOutputStream()
        output.write(CMD_BITMAP(widthBytes, height))

        for (y in 0 until height) {
            for (x in 0 until widthBytes) {
                var b: Byte = 0
                for (bit in 0 until 8) {
                    val px = x * 8 + bit
                    if (px < width) {
                        val pixel = bitmap.getPixel(px, y)
                        val gray = (Color.red(pixel) + Color.green(pixel) + Color.blue(pixel)) / 3
                        if (gray < 128) {
                            b = (b.toInt() or (1 shl (7 - bit))).toByte()
                        }
                    }
                }
                output.write(b.toInt())
            }
        }

        return output.toByteArray()
    }

    /**
     * Check if text has special characters
     */
    private fun hasKhmerOrSpecialChars(text: String): Boolean {
        return text.any { char ->
            val codePoint = char.code
            codePoint in 0x1780..0x17FF ||
                    codePoint in 0x0E00..0x0E7F ||
                    codePoint in 0x4E00..0x9FFF ||
                    codePoint in 0x0600..0x06FF
        }
    }

    /**
     * Get serial number
     */
    private fun getSerialNumber(result: MethodChannel.Result) {
        try {
            val sn = try {
                if (Build.VERSION.SDK_INT >= 30) {
                    SystemPropManager.getSystemProperties("persist.sys.imin.sn")
                } else {
                    SystemPropManager.getSn()
                }
            } catch (e: Exception) {
                "UNKNOWN"
            }

            runOnMainThread {
                result.success(sn)
            }
        } catch (e: Exception) {
            runOnMainThread {
                result.error("SN_ERROR", e.message, null)
            }
        }
    }

    /**
     * Open cash box
     */
    private fun openCashBox(result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            try {
                IminSDKManager.opencashBox()
            } catch (e: Exception) {
                val device = File(devicePath!!)
                FileOutputStream(device).use { output ->
                    output.write(byteArrayOf(ESC, 0x70, 0x00, 0x19, 0xFA.toByte()))
                    output.flush()
                }
            }

            runOnMainThread {
                result.success("opencashBox")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open cash box", e)
            runOnMainThread {
                result.error("CASHBOX_ERROR", e.message, null)
            }
        }
    }

    /**
     * Reset printer
     */
    private fun resetPrinter(result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val device = File(devicePath!!)
            FileOutputStream(device).use { output ->
                output.write(CMD_INIT)
                output.flush()
            }

            Thread.sleep(1000)

            runOnMainThread {
                result.success("reset")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to reset", e)
            runOnMainThread {
                result.error("RESET_ERROR", e.message, null)
            }
        }
    }

    /**
     * Get device info
     */
    private fun getDeviceInfo(result: MethodChannel.Result) {
        val info = mapOf(
            "deviceModel" to deviceModel,
            "androidVersion" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "manufacturer" to Build.MANUFACTURER,
            "brand" to Build.BRAND,
            "device" to Build.DEVICE,
            "printerInitialized" to isPrinterInitialized,
            "printMethod" to "Direct Device I/O",
            "devicePath" to (devicePath ?: "Not found"),
            "printerWidth" to printerWidth,
            "paperSize" to "58mm (384px)"
        )

        runOnMainThread {
            result.success(info)
        }
    }

    /**
     * Test print
     */
    private fun testPrint(result: MethodChannel.Result) {
        if (!isPrinterInitialized || devicePath == null) {
            runOnMainThread {
                result.error("ERROR", "Printer not initialized", null)
            }
            return
        }

        try {
            val testText = """
================================
       TEST PRINT
================================
Device: $deviceModel
Method: Direct Device I/O
Android: ${Build.VERSION.RELEASE}
Paper: 58mm (384px)
Path: $devicePath
Time: ${System.currentTimeMillis()}
================================



""".trimIndent()

            val device = File(devicePath!!)
            FileOutputStream(device).use { output ->
                output.write(testText.toByteArray(Charsets.UTF_8))
                output.flush()
            }

            Log.d(TAG, " Test print completed")

            runOnMainThread {
                result.success("Test print completed")
            }

        } catch (e: Exception) {
            Log.e(TAG, "Test print failed", e)
            runOnMainThread {
                result.error("TEST_PRINT_ERROR", e.message, null)
            }
        }
    }

    private fun runOnMainThread(action: () -> Unit) {
        Handler(Looper.getMainLooper()).post(action)
    }

    fun getChannelName(): String = CHANNEL_NAME
}
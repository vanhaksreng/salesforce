package com.clearviewerp.salesforce

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity(){
    private val htmlPdfChannel = "flutter_html_to_pdf"
    private val locationMethodChannel = "com.clearviewerp.salesforce/location"
    private val locationEventChanel = "com.clearviewerp.salesforce/location_stream"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupHtmlToPdfChannel(flutterEngine)
        setupLocationService(flutterEngine)
    }
    
    private fun setupLocationService(flutterEngine: FlutterEngine) {

        // MethodChannel for start/stop tracking
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, locationMethodChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTracking" -> {
                    val intent = Intent(this, LocationService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) { // API 26+
                        startForegroundService(intent)
                    } else {
                        startService(intent) // For API < 26
                    }
                    result.success("Tracking started")
                }
                "stopTracking" -> {
                    val intent = Intent(this, LocationService::class.java)
                    stopService(intent)
                    result.success("Tracking stopped")
                }
                else -> result.notImplemented()
            }
        }

        // EventChannel for location updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, locationEventChanel).setStreamHandler(LocationStreamHandler(this))
    }

    private fun setupHtmlToPdfChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, htmlPdfChannel).setMethodCallHandler { call, result ->
            if (call.method == "convertHtmlToPdf") {
                val htmlFilePath = call.argument<String>("htmlFilePath")
                if (htmlFilePath == null) {
                    result.error("INVALID_ARGUMENT", "htmlFilePath is null", null)
                    return@setMethodCallHandler
                }

                HtmlToPdfConverter().convert(htmlFilePath, applicationContext, object : HtmlToPdfConverter.Callback {
                    override fun onSuccess(filePath: String) {
                        result.success(filePath)
                    }

                    override fun onFailure() {
                        result.error("ERROR", "Failed to convert HTML to PDF", null)
                    }
                })
            } else {
                result.notImplemented()
            }
        }
    }
}

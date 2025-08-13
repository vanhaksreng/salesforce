package com.clearviewerp.salesforce

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val htmlPdfChannelName = "flutter_html_to_pdf"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupHtmlToPdfChannel(flutterEngine)
    }

    private fun setupHtmlToPdfChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, htmlPdfChannelName).setMethodCallHandler { call, result ->
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

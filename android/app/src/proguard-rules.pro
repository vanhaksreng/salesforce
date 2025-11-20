# Thermal Printer Plugin ProGuard Rules

# Keep all Flutter plugin classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep the thermal printer plugin
-keep class com.clearviewerp.salesforce.ThermalPrinterPlugin { *; }
-keep class com.clearviewerp.salesforce.MainActivity { *; }

# Keep Bluetooth classes
-keep class android.bluetooth.** { *; }
-dontwarn android.bluetooth.**

# Keep USB classes
-keep class android.hardware.usb.** { *; }
-dontwarn android.hardware.usb.**

# Keep Network classes
-keep class java.net.** { *; }
-keep class javax.net.** { *; }

# Keep Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Preserve annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep bitmap and graphics classes
-keep class android.graphics.** { *; }
-keep class android.graphics.Bitmap { *; }
-keep class android.graphics.Canvas { *; }
-keep class android.graphics.Paint { *; }

# Keep method channel handlers
-keepclassmembers class * {
    @io.flutter.plugin.common.MethodChannel$MethodCallHandler *;
}

# Optimization settings
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
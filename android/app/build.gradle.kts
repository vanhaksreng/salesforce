import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val flutterVersionCode: Int =
    (project.findProperty("flutter.versionCode") as String?)?.toInt() ?: 1

val flutterVersionName: String =
    project.findProperty("flutter.versionName") as String? ?: "1.0"


android {
    namespace = "com.clearviewerp.salesforce"
    compileSdk = 36
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

//    packagingOptions {
//        jniLibs {
//            useLegacyPackaging = false
//        }
//    }

    bundle {
        abi {
            enableSplit = true
        }
    }


    defaultConfig {
        applicationId = "com.clearviewerp.salesforce"
        minSdk = 24
        targetSdk = 36
        //versionCode = flutterVersionCode
        //versionName = flutter.versionName

        versionCode = 13000002
        versionName = "13.0.1"

        ndk {
            abiFilters += setOf(
                "arm64-v8a",
                "x86_64"
            )
        }

    }
    
    signingConfigs {
       create("release") {
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            //signingConfig = signingConfigs.getByName("debug")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(files("libs/iminPrinterSDK.jar"))
    implementation(files("libs/IminLibs1.0.15.jar"))
//    implementation("com.github.mik3y:usb-serial-for-android:3.7.2")
    implementation("com.google.android.gms:play-services-location:21.3.0")
    implementation ("androidx.work:work-runtime-ktx:2.10.3")
    implementation ("io.reactivex.rxjava2:rxjava:2.2.21")
    implementation ("io.reactivex.rxjava2:rxandroid:2.1.1")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
   
}

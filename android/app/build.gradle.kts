import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.clearviewerp.salesforce"
    compileSdk = flutter.compileSdkVersion
    //compileSdk = 36
    ndkVersion = flutter.ndkVersion
    //ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

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

        versionCode = 13020003
        versionName = "13.0.2"

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
    implementation("com.google.android.gms:play-services-location:21.3.0")
    implementation("androidx.work:work-runtime-ktx:2.10.3")
    implementation("io.reactivex.rxjava2:rxjava:2.2.21")
    implementation("io.reactivex.rxjava2:rxandroid:2.1.1")
    
    implementation("com.fasterxml.jackson.core:jackson-core:2.15.2")
    implementation("com.fasterxml.jackson.core:jackson-databind:2.15.2")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

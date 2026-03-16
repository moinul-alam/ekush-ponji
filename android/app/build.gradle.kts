import java.util.Properties
import java.io.FileInputStream

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
keyProperties.load(FileInputStream(keyPropertiesFile))

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ekushlabs.ekush_ponji"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring (for Java 8+ APIs on old Android versions)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.ekushlabs.ekush_ponji"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String
            keyPassword = keyProperties["keyPassword"] as String
            storeFile = file(keyProperties["storeFile"] as String)
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // ── Signing ───────────────────────────────────────
            signingConfig = signingConfigs.getByName("release")

            // ── Code & resource shrinking ─────────────────────
            // Removes unused code from your app and all libraries (incl. AdMob).
            isMinifyEnabled = true
            // Removes unused Android resources — saves 1–2 MB from AdMob alone.
            isShrinkResources = true

            // ── ProGuard rules ────────────────────────────────
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            // Keep debug fast — no shrinking, no obfuscation
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // ── Split APKs by ABI ─────────────────────────────────────
    // When building APK (not AAB), generate a separate APK per CPU
    // architecture so each user downloads only what their device needs.
    // Has no effect on AAB builds — Play Store handles splits automatically.
    splits {
        abi {
            isEnable = true
            reset()
            include("arm64-v8a", "armeabi-v7a", "x86_64")
            isUniversalApk = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required when using isCoreLibraryDesugaringEnabled = true
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
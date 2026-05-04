import com.android.build.gradle.internal.dsl.BaseAppModuleExtension
import java.io.FileInputStream
import java.util.Properties

// Load keystore properties with proper error handling
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    println("✅ key.properties found at ${keystorePropertiesFile.absolutePath}")
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    
    // Debug output to verify loading
    println("storePassword exists: ${keystoreProperties.containsKey("storePassword")}")
    println("keyPassword exists: ${keystoreProperties.containsKey("keyPassword")}")
    println("keyAlias exists: ${keystoreProperties.containsKey("keyAlias")}")
    println("storeFile exists: ${keystoreProperties.containsKey("storeFile")}")
    println("storeFile value: ${keystoreProperties.getProperty("storeFile")}")
} else {
    println("❌ key.properties NOT found at ${keystorePropertiesFile.absolutePath}")
    throw GradleException("key.properties not found! Please create it with your signing configuration.")
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.sommie"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
       applicationId = "io.sommie"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "tv.yunbiao.yuanjielive"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "tv.yunbiao.yuanjielive"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("config") { // 注意这里使用 create("config")
            keyAlias = "leadlive"
            keyPassword = "123456"
            storeFile = file("G:\\flutter_project_2026\\yuanjielive\\android\\lead_live.jks")
            storePassword = "123456"
        }

    }
    buildTypes {
        getByName("release") {
            // 使用之前创建的 config
            signingConfig = signingConfigs.getByName("config")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("config")
        }
    }
}

flutter {
    source = "../.."
}

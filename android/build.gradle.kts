buildscript {

    repositories {
        google() // Google官方仓库
        mavenCentral() // Maven中央仓库（官方源，应包含缺失的包）
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
        maven { url = uri("https://maven.aliyun.com/repository/releases") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/groups/public") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/repositories/releases") }
    }

    dependencies {
        // 更新 Android Gradle Plugin 版本
        classpath("com.android.tools.build:gradle:8.3.2")  // 对应 Gradle 8.13
    }
}

allprojects {
    repositories {
        google() // Google官方仓库
        mavenCentral() // Maven中央仓库（官方源，应包含缺失的包）
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
        maven { url = uri("https://maven.aliyun.com/repository/releases") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/groups/public") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/repositories/releases") }
    }

}

subprojects {
    afterEvaluate {
        val p = this
        // 检查该子项目（插件）是否有 android 配置块
        if (p.extensions.findByName("android") != null) {
            val android = p.extensions.getByName("android") as com.android.build.gradle.BaseExtension

            // 1. 针对特定的直播插件强制注入 namespace
            if (p.name == "flutter_livepush_plugin") {
                android.namespace = "com.alivc.livepush"
            }

            // 2. 通用兜底：如果其他插件也没有 namespace，则根据 project 路径自动生成一个
            if (android.namespace == null) {
                android.namespace = p.group.toString().ifEmpty { "temp.namespace.${p.name}" }
            }
        }
    }
}


val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

# Flutter ProGuard Rules

# Keep Flutter Engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Keep all native methods and their classes
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes that are referenced by the Flutter engine
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Speech Recognition
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Local Auth / Biometrics
-keep class androidx.biometric.** { *; }
-keep class androidx.core.hardware.fingerprint.** { *; }

# Flutter Sound
-keep class com.doranteseaso.flauto.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Permission Handler  
-keep class com.baseflow.permissionhandler.** { *; }

# Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Drift/SQLite  
-keep class com.tekartik.sqflite.** { *; }
-keep class org.sqlite.** { *; }

# General Android optimizations
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep Gson classes (if using JSON)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep all annotations
-keepattributes *Annotation*

# Keep source file names and line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Rename source file attribute to hide original source file name
-renamesourcefileattribute SourceFile
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.bootstrap.** { *; }
-keep class io.flutter.anywhere.** { *; }

# AdMob
-keep class com.google.android.gms.ads.** { *; }

# ML Kit (Standard rules)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.ml.** { *; }

# JNI
-keepclasseswithmembernames class * {
    native <methods>;
}

# Ignore Play Core (referenced by Flutter Engine but not used)
-dontwarn com.google.android.play.core.**

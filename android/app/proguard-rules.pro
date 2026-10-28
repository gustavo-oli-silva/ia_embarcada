# Flutter Wrapper & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Flutter Deferred Components / Play Core (classes opcionais da Play Store referenciadas pelo Flutter Engine)
-dontwarn com.google.android.play.core.**

# Google ML Kit Image Labeling plugin
-keep class com.google_mlkit_image_labeling.** { *; }
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Play Services / ML Kit internal vision dependencies
-keep class com.google.android.gms.internal.mlkit_vision_label.** { *; }
-dontwarn com.google.android.gms.internal.mlkit_vision_label.**
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.android.gms.vision.**

# Preserva métodos nativos chamados via JNI
-keepclasseswithmembernames class * {
    native <methods>;
}


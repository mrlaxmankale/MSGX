# ProGuard and R8 rules for MSGX Android Release Builds

# Keep AudioService and background playback handlers
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }

# Keep native sqflite SQLite bindings
-keep class com.tekartik.sqflite.** { *; }

# Keep Flutter engine embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }


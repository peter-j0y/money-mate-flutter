# Flutter 엔진/플러그인 임베딩 클래스 보존 (플러그인 등록 리플렉션 대비)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Firebase Crashlytics: 스택트레이스 심볼 관련 클래스 보존
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

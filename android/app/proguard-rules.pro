## Keep AppAuth and FlutterAppAuth classes and members to avoid stripping state handling
-keep class net.openid.appauth.** { *; }
-dontwarn net.openid.appauth.**

-keep class io.crossingthestreams.flutterappauth.** { *; }
-dontwarn io.crossingthestreams.flutterappauth.**

## Keep AndroidX Browser, CustomTabs, and Activity result APIs used by AppAuth
-keep class androidx.browser.** { *; }
-dontwarn androidx.browser.**

-keep class androidx.activity.result.** { *; }
-dontwarn androidx.activity.result.**

## Keep Kotlin metadata to avoid reflective issues
-keep class kotlin.Metadata { *; }


package com.example.use_this

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourapp/search_engine_detection"
    private val LAUNCHER_CHANNEL = "com.yourapp/browser_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledSearchEngines") {
                val browsers = getInstalledBrowsers()
                result.success(browsers)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LAUNCHER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchBrowser") {
                val url = call.argument<String>("url")
                val packageName = call.argument<String>("package")
                try {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                    if (packageName != null && packageName.isNotEmpty()) {
                        intent.setPackage(packageName)
                    }
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Could not launch browser", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getInstalledBrowsers(): List<String> {
        val pm = packageManager
        val browsers = mutableListOf<String>()
        val browserPackages = mapOf(
            "com.android.chrome" to "Chrome",
            "org.mozilla.firefox" to "Firefox",
            "com.microsoft.emmx" to "Edge",
            "com.opera.browser" to "Opera",
            "com.brave.browser" to "Brave",
            "com.sec.android.app.sbrowser" to "Samsung Internet"
        )

        for ((pkg, name) in browserPackages) {
            try {
                pm.getPackageInfo(pkg, 0)
                browsers.add(name)
            } catch (e: PackageManager.NameNotFoundException) {
                // Not installed
            }
        }
        return browsers
    }
}
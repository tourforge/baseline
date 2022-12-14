package org.opentourbuilder.guide

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("org.opentourbuilder.guide.MapLibrePlatformView",
                MapLibrePlatformViewFactory(flutterEngine.dartExecutor.binaryMessenger))
    }
}

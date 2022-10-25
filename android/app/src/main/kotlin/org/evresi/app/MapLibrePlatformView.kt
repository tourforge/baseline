package org.evresi.app

import android.content.Context
import android.view.View
import com.mapbox.geojson.FeatureCollection
import io.flutter.plugin.platform.PlatformView
import com.mapbox.mapboxsdk.maps.MapView
import com.mapbox.mapboxsdk.camera.CameraPosition
import com.mapbox.mapboxsdk.Mapbox
import com.mapbox.mapboxsdk.geometry.LatLng
import com.mapbox.mapboxsdk.maps.MapboxMap
import com.mapbox.mapboxsdk.maps.Style
import com.mapbox.mapboxsdk.style.sources.GeoJsonSource
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.IllegalArgumentException

class MapLibrePlatformView(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
    messenger: BinaryMessenger
) : PlatformView {
    private val mapView: MapView
    private val channel = MethodChannel(messenger, "evresi.org/app/map")
    private lateinit var locationSource: GeoJsonSource
    private var map: MapboxMap? = null

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {}

    init {
        if (creationParams == null) {
            throw IllegalArgumentException()
        }

        channel.setMethodCallHandler { call, result -> handleMethodCall(call, result) }

        val styleText = creationParams["style"] as String
        val pathGeoJson = creationParams["pathGeoJson"] as String
        val pointsGeoJson = creationParams["pointsGeoJson"] as String

        // Initialize MapLibre
        Mapbox.getInstance(context)

        mapView = MapView(context)
        mapView.getMapAsync { map ->
            handleMapLoaded(
                map = map,
                styleText = styleText,
                pathGeoJson = pathGeoJson,
                pointsGeoJson = pointsGeoJson,
            )
        }
    }

    private fun handleMapLoaded(
        map: MapboxMap,
        styleText: String,
        pathGeoJson: String,
        pointsGeoJson: String
    ) {
        this.map = map

        map.uiSettings.setAttributionMargins(15, 0, 0, 15)
        map.cameraPosition = CameraPosition.Builder()
            .target(LatLng(34.0, -80.0))
            .zoom(10.0)
            .build()

        locationSource = GeoJsonSource("current_location")
        map.setStyle(Style.Builder()
            .fromJson(styleText)
            .withSource(locationSource)
            .withSource(GeoJsonSource("tour_path",
                FeatureCollection.fromJson(pathGeoJson)))
            .withSource(GeoJsonSource("tour_points",
                FeatureCollection.fromJson(pointsGeoJson))))

        map.addOnCameraMoveListener {
            val cameraPosition = map.cameraPosition
            channel.invokeMethod(
                "updateCameraPosition", mapOf(
                    "lat" to cameraPosition.target.latitude,
                    "lng" to cameraPosition.target.longitude,
                    "zoom" to cameraPosition.zoom + 1,
                )
            )
        }

    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "updateLocation" -> {
                locationSource.setGeoJson(call.arguments as String)
                result.success(null)
            }
        }
    }
}

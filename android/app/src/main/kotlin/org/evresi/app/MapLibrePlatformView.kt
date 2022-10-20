package org.evresi.app

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.TextView
import io.flutter.plugin.platform.PlatformView
import com.mapbox.mapboxsdk.maps.MapView
import com.mapbox.mapboxsdk.camera.CameraPosition
import com.mapbox.mapboxsdk.Mapbox
import com.mapbox.mapboxsdk.WellKnownTileServer
import com.mapbox.mapboxsdk.geometry.LatLng

class MapLibrePlatformView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    private val mapView: MapView

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {}

    init {
        val mapTilerKey = "snTep1JxPBFgkJqXe562"
        val styleUrl = "https://api.maptiler.com/maps/streets/style.json?key=${mapTilerKey}"
        Mapbox.getInstance(context, mapTilerKey, WellKnownTileServer.MapLibre)
        mapView = MapView(context)
        mapView.getMapAsync { map ->
            // Set the style after mapView was loaded
            map.setStyle(styleUrl) {
                map.uiSettings.setAttributionMargins(15, 0, 0, 15)
                // Set the map view center
                map.cameraPosition = CameraPosition.Builder()
                    .target(LatLng(34.0, -80.0))
                    .zoom(10.0)
                    .build()
            }
        }
    }
}

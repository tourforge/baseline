package org.evresi.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.view.View
import com.mapbox.geojson.FeatureCollection
import io.flutter.plugin.platform.PlatformView
import com.mapbox.mapboxsdk.maps.MapView
import com.mapbox.mapboxsdk.camera.CameraPosition
import com.mapbox.mapboxsdk.Mapbox
import com.mapbox.mapboxsdk.WellKnownTileServer
import com.mapbox.mapboxsdk.geometry.LatLng
import com.mapbox.mapboxsdk.maps.Style
import com.mapbox.mapboxsdk.style.expressions.Expression
import com.mapbox.mapboxsdk.style.layers.*
import com.mapbox.mapboxsdk.style.sources.GeoJsonSource

class MapLibrePlatformView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    private val mapView: MapView

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {}

    init {
        val mapTilerKey = creationParams!!["mapTilerKey"] as String
        val styleUrl = "https://api.maptiler.com/maps/streets/style.json?key=${mapTilerKey}"
        Mapbox.getInstance(context, mapTilerKey, WellKnownTileServer.MapLibre)
        mapView = MapView(context)
        mapView.getMapAsync { map ->
            // Set the style after mapView was loaded
            map.setStyle(styleUrl) { style ->
                map.uiSettings.setAttributionMargins(15, 0, 0, 15)
                // Set the map view center
                map.cameraPosition = CameraPosition.Builder()
                    .target(LatLng(34.0, -80.0))
                    .zoom(10.0)
                    .build()

                val pathFeatureCollection = FeatureCollection.fromJson(creationParams["pathGeoJson"] as String)
                style.addSource(GeoJsonSource("pathFeatureCollection", pathFeatureCollection))
                style.addLayer(
                    LineLayer("pathLineLayer", "pathFeatureCollection")
                        .withProperties(
                            PropertyFactory.lineCap(Property.LINE_CAP_ROUND),
                            PropertyFactory.lineJoin(Property.LINE_JOIN_ROUND),
                            PropertyFactory.lineOpacity(.7f),
                            PropertyFactory.lineWidth(7f),
                            PropertyFactory.lineColor("#ff0000")
                        )
                )

                val pointsFeatureCollection = FeatureCollection.fromJson(creationParams["pointsGeoJson"] as String)
                style.addSource(GeoJsonSource("pointsFeatureCollection", pointsFeatureCollection))
                style.addLayer(
                    CircleLayer("pointsCircleLayer", "pointsFeatureCollection")
                        .withProperties(
                            PropertyFactory.circleRadius(16.0f),
                            PropertyFactory.circleColor("#ff0000"),
                            PropertyFactory.circleStrokeColor("#000000"),
                            PropertyFactory.circleStrokeWidth(4.0f),
                        )
                )
                style.addLayer(
                    SymbolLayer("pointsSymbolLayer", "pointsFeatureCollection")
                        .withProperties(
                            PropertyFactory.textField(Expression.get("number")),
                            PropertyFactory.textColor("#ffffff"),
                            PropertyFactory.textSize(18.0f),
                            PropertyFactory.textIgnorePlacement(true),
                        )
                )
            }
        }
    }
}

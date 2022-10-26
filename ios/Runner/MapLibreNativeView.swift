import Mapbox
import Flutter
import UIKit

class MapLibreNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return MapLibreNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class MapLibreNativeView: NSObject, FlutterPlatformView, MGLMapViewDelegate {
    private var _view: UIView
    private var _locationSource: MGLShapeSource = MGLShapeSource(identifier: "current_location", shape: MGLShapeCollectionFeature())
    private var _channel: FlutterMethodChannel
    private var _mapView: MGLMapView?
    
    private var _tilesUrl: String
    private var _pathGeoJson: String
    private var _pointsGeoJson: String

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _channel = FlutterMethodChannel(name: "evresi.org/app/map", binaryMessenger: messenger)
        _tilesUrl = (args as! Dictionary<String, Any>)["tilesUrl"] as! String
        _pathGeoJson = (args as! Dictionary<String, Any>)["pathGeoJson"] as! String
        _pointsGeoJson = (args as! Dictionary<String, Any>)["pointsGeoJson"] as! String
        super.init()
        _channel.setMethodCallHandler(handleMethodCall)
        let stylePath = (args as! Dictionary<String, Any>)["stylePath"] as! String
        createNativeView(view: _view, stylePath: stylePath)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView, stylePath: String) {
        _view.backgroundColor = UIColor.white
        
        // create the map view
        let mapView = MGLMapView(frame: _view.bounds, styleURL: URL(fileURLWithPath: stylePath))
        
        _mapView = mapView
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.logoView.isHidden = true
        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(
            CLLocationCoordinate2D(latitude: 47.127757, longitude: 8.579139),
            zoomLevel: 10,
            animated: false)
        
        _view.addSubview(mapView)
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        let tilesSource = MGLVectorTileSource(identifier: "openmaptiles", tileURLTemplates: [_tilesUrl])
        style.addSource(tilesSource)
        
        var pathShape: MGLShape
        do {
            pathShape = try MGLShape(data: _pathGeoJson.data(using: String.Encoding.utf8)!, encoding: String.Encoding.utf8.rawValue)
        } catch {
            print("BAD")
            return
        }
        let pathSource = MGLShapeSource(identifier: "tour_path", shape: pathShape)
        style.addSource(pathSource)
        
        var pointsShape: MGLShape
        do {
            pointsShape = try MGLShape(data: _pointsGeoJson.data(using: String.Encoding.utf8)!, encoding: String.Encoding.utf8.rawValue)
        } catch {
            print("BAD")
            return
        }
        let pointsSource = MGLShapeSource(identifier: "tour_points", shape: pointsShape)
        style.addSource(pointsSource)
        
        style.addSource(_locationSource)
    }
    
    func mapView(_ mapView: MGLMapView, regionIsChangingWith reason: MGLCameraChangeReason) {
        _channel.invokeMethod("updateCameraPosition", arguments: [
            "lat": _mapView!.camera.centerCoordinate.latitude,
            "lng": _mapView!.camera.centerCoordinate.longitude,
            "zoom": _mapView!.zoomLevel + 1,
        ])
    }
    
    func handleMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        if (call.method == "updateLocation") {
            do {
                self._locationSource.shape = try MGLShape(data: (call.arguments as! String).data(using: String.Encoding.utf8)!, encoding: String.Encoding.utf8.rawValue)
            } catch {
                print("BAD")
            }
        }
    }
}

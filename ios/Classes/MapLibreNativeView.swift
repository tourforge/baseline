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
    private var _locationSource: MGLShapeSource
    private var _channel: FlutterMethodChannel
    private var _mapView: MGLMapView?
    
    private var _pathGeoJson: String
    private var _pointsGeoJson: String
    private var _locationGeoJson: String?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _channel = FlutterMethodChannel(name: "tourforge.org/guide/map", binaryMessenger: messenger)
        _pathGeoJson = (args as! Dictionary<String, Any>)["pathGeoJson"] as! String
        _pointsGeoJson = (args as! Dictionary<String, Any>)["pointsGeoJson"] as! String
        _locationSource = MGLShapeSource(identifier: "current_location", shape: MGLShapeCollectionFeature())
        super.init()
        _channel.setMethodCallHandler(handleMethodCall)
        let stylePath = (args as! Dictionary<String, Any>)["stylePath"] as! String
        let lat = ((args as! Dictionary<String, Any>)["center"] as! Dictionary<String, Any>)["lat"] as! Double
        let lng = ((args as! Dictionary<String, Any>)["center"] as! Dictionary<String, Any>)["lng"] as! Double
        let zoom = (args as! Dictionary<String, Any>)["zoom"] as! Double
        createNativeView(view: _view, stylePath: stylePath, lat: lat, lng: lng, zoom: zoom)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView, stylePath: String, lat: Double, lng: Double, zoom: Double) {
        _view.backgroundColor = UIColor.white
        // create the map view
        let mapView = MGLMapView(frame: _view.bounds, styleURL: URL(fileURLWithPath: stylePath))
        
        _mapView = mapView
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.compassView.isHidden = true
        mapView.attributionButton.isHidden = true
        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(
            CLLocationCoordinate2D(latitude: lat, longitude: lng),
            zoomLevel: zoom,
            animated: false)
        
        _view.addSubview(mapView)
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        var pathShape: MGLShape
        do {
            pathShape = try MGLShape(data: _pathGeoJson.data(using: String.Encoding.utf8)!, encoding: String.Encoding.utf8.rawValue)
        } catch {
            print("BAD")
            return
        }
        let pathSource = MGLShapeSource(identifier: "tour_path", shape: pathShape)
        style.addSource(pathSource)
        
        var pointsShape: MGLShapeCollection
        do {
            pointsShape = try MGLShape(data: _pointsGeoJson.data(using: String.Encoding.utf8)!, encoding: String.Encoding.utf8.rawValue) as! MGLShapeCollection
        } catch {
            print("BAD")
            return
        }
        let pointsSource = MGLShapeSource(identifier: "tour_points", shape: pointsShape)
        style.addSource(pointsSource)
        
        for shape in pointsShape.shapes {
            // Add each waypoint as an annotation. These are made transparent in the mapView(..., imageFor annotation) method,
            // since they are being displayed through pointsSource.
            mapView.addAnnotation(shape)
        }
        
        style.addSource(_locationSource)
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // fully transparent 32x32 PNG from GIMP
        let data = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAABImlDQ1BJQ0MgcHJvZmlsZQAAKJGdkLFKw1AUhr9UsSI6VRykQwYdCy52cqkKQbAQYwWjU5qkWExiSFKKb+Cb6MN0EARfwV3B2f9GBwezeOBwPg7n/P+5F1p2Eqbl8h6kWVU43sC/9K/s9hsWXTq02Q3CMh+47imN8fmqacVLz2g1z/0ZK1FchqoLZRbmRQXWgbg/r3LDSjZvR96R+EFsR2kWiZ/EO1EaGTa7XprMwh9Nc816nF2cm76yi8MJQ1xsxsyYklDRU83UOabPvqpDQcA9JaFqQqzeXDMVN6JSSg6HopFI1zT4bdd+rlzG0phKyzjckUrT+GH+93vt46zetLYWeVAEdWtJ2ZpM4P0RNnzoPMPadYPX6u+3Ncz065l/vvEL5NBQY40R6psAAAACYktHRAD/h4/MvwAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAAd0SU1FB+cBHBMIG7zmHsAAAAAZdEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIEdJTVBXgQ4XAAAAIUlEQVRIx2P8z0AZYGIYNWDUgFEDRg0YNWDUgFEDhpkBACOIAT96to3gAAAAAElFTkSuQmCC")!
        let img = UIImage(data: data)!
        
        return MGLAnnotationImage(image: img, reuseIdentifier: "empty-32x32-png")
    }
    
    func mapView(_ mapView: MGLMapView, shouldChangeFrom oldCamera: MGLMapCamera, to newCamera: MGLMapCamera) -> Bool {
        _channel.invokeMethod("moveUpdate", arguments: [])
        return true
    }
    
    func mapView(_ mapView: MGLMapView, regionIsChangingWith reason: MGLCameraChangeReason) {
        _channel.invokeMethod("updateCameraPosition", arguments: [
            "lat": _mapView!.camera.centerCoordinate.latitude,
            "lng": _mapView!.camera.centerCoordinate.longitude,
            "zoom": _mapView!.zoomLevel + 1,
        ])
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        _channel.invokeMethod("pointClick", arguments: [
            "index": Int((annotation as! MGLPointFeature).attributes["number"] as! String)! - 1
        ])
    }
    
    func handleMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        if (call.method == "updateLocation") {
            do {
                _locationGeoJson = (call.arguments as! String)
                self._locationSource.shape =
                    try MGLShape(data: _locationGeoJson!.data(using: String.Encoding.utf8)!, encoding: String.Encoding.utf8.rawValue)
            } catch {
                print("BAD")
            }
        }
        if (call.method == "setStyle") {
            let stylePath = call.arguments as! String
            _locationSource = MGLShapeSource(identifier: "current_location", shape: MGLShapeCollectionFeature())
            do {
                if (_locationGeoJson != nil) {
                    self._locationSource.shape =
                        try MGLShape(data: _locationGeoJson!.data(using: String.Encoding.utf8)!, encoding: String.Encoding.utf8.rawValue)
                }
            } catch {
                print("BAD")
            }
            self._mapView?.styleURL = URL(fileURLWithPath: stylePath)
        }
        if (call.method == "moveCamera") {
            let args = call.arguments as! Dictionary<String, Any>
            let lat = args["lat"] as! Double
            let lng = args["lng"] as! Double
            let duration  = args["duration"] as! Double
            self._mapView!.setCenter(
                CLLocationCoordinate2D(latitude: lat, longitude: lng),
                animated: true)
        }
    }
}

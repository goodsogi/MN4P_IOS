//
//  GoogleMapDrawingManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 19..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

//Google Map 드로잉 관리 
class GoogleMapDrawingManager {
    
    var firstPolyline : GMSPolyline!
    var firstPolylineEdge : GMSPolyline!
    var secondPolyline : GMSPolyline!
    var secondPolylineEdge : GMSPolyline!
    var startMarker: GMSMarker!
    var endMarker: GMSMarker!
    
    var currentLocationMarker:GMSMarker!
    var selectedPlaceMarker:GMSMarker!
    
    var mapView:GMSMapView!
    
    var geofenceMarker: GMSMarker?
    
    var firstDistanceFromCurrentLocationToRoutePoint = 0
        
    public func setMapView(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    
    private func clearMap() {
        mapView.clear()
    }
    
    
    private func getScaledImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func drawRouteOnMap(firstDirectionModel:DirectionModel,secondDirectionModel:DirectionModel, isFindRouteViewController:Bool) {
        
        clearMap()
        
        drawStartEndMarker(directionModel: firstDirectionModel)
        
        if(isFindRouteViewController) {
            drawSubPolyline(directionModel:secondDirectionModel)
        }
        
        drawMainPolyline(directionModel: firstDirectionModel)
        
        if(isFindRouteViewController) {
        zoomMapWithPolyline()
        }
    }
    
    private func zoomMapWithPolyline() {
        //경로가 모두 표시되게 zoom 조정        
        
        ActionDelayManager.run(seconds: 1) { () -> () in // change 2 to desired number of seconds
            //fit map to markers
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(self.startMarker.position)
            bounds = bounds.includingCoordinate(self.endMarker.position)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
            self.mapView.animate(with: update)
        }
    }
    
    private func drawMainPolyline(directionModel:DirectionModel) {
        //두번째 옵션의 경로 polyline 그림
        let path = getPath(directionModel: directionModel)
        
        firstPolylineEdge = getPolyline(path:path, strokeWidth:9.0, strokeColor: HexColorManager.colorWithHexString(hexString: "0078FF"))
        firstPolylineEdge.map = mapView
        
        firstPolyline = getPolyline(path:path, strokeWidth:6.0, strokeColor: HexColorManager.colorWithHexString(hexString: "32AAFF"))
        firstPolyline.map = mapView
    }
    
    private func drawSubPolyline(directionModel:DirectionModel) {
        //두번째 옵션의 경로 polyline 그림
        let path = getPath(directionModel: directionModel)
        
        secondPolylineEdge = getPolyline(path:path, strokeWidth:9.0, strokeColor: HexColorManager.colorWithHexString(hexString: "B38DAFC0"))
        secondPolylineEdge.map = mapView
        
        secondPolyline = getPolyline(path:path, strokeWidth:6.0, strokeColor: HexColorManager.colorWithHexString(hexString: "B3A3CADE"))
        secondPolyline.map = mapView
        
    }
    
    
    private func getPolyline(path:GMSMutablePath, strokeWidth:CGFloat, strokeColor:UIColor) -> GMSPolyline{
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = strokeWidth
        polyline.strokeColor = strokeColor
        polyline.geodesic = true
        
        return polyline
    }
    
    
    private func getPath(directionModel:DirectionModel) -> GMSMutablePath {
        
        let path = GMSMutablePath()
        
        for routePointModel in directionModel.getRoutePointModels()! {
            path.addLatitude(routePointModel.getLat()!, longitude: routePointModel.getLng()!)
        }
        
        return path
    }
    
    private func drawStartEndMarker(directionModel:DirectionModel) {
        
        startMarker = GMSMarker()
        
        startMarker.position = CLLocationCoordinate2D(latitude: directionModel.getRoutePointModels()![0].getLat()!, longitude: directionModel.getRoutePointModels()![0].getLng()!)
        startMarker.title = "start marker"
        startMarker.icon = self.getScaledImage(image: UIImage(named: "start_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        startMarker.map = self.mapView
        
        endMarker = GMSMarker()
        
        endMarker.position = CLLocationCoordinate2D(latitude: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLat()!, longitude: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLng()!)
        endMarker.title = "end marker"
        endMarker.icon = self.getScaledImage(image: UIImage(named: "destination_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        endMarker.map = self.mapView
    }
    
    //********************************************************************************************************
    //
    // MainViewController(메인화면)
    //
    //********************************************************************************************************
    
    
    public func createCurrentLocationMarker() {
        currentLocationMarker = GMSMarker()
        
        currentLocationMarker.position = CLLocationCoordinate2D(latitude: 37.534459, longitude: 126.983314)
        currentLocationMarker.title = "current location marker"
        currentLocationMarker.icon = self.getScaledImage(image: UIImage(named: "current_location_marker.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        currentLocationMarker.map = self.mapView
    }
    
    
    public func showFirstCurrentLocationOnMap(userLocation: CLLocation , isNavigationViewController : Bool) {
        
        let zoomValue : Float = isNavigationViewController ? 18 : 14
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: zoomValue)
        mapView.camera = camera
       
        
    }
    
    public func showCurrentLocationMarker(userLocation: CLLocation)  {
  
currentLocationMarker.position = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude , longitude: userLocation.coordinate.longitude )
        
    }
    
    
    public func showSelectedPlaceOnMap(selectedPlaceModel:PlaceModel) {
        
        let camera = GMSCameraPosition.camera(withLatitude: selectedPlaceModel.getLatitude() ?? 0, longitude: selectedPlaceModel.getLongitude() ?? 0, zoom: 14)
        mapView.camera = camera
        
        
        if(selectedPlaceMarker == nil) {
            selectedPlaceMarker = GMSMarker()
            selectedPlaceMarker.position = CLLocationCoordinate2D(latitude: selectedPlaceModel.getLatitude() ?? 0, longitude: selectedPlaceModel.getLongitude() ?? 0)
            selectedPlaceMarker.title = "selected place marker"
            selectedPlaceMarker.map = self.mapView
        } else {
            selectedPlaceMarker.position = CLLocationCoordinate2D(latitude: selectedPlaceModel.getLatitude() ?? 0, longitude: selectedPlaceModel.getLongitude() ?? 0)
            
        }
    }
    
    //********************************************************************************************************
    //
    // NavigationViewController(경로안내화면)
    //
    //********************************************************************************************************
    
    public func setMapPadding(topPadding: CGFloat) {
        let mapInsets = UIEdgeInsets(top: topPadding, left: 0.0, bottom: 0.0, right: 0.0)
        mapView.padding = mapInsets
    }
    
    public func showGeofenceMarker(geofenceModel: RoutePointModel) {
        
        if(geofenceMarker == nil) {
            geofenceMarker = GMSMarker()
            geofenceMarker!.title = "geofence marker"
            geofenceMarker!.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            geofenceMarker!.icon = self.getScaledImage(image: UIImage(named: "geofence_dot.png")!, scaledToSize: CGSize(width: 20.0, height: 20.0))
            geofenceMarker!.map = self.mapView
        }
        
        geofenceMarker!.position = CLLocationCoordinate2D(latitude: geofenceModel.getLat()!, longitude: geofenceModel.getLng()!)
        
    }
    
    public func refreshMap(geofenceModel: RoutePointModel, currentRoutePointLocation: CLLocation, currentLocation: CLLocation) {

        //위치와 베어링을 한번에 갱신하도록 수정
      
        let currentLocationCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        let targetBearingInt: Int = getBearing(currentRoutePointLocation : currentRoutePointLocation, currentLocation : currentLocation)
        
        let myNewCamera = GMSCameraPosition.init(target: currentLocationCoordinate, zoom: mapView.camera.zoom, bearing: Double(targetBearingInt), viewingAngle: 0)
        
        mapView.camera = myNewCamera
        
    }
    
    public func showFirstRoute(firstDirectionModel:DirectionModel,secondDirectionModel:DirectionModel) {
        removeAllPolylines()
        drawSubPolyline(directionModel: secondDirectionModel)
        drawMainPolyline(directionModel: firstDirectionModel)
    }
    
    public func showSecondRoute(firstDirectionModel:DirectionModel,secondDirectionModel:DirectionModel) {
        removeAllPolylines()
        drawSubPolyline(directionModel: firstDirectionModel)
        drawMainPolyline(directionModel: secondDirectionModel)
        
    }
    
    public func setFirstDistanceFromCurrentLocationToRoutePoint(distance : Int) {
        firstDistanceFromCurrentLocationToRoutePoint = distance
    }
    
    
    private func removeAllPolylines() {
        firstPolylineEdge.map = nil
        firstPolyline.map = nil
        secondPolylineEdge.map = nil
        secondPolyline.map = nil
    }
    
    private func getBearing(currentRoutePointLocation: CLLocation, currentLocation: CLLocation) -> Int {
        var targetBearingInt: Int = 0
        
        
        if(isCurrentLocationAwayFromRoutePoint(currentRoutePointLocation : currentRoutePointLocation, currentLocation : currentLocation)) {
            targetBearingInt = Int(BearingManager.getBearingBetweenTwoPoints1(point1: currentRoutePointLocation, point2: currentLocation))
          
        } else {
            targetBearingInt = Int(BearingManager.getBearingBetweenTwoPoints1(point1: currentLocation, point2: currentRoutePointLocation))
           
        }
        
        return targetBearingInt
    }
    
    private func isCurrentLocationAwayFromRoutePoint(currentRoutePointLocation: CLLocation, currentLocation: CLLocation) -> Bool{
        
        let currentDistance : Int = Int(currentRoutePointLocation.distance(from: currentLocation))
        
        var isAway : Bool = false
        
        
        if( currentDistance - firstDistanceFromCurrentLocationToRoutePoint > 20) {
            isAway = true
            
        } else {
            isAway = false
          
        }
        
        
        return isAway
    }
    
}

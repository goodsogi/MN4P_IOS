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
   
    var polyline : GMSPolyline?
    var polylineEdge : GMSPolyline?
  
    var startMarker: GMSMarker?
    var endMarker: GMSMarker?
    
    var currentLocationMarker:GMSMarker?
    var selectedPlaceMarker:GMSMarker?
    
    var mapView:GMSMapView!
    
    var geofenceMarker: GMSMarker?
    
    var navigationMarker: GMSMarker?
    
    var firstDistanceFromCurrentLocationToRoutePoint = 0
        
    public func setMapView(mapView: GMSMapView) {
        self.mapView = mapView
        
   
    }
    
    
    public func clearMap() {
        mapView.clear()
    }
    
   
    /*
     메인 화면
     */
    
    public func clearMainOverlay() {
        print("plusapps clearMainOverlay")
        currentLocationMarker?.map = nil
        currentLocationMarker = nil
    }
    
    
    
    private func createCurrentLocationMarker(userLocation: CLLocation) {
       
        currentLocationMarker = GMSMarker()
        
        //아래 코드를 사용하면 마커가 표시안됨, userLocation.coordinate를 사용해야 하는 듯
       // currentLocationMarker?.position = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        currentLocationMarker?.position = userLocation.coordinate
        currentLocationMarker?.title = "current location marker"
        currentLocationMarker?.icon = self.getScaledImage(image: UIImage(named: "current_location_marker.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
       
        currentLocationMarker?.map = self.mapView
    }
    
    
    
    private func moveMapToLocation(userLocation: CLLocation) {
        
        let zoomValue : Float = 14
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: zoomValue)
        mapView.camera = camera
    }
    
    
    func moveMapToPosition(userLocation: CLLocation , isNavigationViewController : Bool) {
        
        let zoomValue : Float = isNavigationViewController ? 18 : 14
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: zoomValue)
        mapView.camera = camera
    }
    
    private func refreshCurrentLocationMarker(userLocation: CLLocation) {
        currentLocationMarker?.position = userLocation.coordinate
    }
    
   
    
    func showCurrentLocationMarker(userLocation: CLLocation)  {
       
        if (currentLocationMarker == nil) {        
            createCurrentLocationMarker(userLocation: userLocation)
            moveMapToLocation(userLocation: userLocation)
        } else {
            refreshCurrentLocationMarker(userLocation: userLocation);
        }
        
       
    }
    
    
    
    /*
     장소정보 화면
     */
    func showPlaceMarker(selectedPlaceModel:PlaceModel) {
        
                
        if(selectedPlaceMarker == nil) {
            createPlaceMarker(placeModel : selectedPlaceModel)
        } else {         
            refreshPlaceMarker(placeModel : selectedPlaceModel);
        }
        
        animateMapToLocation(placeModel : selectedPlaceModel);
        
       
              
    }
    
    private func animateMapToLocation(placeModel:PlaceModel) {
       
        let cameraPosition = GMSCameraPosition.camera(withLatitude: placeModel.getLatitude() ?? 0, longitude: placeModel.getLongitude() ?? 0, zoom: 14)
        mapView.animate(to: cameraPosition)
    }


    
    private func refreshPlaceMarker(placeModel:PlaceModel) {
        selectedPlaceMarker?.position = CLLocationCoordinate2D(latitude: placeModel.getLatitude() ?? 0, longitude: placeModel.getLongitude() ?? 0)
    }
    
    public func createPlaceMarker(placeModel:PlaceModel) {
        selectedPlaceMarker = GMSMarker()
        selectedPlaceMarker?.position = CLLocationCoordinate2D(latitude: placeModel.getLatitude() ?? 0, longitude: placeModel.getLongitude() ?? 0)
        selectedPlaceMarker?.icon = self.getScaledImage(image: UIImage(named: "place_marker.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        selectedPlaceMarker?.title = "selected place marker"
        selectedPlaceMarker?.map = self.mapView
    }
    
    func clearPlaceInfoOverlay() {
        selectedPlaceMarker?.map = nil
        selectedPlaceMarker = nil
    }
    
    /*
     경로정보 화면
     */
    
    
    func clearRouteInfoOverlay() {
        polylineEdge?.map = nil
        polylineEdge = nil
        polyline?.map = nil
        polyline = nil
        
        startMarker?.map = nil
       
              
        endMarker?.map = nil
        endMarker = nil
    }
    
    
    
    public func showRouteOverlays(directionModel: DirectionModel) {
       
        
        drawStartEndMarker(directionModel: directionModel)
        
        drawPolyline(directionModel: directionModel)
        
        zoomMapWithPolyline()
        
    }
    
    private func getScaledImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
   
    
    private func zoomMapWithPolyline() {
        //경로가 모두 표시되게 zoom 조정
        
        ActionDelayManager.run(seconds: 1) { () -> () in // change 2 to desired number of seconds
            //fit map to markers
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(self.startMarker!.position)
            bounds = bounds.includingCoordinate(self.endMarker!.position)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
            self.mapView.animate(with: update)
        }
    }
    
    private func drawPolyline(directionModel:DirectionModel) {
        //두번째 옵션의 경로 polyline 그림
        let path = getPath(directionModel: directionModel)
        
        polylineEdge = getPolyline(path:path, strokeWidth:9.0, strokeColor: HexColorManager.colorWithHexString(hexString: "0078FF"))
        polylineEdge?.map = mapView
        
        polyline = getPolyline(path:path, strokeWidth:6.0, strokeColor: HexColorManager.colorWithHexString(hexString: "32AAFF"))
        polyline?.map = mapView
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
        
        startMarker?.position = CLLocationCoordinate2D(latitude: directionModel.getRoutePointModels()![0].getLat()!, longitude: directionModel.getRoutePointModels()![0].getLng()!)
        startMarker?.title = "start marker"
        startMarker?.icon = self.getScaledImage(image: UIImage(named: "start_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        startMarker?.map = self.mapView
        
        endMarker = GMSMarker()
        
        endMarker?.position = CLLocationCoordinate2D(latitude: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLat()!, longitude: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLng()!)
        endMarker?.title = "end marker"
        endMarker?.icon = self.getScaledImage(image: UIImage(named: "destination_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        endMarker?.map = self.mapView
    }
   
    
    /*
     경로안내 화면
     */
    
    func clearNavigationOverlays() {
        polylineEdge?.map = nil
        polylineEdge = nil
        polyline?.map = nil
        polyline = nil
              
        endMarker?.map = nil
        endMarker = nil
        
        
        geofenceMarker?.map = nil
        geofenceMarker = nil
        
        navigationMarker?.map = nil
        navigationMarker = nil
    }
    
    
    
    public func showNavigationOverlays(directionModel: DirectionModel) {
      
        
        drawEndMarker(directionModel: directionModel)
        
        drawPolyline(directionModel: directionModel)
        
        zoomMapWithPolyline()
        
    }
    
    
    private func drawEndMarker(directionModel:DirectionModel) {
        
        endMarker = GMSMarker()
        
        endMarker?.position = CLLocationCoordinate2D(latitude: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLat()!, longitude: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLng()!)
        endMarker?.title = "end marker"
        endMarker?.icon = self.getScaledImage(image: UIImage(named: "destination_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        endMarker?.map = self.mapView
    }
    
    public func setMapPadding(bottomPadding: CGFloat) {
        let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomPadding, right: 0.0)
        mapView.padding = mapInsets
    }
    
    public func showGeofenceMarker(geofenceModel: GeofenceModel) {
        
        if (geofenceMarker == nil) {
            createGeofenceMarker(geofenceModel: geofenceModel)
                } else {
                    refreshGeofenceMarker(geofenceModel: geofenceModel)
                }
      
    }
    
    public func showNavigationMarker(nearestSegmentedRoutePoint: CLLocation) {
        
        if (navigationMarker == nil) {
            createNavigationMarker(nearestSegmentedRoutePoint: nearestSegmentedRoutePoint)
                } else {
                    refreshNavigationMarker(nearestSegmentedRoutePoint: nearestSegmentedRoutePoint)
                }
      
    }
    
    private func refreshNavigationMarker(nearestSegmentedRoutePoint: CLLocation) {
        navigationMarker!.position = nearestSegmentedRoutePoint.coordinate
    }
    
    private func createNavigationMarker(nearestSegmentedRoutePoint: CLLocation) {
        navigationMarker = GMSMarker()
        navigationMarker!.title = "navigation marker"
        navigationMarker!.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        navigationMarker!.position = nearestSegmentedRoutePoint.coordinate
        navigationMarker!.icon = self.getScaledImage(image: UIImage(named: "navigation_marker.png")!, scaledToSize: CGSize(width: 20.0, height: 20.0))
        navigationMarker!.map = self.mapView
    }
    
    
    
    private func refreshGeofenceMarker(geofenceModel: GeofenceModel) {
        geofenceMarker!.position = CLLocationCoordinate2D(latitude: geofenceModel.getLat() ?? 0, longitude: geofenceModel.getLng() ?? 0)
    }
    
    private func createGeofenceMarker(geofenceModel: GeofenceModel) {
        geofenceMarker = GMSMarker()
        geofenceMarker!.title = "geofence marker"
        geofenceMarker!.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        geofenceMarker!.position = CLLocationCoordinate2D(latitude: geofenceModel.getLat() ?? 0, longitude: geofenceModel.getLng() ?? 0)
        geofenceMarker!.icon = self.getScaledImage(image: UIImage(named: "geofence_dot.png")!, scaledToSize: CGSize(width: 20.0, height: 20.0))
        geofenceMarker!.map = self.mapView
    }
    
    public func updateMapBearingAndZoom(currentGeofenceLocation: CLLocation, nextGeofenceLocation: CLLocation) {
 
        
        ActionDelayManager.run(seconds: 1) { () -> () in // change 2 to desired number of seconds
            //zoom 처리
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(currentGeofenceLocation.coordinate)
            bounds = bounds.includingCoordinate(nextGeofenceLocation.coordinate)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
            self.mapView.animate(with: update)
            
            ActionDelayManager.run(seconds: 1) { () -> () in
            //베어링 처리
            
            let targetBearing: Double =  self.getBearing(currentGeofenceLocation : currentGeofenceLocation, nextGeofenceLocation : nextGeofenceLocation)
            
            //TODO 시작 좌표값이 맞는지 확인하세요
            let myNewCamera = GMSCameraPosition.init(target: currentGeofenceLocation.coordinate, zoom:  self.mapView.camera.zoom, bearing: targetBearing , viewingAngle: 0)
            
            self.mapView.camera = myNewCamera
            }
        }
        
        
    }
   
    public func setFirstDistanceFromCurrentLocationToRoutePoint(distance : Int) {
        firstDistanceFromCurrentLocationToRoutePoint = distance
    }
    
  
    
    private func getBearing(currentGeofenceLocation: CLLocation, nextGeofenceLocation: CLLocation) -> Double {
        let targetBearing: Double = BearingManager.getBearingBetweenTwoPoints1(point1: currentGeofenceLocation, point2: nextGeofenceLocation)
        
// TODO 아래 코드가 불필요하면 삭제하세요
//        if(isCurrentLocationAwayFromRoutePoint(currentRoutePointLocation : currentRoutePointLocation, currentLocation : currentLocation)) {
//            targetBearingInt = Int(BearingManager.getBearingBetweenTwoPoints1(point1: currentRoutePointLocation, point2: currentLocation))
//
//        } else {
//            targetBearingInt = Int(BearingManager.getBearingBetweenTwoPoints1(point1: currentLocation, point2: currentRoutePointLocation))
//
//        }
        
        return targetBearing
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

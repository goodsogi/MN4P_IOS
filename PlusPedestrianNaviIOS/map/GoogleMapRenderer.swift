//
//  GoogleMapDrawingManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 19..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapRenderer : IMapRenderer {
   
    /*
     Map 공통
     */
    
    var mapView: GMSMapView?
    
    
    func setMap(mapView: Any) {
        self.mapView = mapView as? GMSMapView
      
    }
    
    
    func setMapPadding(value: CGFloat) {
        let mapInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: value, right: 0.0)
        mapView?.padding = mapInsets
    }
    
    
    func moveMapToLocation(location: CLLocation) {
        
        let zoomValue : Float = 14
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomValue)
        mapView?.camera = camera
        
       
    }
     
    
    func clearMap(screenType: Int) {
       
        //TODO 추가 수정하세요
        switch (screenType) {
        
        case Mn4pConstants.MAIN:
            clearMainOverlay()
            break
        case Mn4pConstants.PLACE_INFO:
            clearPlaceInfoOverlay()
            break
            
        case Mn4pConstants.ROUTE_INFO:
            clearRouteInfoOverlay()
            break
        case Mn4pConstants.NAVIGATION:
            clearNavigationOverlays()
            break
        default:
            break
        }
        
    }
    
    private func animateMapToLocation(placeModel:PlaceModel) {
       
        let cameraPosition = GMSCameraPosition.camera(withLatitude: placeModel.getLatitude() ?? 0, longitude: placeModel.getLongitude() ?? 0, zoom: 14)
        mapView?.animate(to: cameraPosition)
    }

    private func clearMap() {
        mapView?.clear()
    }
    
    
    /*
     Main 화면
     */
    
    var currentLocationMarker:GMSMarker?
    
    
    func showCurrentLocationMarker(currentLocation: CLLocation)  {
      
        if (currentLocationMarker == nil) {
            createCurrentLocationMarker(userLocation: currentLocation)
            moveMapToLocation(location: currentLocation)
        } else {
            refreshCurrentLocationMarker(userLocation: currentLocation);
        }
        
       
    }
    
    
    private func createCurrentLocationMarker(userLocation: CLLocation) {
       
        currentLocationMarker = GMSMarker()
        
        //아래 코드를 사용하면 마커가 표시안됨, userLocation.coordinate를 사용해야 하는 듯
       // currentLocationMarker?.position = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        currentLocationMarker!.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        currentLocationMarker?.position = userLocation.coordinate
        currentLocationMarker?.title = "current location marker"
        currentLocationMarker?.icon = self.getScaledImage(image: UIImage(named: "current_location_marker.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
       
        currentLocationMarker?.map = self.mapView
       
    }
    
    
     private func refreshCurrentLocationMarker(userLocation: CLLocation) {
         currentLocationMarker?.position = userLocation.coordinate
     }
    
    
    private func clearMainOverlay() {
        currentLocationMarker?.map = nil
        currentLocationMarker = nil
    }
        
    
    func applyAngleToCurrentLocationMarker(angle: Double) {
       //TODO 구현하세요
        
    }
    
    /*
     ChooseOnMap 화면
     */
    
    func getMapCenterLatitude() {
        //TODO 구현하세요
    }
    
    func getMapCenterLongitude() {
        //TODO 구현하세요
    }
    
    
    /*
     PlaceInfo 화면
     */
    
    
    var placeMarker:GMSMarker?
    
    
    func showPlaceMarker(placeModel:PlaceModel) {
        
                
        if(placeMarker == nil) {
            createPlaceMarker(placeModel : placeModel)
        } else {
            refreshPlaceMarker(placeModel : placeModel);
        }
        
        animateMapToLocation(placeModel : placeModel);
        
       
              
    }
    
    private func refreshPlaceMarker(placeModel:PlaceModel) {
        placeMarker?.position = CLLocationCoordinate2D(latitude: placeModel.getLatitude() ?? 0, longitude: placeModel.getLongitude() ?? 0)
    }
    
    private func createPlaceMarker(placeModel:PlaceModel) {
        placeMarker = GMSMarker()
        placeMarker?.position = CLLocationCoordinate2D(latitude: placeModel.getLatitude() ?? 0, longitude: placeModel.getLongitude() ?? 0)
        placeMarker?.icon = self.getScaledImage(image: UIImage(named: "place_marker.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        placeMarker?.title = "selected place marker"
        placeMarker?.map = self.mapView
    }
    
    private func clearPlaceInfoOverlay() {
        placeMarker?.map = nil
        placeMarker = nil
    }
    
    
    /*
     RouteInfo 화면
     */
    
    var polyline : GMSPolyline?
    var polylineEdge : GMSPolyline?
  
    var startPointMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    
    
    func showRouteOverlays(directionModel: DirectionModel) {
       
        clearMap()
        
        addPolylineToMap(directionModel: directionModel)
        
        addStartPointMarker(directionModel: directionModel)
        
        addDestinationMarker(directionModel: directionModel)
        
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
            bounds = bounds.includingCoordinate(self.startPointMarker!.position)
            bounds = bounds.includingCoordinate(self.destinationMarker!.position)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
            self.mapView?.animate(with: update)
        }
    }
    
    private func addPolylineToMap(directionModel:DirectionModel) {
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
    
    private func addStartPointMarker(directionModel:DirectionModel) {
        
        startPointMarker = GMSMarker()
        
        startPointMarker?.position = CLLocationCoordinate2D(latitude: directionModel.getRoutePointModels()![0].getLat()!, longitude: directionModel.getRoutePointModels()![0].getLng()!)
        startPointMarker?.title = "start marker"
        startPointMarker?.icon = self.getScaledImage(image: UIImage(named: "start_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        startPointMarker?.map = self.mapView
      
    }
   
    
    
    private func addDestinationMarker(directionModel:DirectionModel) {
     
        
        destinationMarker?.position = CLLocationCoordinate2D(latitude: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLat()!, longitude: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLng()!)
        destinationMarker?.title = "end marker"
        destinationMarker?.icon = self.getScaledImage(image: UIImage(named: "destination_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0))
        destinationMarker?.map = self.mapView
    }
   
    private func clearRouteInfoOverlay() {
        polylineEdge?.map = nil
        polylineEdge = nil
        polyline?.map = nil
        polyline = nil
        
        startPointMarker?.map = nil
       
              
        destinationMarker?.map = nil
        destinationMarker = nil
    }
    
    
    /*
     Navigation 화면
     */
    
    var geofenceMarker: GMSMarker?
    
    var navigationMarker: GMSMarker?
    
    var firstDistanceFromCurrentLocationToRoutePoint = 0
    private let ZINDEX_NAVIGATION_MARKER: Int32 = 10
    private let ZINDEX_GEOFENCE_MARKER: Int32 = 7
    
    func showProgress(progress: Double) {
       //TODO 구현하세요
    }
    
    func showNavigationOverlays(directionModel: DirectionModel) {
      
        clearMap()
        
        addPolylineToMap(directionModel: directionModel)
        
        addDestinationMarker(directionModel: directionModel)
        
        zoomMapWithPolyline()
        
    }
    
    
   
    func showOverview(angle : Double) {
        zoomMapWithPolyline()
        applyAngleToNavigationMarker(angle: angle)
    }
    
    func showGeofenceMarker(geofenceModel: GeofenceModel) {
        
        if (geofenceMarker == nil) {
            createGeofenceMarker(geofenceModel: geofenceModel)
                } else {
                    refreshGeofenceMarker(geofenceModel: geofenceModel)
                }
      
    }
    
    func showNavigationMarker(nearestSegmentedRoutePoint: CLLocation) {
        
        if (navigationMarker == nil) {
            createNavigationMarker(nearestSegmentedRoutePoint: nearestSegmentedRoutePoint)
                } else {
                    refreshNavigationMarker(nearestSegmentedRoutePoint: nearestSegmentedRoutePoint)
                }
      
    }
    
   
    func updateMapBearingAndZoom(currentGeofenceLocation: CLLocation, nextGeofenceLocation: CLLocation) {
 
        
        ActionDelayManager.run(seconds: 1) { () -> () in // change 2 to desired number of seconds
            //zoom 처리
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(currentGeofenceLocation.coordinate)
            bounds = bounds.includingCoordinate(nextGeofenceLocation.coordinate)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
            self.mapView?.animate(with: update)
            
            ActionDelayManager.run(seconds: 1) { () -> () in
            //베어링 처리
            
            let targetBearing: Double =  self.getBearing(currentGeofenceLocation : currentGeofenceLocation, nextGeofenceLocation : nextGeofenceLocation)
            
            //TODO 시작 좌표값이 맞는지 확인하세요
            let myNewCamera = GMSCameraPosition.init(target: currentGeofenceLocation.coordinate, zoom:  self.mapView?.camera.zoom ?? 0, bearing: targetBearing , viewingAngle: 30 )
            
            self.mapView?.camera = myNewCamera
            }
        }
    }
   
    
    func handleExitFromOverview( ) {
        applyAngleToNavigationMarker(angle: 0)
        //TODO 필요시 구현하세요
        //restoreMapToPreviousState()
    }
    
    
    private func refreshNavigationMarker(nearestSegmentedRoutePoint: CLLocation) {
        navigationMarker!.position = nearestSegmentedRoutePoint.coordinate
    }
    
    private func createNavigationMarker(nearestSegmentedRoutePoint: CLLocation) {
        navigationMarker = GMSMarker()
        navigationMarker!.title = "navigation marker"
        navigationMarker!.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        navigationMarker!.position = nearestSegmentedRoutePoint.coordinate
        navigationMarker!.zIndex = ZINDEX_NAVIGATION_MARKER
        navigationMarker!.icon = self.getScaledImage(image: UIImage(named: "navigation_marker.png")!, scaledToSize: CGSize(width: 60.0, height: 60.0))
        navigationMarker!.map = self.mapView
    }
    
    
    
    private func refreshGeofenceMarker(geofenceModel: GeofenceModel) {
        geofenceMarker!.position = CLLocationCoordinate2D(latitude: geofenceModel.getLat() ?? 0, longitude: geofenceModel.getLng() ?? 0)
    }
    
    private func createGeofenceMarker(geofenceModel: GeofenceModel) {
        geofenceMarker = GMSMarker()
        geofenceMarker!.title = "geofence marker"
        geofenceMarker!.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        geofenceMarker!.zIndex = ZINDEX_GEOFENCE_MARKER
        geofenceMarker!.position = CLLocationCoordinate2D(latitude: geofenceModel.getLat() ?? 0, longitude: geofenceModel.getLng() ?? 0)
        geofenceMarker!.icon = self.getScaledImage(image: UIImage(named: "geofence_dot.png")!, scaledToSize: CGSize(width: 20.0, height: 20.0))
        geofenceMarker!.map = self.mapView
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
    
    private func applyAngleToNavigationMarker(angle : Double) {
        navigationMarker?.rotation = angle
    }
    
    private func clearNavigationOverlays() {
        polylineEdge?.map = nil
        polylineEdge = nil
        polyline?.map = nil
        polyline = nil
              
        destinationMarker?.map = nil
        destinationMarker = nil
        
        
        geofenceMarker?.map = nil
        geofenceMarker = nil
        
        navigationMarker?.map = nil
        navigationMarker = nil
    }
    
    
    /*
    SearchNearby 화면
     */
    
    func showSearchNearbyPlaceMarkers() {
       //TODO 구현하세요
    }
    
    func enlargeZoomForSearchNearby() {
        //TODO 구현하세요
    }
    
    func handleMarkerClick(placeModelOfSelectedMarker: PlaceModel) {
        //TODO 구현하세요
    }
    
    func resetSelectedMarkerIcon() {
        //TODO 구현하세요
    }
   
    
    
}

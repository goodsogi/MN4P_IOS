//
//  GoogleMapDrawingManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 19..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import NMapsMap

class NaverMapRenderer : IMapRenderer {
   
    /*
     Map 공통
     */
    
    var mapView: NMFMapView?
    var mapContainer: UIView?
    
    func setMap(mapView: Any) {
        self.mapView = mapView as? NMFMapView
    }
    
    func setMapContainer(mapContainer: UIView) {
        self.mapContainer = mapContainer
    }
    
    
    func setMapPadding(value: CGFloat) {
        
        //mapContainer의 높이를 조절하는 것으로 네이버 지도의 높이를 조절 불가능
        //mapContainer의 높이를 줄이면 네이버 지도가 이상한 위치에 표시됨
        
        //mapContainer의 inset을 사용해야 함, inset은 안드로이드의 padding에 해당하는 듯
        //dy는 해딩 패딩값의 절반임 
        
        let dyValue: CGFloat = value / 2 
        self.mapView!.superview!.bounds = self.mapView!.superview!.frame.insetBy(dx: 0, dy: dyValue)
        
        //네이버지도 로고를 표시하기 위해 contentInset 지정
        //contentInset을 지정하면 마커의 위치가 이상해져 사용안하는 것이 좋을 듯
       // let insets = UIEdgeInsets(top: 0, left: 0, bottom: dyValue, right: 0)
       // self.mapView!.contentInset = insets
        
    }
    
    
    func moveMapToLocation(location: CLLocation) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude), zoomTo: 14)
        mapView?.moveCamera(cameraUpdate)
       
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
       
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat:  placeModel.getLatitude() ?? 0, lng: placeModel.getLongitude() ?? 0), zoomTo: 17)
        cameraUpdate.animation = .easeIn
        mapView?.moveCamera(cameraUpdate)
        
        
      
    }

    private func clearMap() {
        polyline?.mapView = nil
        polyline = nil
        
        startPointMarker?.mapView = nil
        //startPointMarker = nil
        
        destinationMarker?.mapView = nil
        destinationMarker = nil
        
        geofenceMarker?.mapView = nil
        geofenceMarker = nil
        
        navigationMarker?.mapView = nil
        navigationMarker = nil
    }
    
    
    /*
     Main 화면
     */
    
    var currentLocationMarker: NMFMarker?
    
    
    func showCurrentLocationMarker(currentLocation: CLLocation)  {
       
        if (currentLocationMarker == nil) {
            createCurrentLocationMarker(userLocation: currentLocation)
            moveMapToLocation(location: currentLocation)
        } else {
            refreshCurrentLocationMarker(userLocation: currentLocation);
        }
        
       
    }
    
    
    private func createCurrentLocationMarker(userLocation: CLLocation) {
       
        currentLocationMarker = NMFMarker()
        currentLocationMarker?.anchor = CGPoint(x: 0.5, y: 0.5)
        //아래 코드를 사용하면 마커가 표시안됨, userLocation.coordinate를 사용해야 하는 듯
       // currentLocationMarker?.position = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        currentLocationMarker?.position = NMGLatLng(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
        currentLocationMarker?.iconImage = NMFOverlayImage(image: self.getScaledImage(image: UIImage(named: "current_location_marker.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0)))
       
        currentLocationMarker?.mapView = self.mapView
    }
    
    
     private func refreshCurrentLocationMarker(userLocation: CLLocation) {
        currentLocationMarker?.position = NMGLatLng(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
      
     }
    
    
    private func clearMainOverlay() {
        currentLocationMarker?.mapView = nil
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
    
    
    var placeMarker: NMFMarker?
    
    
    func showPlaceMarker(placeModel:PlaceModel) {
        
                
        if(placeMarker == nil) {
            createPlaceMarker(placeModel : placeModel)
        } else {
            refreshPlaceMarker(placeModel : placeModel);
        }
        
        animateMapToLocation(placeModel : placeModel);
        
       
              
    }
    
    private func refreshPlaceMarker(placeModel:PlaceModel) {
        placeMarker?.position = NMGLatLng(lat:  placeModel.getLatitude() ?? 0, lng: placeModel.getLongitude() ?? 0)
      
    }
    
    private func createPlaceMarker(placeModel:PlaceModel) {
        placeMarker = NMFMarker()
        
        placeMarker?.position = NMGLatLng(lat:  placeModel.getLatitude() ?? 0, lng: placeModel.getLongitude() ?? 0)
        placeMarker?.iconImage = NMFOverlayImage(image: self.getScaledImage(image: UIImage(named: "place_marker.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0)))
       
        placeMarker?.mapView = self.mapView
     
    }
    
    private func clearPlaceInfoOverlay() {
        placeMarker?.mapView = nil
        placeMarker = nil
    }
    
    
    /*
     RouteInfo 화면
     */
    
    var polyline : NMFPath?
    
    var startPointMarker: NMFMarker?
    var destinationMarker: NMFMarker?
    private let ZINDEX_POLYLINE: Int  = 3
    
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
            //TODO 제대로 zoom이 표시되는지 확인하세요
            
            
            
            //TODO 필요시 아래 코드 사용하세요
//            let zoomLevel: Double = NMFCameraUtils.getFittableZoomLevel(with: <#T##NMGLatLngBounds#>, insets: <#T##UIEdgeInsets#>, mapView: mapView!)

            if (self.startPointMarker == nil) {
                print("plusapps startPointMarker == nil")
            }
            
            print("plusapps self.startPointMarker!.position ", self.startPointMarker!.position)
            
            
           
            
            let bounds = NMGLatLngBounds()
            bounds.southWest = NMGLatLng(lat: max(self.startPointMarker!.position.lat, self.destinationMarker!.position.lat), lng: min(self.startPointMarker!.position.lng, self.destinationMarker!.position.lng))
            bounds.northEast = NMGLatLng(lat: min(self.startPointMarker!.position.lat, self.destinationMarker!.position.lat), lng: max(self.startPointMarker!.position.lng, self.destinationMarker!.position.lng))
             
            //TODO 경로정보 화면과 경로안내 화면 처리하세요
            var insets = UIEdgeInsets()
            insets.top = 50
            insets.bottom = 50
            insets.left = 50
            insets.right = 50
            
            let cameraUpdate = NMFCameraUpdate(fit: bounds, paddingInsets: insets)
            cameraUpdate.animation = .easeIn
            self.mapView?.moveCamera(cameraUpdate)
        }
    }
    
    private func addPolylineToMap(directionModel:DirectionModel) {
        polyline = NMFPath()
        let path = getPath(directionModel: directionModel)
        
        polyline?.path = path
        polyline?.width = 6
        polyline?.outlineWidth = 3
        polyline?.patternIcon = NMFOverlayImage(name: "path_pattern")
        polyline?.patternInterval = 20
        polyline?.color = HexColorManager.colorWithHexString(hexString: "#32AAFF")
        polyline?.outlineColor = HexColorManager.colorWithHexString(hexString: "#0078FF")
        polyline?.passedColor = HexColorManager.colorWithHexString(hexString: "#8b8e94")
        polyline?.passedOutlineColor = HexColorManager.colorWithHexString(hexString: "#ffffff")
        polyline?.zIndex = ZINDEX_POLYLINE
        polyline?.progress = 0
        polyline?.mapView = mapView
       
    }
    
    
    private func getPath(directionModel:DirectionModel) -> NMGLineString<AnyObject> {
        
        let path = NMGLineString<AnyObject>()
        
        for routePointModel in directionModel.getRoutePointModels()! {
            path.addPoint(NMGLatLng(lat: routePointModel.getLat()!, lng: routePointModel.getLng()!))
          }
        
        return path
    }
    
    private func addStartPointMarker(directionModel:DirectionModel) {
        
        
        startPointMarker = NMFMarker()
        
        startPointMarker?.position = NMGLatLng(lat:  directionModel.getRoutePointModels()![0].getLat()!, lng: directionModel.getRoutePointModels()![0].getLng()!)
        startPointMarker?.iconImage = NMFOverlayImage(image: self.getScaledImage(image: UIImage(named: "start_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0)))
       
        startPointMarker?.mapView = self.mapView
      
    }
   
    
    
    private func addDestinationMarker(directionModel:DirectionModel) {
     
        
        destinationMarker = NMFMarker()
        
        destinationMarker?.position = NMGLatLng(lat:  directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLat()!, lng: directionModel.getRoutePointModels()![directionModel.getRoutePointModels()!.count - 1].getLng()!)
        destinationMarker?.iconImage = NMFOverlayImage(image: self.getScaledImage(image: UIImage(named: "destination_pin.png")!, scaledToSize: CGSize(width: 50.0, height: 50.0)))
       
        destinationMarker?.mapView = self.mapView
        
  
    }
   
    private func clearRouteInfoOverlay() {
        polyline?.mapView = nil
        polyline = nil
        
        startPointMarker?.mapView = nil
        //startPointMarker = nil
              
        destinationMarker?.mapView = nil
        destinationMarker = nil
    }
    
    
    /*
     Navigation 화면
     */
    
    var geofenceMarker: NMFMarker?
    
    var navigationMarker: NMFMarker?
    
    var firstDistanceFromCurrentLocationToRoutePoint = 0
    private let ZINDEX_NAVIGATION_MARKER: Int = 10
    private let ZINDEX_GEOFENCE_MARKER: Int = 7
    
    func showProgress(progress: Double) {
        polyline?.progress = progress
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
           
            
            
            let bounds = NMGLatLngBounds()
            bounds.southWest = NMGLatLng(lat: max(currentGeofenceLocation.coordinate.latitude, nextGeofenceLocation.coordinate.latitude), lng: min(currentGeofenceLocation.coordinate.longitude, nextGeofenceLocation.coordinate.longitude))
            bounds.northEast = NMGLatLng(lat: min(currentGeofenceLocation.coordinate.latitude,nextGeofenceLocation.coordinate.latitude), lng: max(currentGeofenceLocation.coordinate.longitude, nextGeofenceLocation.coordinate.longitude))
             
            //TODO 경로정보 화면과 경로안내 화면 처리하세요
            var insets = UIEdgeInsets()
            insets.top = 100.0
            insets.bottom = 100.0
            insets.left = 100.0
            insets.right = 100.0
            
            let cameraUpdate = NMFCameraUpdate(fit: bounds, paddingInsets: insets)
            cameraUpdate.animation = .easeIn
            self.mapView?.moveCamera(cameraUpdate)
            
            
            ActionDelayManager.run(seconds: 1) { () -> () in
            //베어링 처리
            
            let targetBearing: Double =  self.getBearing(currentGeofenceLocation : currentGeofenceLocation, nextGeofenceLocation : nextGeofenceLocation)
            
            //TODO 시작 좌표값이 맞는지 확인하세요
                 let params = NMFCameraUpdateParams()
                
                let scrollPositionLat = ( currentGeofenceLocation.coordinate.latitude + nextGeofenceLocation.coordinate.latitude ) / 2
                let scrollPositionLng = ( currentGeofenceLocation.coordinate.longitude + nextGeofenceLocation.coordinate.longitude ) / 2
                let scrollPosition = NMGLatLng(lat: scrollPositionLat, lng: scrollPositionLng)
                
                params.rotate(to: targetBearing)
                params.tilt(to: 30)
                params.scroll(to: scrollPosition)
                
                
                let cameraUpdate = NMFCameraUpdate(params: params)
                
               
                cameraUpdate.animation = .easeIn
                self.mapView?.moveCamera(cameraUpdate)
            }
        }
    }
   
    
    func handleExitFromOverview( ) {
        applyAngleToNavigationMarker(angle: 0)
        //TODO 필요시 구현하세요
        //restoreMapToPreviousState()
    }
    
    
    private func refreshNavigationMarker(nearestSegmentedRoutePoint: CLLocation) {
        navigationMarker?.position = NMGLatLng(lat:  nearestSegmentedRoutePoint.coordinate.latitude, lng: nearestSegmentedRoutePoint.coordinate.longitude)
     }
    
    private func createNavigationMarker(nearestSegmentedRoutePoint: CLLocation) {
       
        navigationMarker = NMFMarker()
        navigationMarker?.anchor = CGPoint(x: 0.5, y: 0.5)
        navigationMarker?.position = NMGLatLng(lat:  nearestSegmentedRoutePoint.coordinate.latitude, lng: nearestSegmentedRoutePoint.coordinate.longitude)
        navigationMarker?.iconImage = NMFOverlayImage(image: self.getScaledImage(image: UIImage(named: "navigation_marker.png")!, scaledToSize: CGSize(width: 60.0, height: 60.0)))
        navigationMarker?.zIndex = ZINDEX_NAVIGATION_MARKER
        navigationMarker?.mapView = self.mapView
     
    }
    
    
    
    private func refreshGeofenceMarker(geofenceModel: GeofenceModel) {
        geofenceMarker?.position = NMGLatLng(lat:  geofenceModel.getLat() ?? 0, lng: geofenceModel.getLng() ?? 0)
          }
    
    private func createGeofenceMarker(geofenceModel: GeofenceModel) {
      
        
        geofenceMarker = NMFMarker()
        geofenceMarker?.anchor = CGPoint(x: 0.5, y: 0.5)
        geofenceMarker?.position = NMGLatLng(lat:  geofenceModel.getLat() ?? 0, lng: geofenceModel.getLng() ?? 0)
        geofenceMarker?.iconImage = NMFOverlayImage(image: self.getScaledImage(image: UIImage(named: "geofence_dot.png")!, scaledToSize: CGSize(width: 20.0, height: 20.0)))
        geofenceMarker?.zIndex = ZINDEX_GEOFENCE_MARKER
        geofenceMarker?.mapView = self.mapView
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
        navigationMarker?.angle = CGFloat(angle)
    }
    
    private func clearNavigationOverlays() {
       
        polyline?.mapView = nil
        polyline = nil
              
        destinationMarker?.mapView = nil
        destinationMarker = nil
        
        
        geofenceMarker?.mapView = nil
        geofenceMarker = nil
        
        navigationMarker?.mapView = nil
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

//
//  NavigationViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 21..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import CoreLocation


class NavigationViewController: UIViewController, GMSMapViewDelegate,  CLLocationManagerDelegate{
    
    
     var selectedPlaceModel:SearchPlaceModel?
        
    @IBOutlet weak var mapView: GMSMapView!
    var userLocation:CLLocation!
    
    var isFirstLocation:Bool = true
    
    let TMAP_APP_KEY:String = "c605ee67-a552-478c-af19-9675d1fc8ba3"; // 티맵 앱 key
    
    var locationManager:CLLocationManager!
    
    var googleMapDrawingManager:GoogleMapDrawingManager!
    
    var selectedRouteOption:String?
    
    var directionModel:DirectionModel!
    
    var locationCatchedTime:Double!
    
    var isGpsUnavailable: Bool! = true
    
    @IBOutlet weak var noGpsAlertBar: UIView!
    
    
    @IBOutlet weak var directionBoard: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawDirectionBoardBackground()
        initGoogleMapDrawingManager()
        determineMyCurrentLocation()
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func drawDirectionBoardBackground() {
        let img = ImageMaker.getRoundRectangleByCorners(width: 200, height: 102, colorHexString: "#288353", byRoundingCorners: [UIRectCorner.topRight , UIRectCorner.bottomRight], cornerRadii: 6.0, alpha: 0.7)
        
        directionBoard.backgroundColor = UIColor(patternImage: img)
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func initGoogleMapDrawingManager() {
        googleMapDrawingManager = GoogleMapDrawingManager()
        googleMapDrawingManager.setMapView(mapView:mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // TODO: Info.plist 수정하세요
        
        
        userLocation = locations[0] as CLLocation
      
        handleGpsAvailability()
        
        
        
        if(isFirstLocation) {
            isFirstLocation = false;
           
            getRoute()
        }
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("navigation user latitude = \(userLocation.coordinate.latitude)")
        print("navigation user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func handleGpsAvailability() {
        
        locationCatchedTime = getCurrentTimeInMillis()
        
        print("locationCatchedTime: " + locationCatchedTime.description)
        
        if(isGpsUnavailable) {
            isGpsUnavailable = false
            noGpsAlertBar.isHidden = true
        }
        
        ActionDelayManager.run(seconds: 5) { () -> () in
            if(self.isLongInterval()) {
                self.isGpsUnavailable = true
                self.noGpsAlertBar.isHidden = false
            }
        }           
    }
    
    
    func getCurrentTimeInMillis() -> Double {
        let currentDateTime = Date()
        return currentDateTime.timeIntervalSince1970
    }
   
    func isLongInterval() -> Bool {
        let currentTime: Double = getCurrentTimeInMillis()
        print("currentTime: " + currentTime.description)
        
        let interval: Double = currentTime - locationCatchedTime
        print("locationCatchedTime: " + locationCatchedTime.description)
        
        //왜 interval이 5가 아니고 10이지??
        print("interval: " + interval.description)
        
        return interval >= 4.5
    }
    
    func getRoute() {
        
        let url:String = "https://api2.sktelecom.com/tmap/routes/pedestrian?version=1&appKey=" + TMAP_APP_KEY
        
        //TODO: 나중에 passList(경유점), angle, searchOption 수정하세요
        //각도는 경로에 영향을 안미치는 듯 보임. 유효값: 0 ~ 359
        //검색 옵션 0: 추천 (기본값), 4: 추천+번화가우선, 10: 최단, 30: 최단거리+계단제외
        
        print("route option: " + selectedRouteOption!)
        
        let param = [  "startX": String(userLocation.coordinate.longitude) , "startY": String(userLocation.coordinate.latitude) , "endX": String(selectedPlaceModel?.getLng()! ?? 0) , "endY": String(selectedPlaceModel?.getLat()! ?? 0) , "angle": "0" , "searchOption": selectedRouteOption! , "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO","startName": "start", "endName": "end"]
        
        
        SpinnerView.show(onView: self.view)
        //headers: ["Content-Type":"application/json", "Accept":"application/json"] 값을 지정하면 오류 발생
        Alamofire.request(url,
                          method: .post,
                          parameters: param,
                          encoding: URLEncoding.default
            )
            .validate(statusCode: 200..<300)
            .responseJSON {
                response in
                
                switch response.result {
                case .success:
                    if let responseData = response.result.value {
                        
                        SpinnerView.remove()
                        
                      
                        self.directionModel = self.getDirectionModel(responseData: responseData);

                        self.drawRouteOnMap()
                        
                        
                    } else {
                        //TODO: 오류가 발생한 경우 처리하세요
                        SpinnerView.remove()
                        
                        
                    }
                    print("Validation Successful")
                case .failure(let error):
                    SpinnerView.remove()
                    
                    //TODO 나중에 제대로 작동하는지 확인하세요 
                    if(error.localizedDescription.contains("forbidden")) {
                        self.showOverApiAlert()
                    }
                    
                    print(error)
                }
                   
                
        }
    }
    
    func showOverApiAlert() {
              
        let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "OverApiAlertPopup")
        modalViewController!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalViewController!.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        present(modalViewController!, animated: true, completion: nil)
               
    }
    
    
    
    func drawRouteOnMap() {
        
        googleMapDrawingManager.drawRouteOnMap(firstDirectionModel: directionModel, secondDirectionModel: directionModel, isShowSecondRoute: false)
      
    }
    
    func getDirectionModel(responseData:Any) -> DirectionModel {
        let swiftyJsonVar = JSON(responseData)
        
        let directionModel:DirectionModel = DirectionModel()
        
        let routePointModels:[RoutePointModel] = self.convertToRoutePointModels(json: swiftyJsonVar)
        directionModel.setRoutePointModels(routePointModels: routePointModels)
        directionModel.setGeofenceModels(geofenceModels: self.convertToGeofenceModel(routePointModels: routePointModels))
        directionModel.setTotalTime(totalTime: swiftyJsonVar["features"][0]["properties"]["totalTime"].intValue)
        directionModel.setTotalDistance(totalDistance: swiftyJsonVar["features"][0]["properties"]["totalDistance"].intValue)
        
        return directionModel
    }
    
    func convertToGeofenceModel(routePointModels:[RoutePointModel]) -> [RoutePointModel]{
        var geofenceModels:[RoutePointModel] = [RoutePointModel]()
        
        for routePointModel in routePointModels {
            if (routePointModel.getType() == PPNConstants.TYPE_POINT) {
                geofenceModels.append(routePointModel)
            }
        }
        
        return geofenceModels
        
    }
    
    func convertToRoutePointModels(json:JSON) -> [RoutePointModel]{
        var routePointModels:[RoutePointModel] = [RoutePointModel]()
        var routePointModel:RoutePointModel
        
        var isFirstIndexPassed:Bool = false
        
        for subJson in json["features"].arrayValue {
            
            if(isFirstIndexPassed && subJson["properties"]["index"].intValue == 0) {
                break
            }
            
            if(subJson["properties"]["index"].intValue == 0) {
                isFirstIndexPassed = true;
            }
            
            if (subJson["geometry"]["type"].stringValue == "Point") {
                routePointModel = RoutePointModel()
                
                routePointModel.setLat(lat: subJson["geometry"]["coordinates"][1].doubleValue);
                routePointModel.setLng(lng: subJson["geometry"]["coordinates"][0].doubleValue);
                routePointModel.setRoadNo(roadNo: 0); //0:자전거 도로 없음
                routePointModel.setDescription(description: self.convertToKindDescription(description: subJson["properties"]["description"].stringValue));
                routePointModel.setType(type: PPNConstants.TYPE_POINT);
                routePointModels.append(routePointModel);
                
            } else {
                
                for coordinates in subJson["geometry"]["coordinates"].arrayValue {
                    routePointModel = RoutePointModel()
                    
                    routePointModel.setLat(lat: coordinates[1].doubleValue);
                    routePointModel.setLng(lng: coordinates[0].doubleValue);
                    routePointModel.setRoadNo(roadNo: subJson["properties"]["roadType"].intValue); //0:자전거 도로 없음
                    routePointModel.setDescription(description: self.convertToKindDescription(description: subJson["properties"]["description"].stringValue));
                    routePointModel.setType(type: PPNConstants.TYPE_LINE);
                    routePointModels.append(routePointModel);
                    
                }
            }
            
        }
        return routePointModels
    }
    
    func convertToKindDescription(description:String) -> String{
        if (description.contains("도착")) {
            return "잠시후 목적지에 도착합니다";
        } else {
            return description + "하세요";
        }
        
        return description;
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
//    func initMapView() {
//        let camera = GMSCameraPosition.camera(withLatitude: 37.534459, longitude: 126.983314, zoom: 14)
//        mapView.camera = camera
//    }
    
    //    func getScaledImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    //        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    //        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    //        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    //        UIGraphicsEndImageContext()
    //        return newImage
    //    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        NSLog("marker was tapped")
        //TODO 나중에 참조하세요
        //        tappedMarker = marker
        //
        //        //get position of tapped marker
        //        let position = marker.position
        //        mapView.animate(toLocation: position)
        //        let point = mapView.projection.point(for: position)
        //        let newPoint = mapView.projection.coordinate(for: point)
        //        let camera = GMSCameraUpdate.setTarget(newPoint)
        //        mapView.animate(with: camera)
        //
        //        let opaqueWhite = UIColor(white: 1, alpha: 0.85)
        //        customInfoWindow?.layer.backgroundColor = opaqueWhite.cgColor
        //        customInfoWindow?.layer.cornerRadius = 8
        //        customInfoWindow?.center = mapView.projection.point(for: position)
        //        customInfoWindow?.center.y -= 140
        //        customInfoWindow?.customWindowLabel.text = "This is my Custom Info Window"
        //        self.mapView.addSubview(customInfoWindow!)
        //
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //TODO 나중에 참조하세요
        //        customInfoWindow?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //TODO 나중에 참조하세요
        //        let position = tappedMarker?.position
        //        customInfoWindow?.center = mapView.projection.point(for: position!)
        //        customInfoWindow?.center.y -= 140
    }
    
    
    
}

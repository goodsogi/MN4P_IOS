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
import Floaty


class NavigationViewController: UIViewController, GMSMapViewDelegate,  CLLocationManagerDelegate, FloatyDelegate{
    
    
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
    
    var floaty:Floaty = Floaty()
    
    var remainDistance:Int!
    
    var previousLocation:CLLocation!
    
    @IBOutlet weak var distanceInfoView: UILabel!
    
    
    @IBOutlet weak var timeInfoView: UILabel!
    
    var timer: Timer!
    
    var pastTimeInSec:Int = 0;
    
    let DISTANCE_ENTER_GEOFENCE: Int = 20
    
    var geofenceModelIndex:Int = 0;
    
    @IBOutlet weak var directionBoard: UIView!
    
    @IBOutlet weak var directionArrow: UIImageView!
    
    @IBOutlet weak var directionInfo: UILabel!
    
    var currentGeofenceModel : RoutePointModel!
    
    @IBOutlet weak var descriptionView: UILabel!
    
    var isFirstCheck : Bool = true
    
    var routePointModelIndex:Int = 0;
    
    var currentRoutePointModel : RoutePointModel!
    
    let DISTANCE_FIRST_ENTER_ROUTE_POINT : Int = 35
    
    let DISTANCE_ENTER_ROUTE_POINT : Int = 12
    
    var currentRoutePointLocation:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawDirectionBoardBackground()
        initGoogleMapDrawingManager()
        determineMyCurrentLocation()
        initFloaty()
    }
    
    //안드로이드의 onDestroy와 같음
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(false)
        //TODO: 호출되는지 확인하세요
        timer.invalidate()
        
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
        
        let topPadding : CGFloat = mapView.frame.height - 110
        googleMapDrawingManager.setMapPadding(topPadding: topPadding)
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
    
    func getDirection() {
        
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
                        
                        self.setInitialRemainDistance()
                        
                        self.showTotalTime()
                        
                        self.showTotalDistance()
                        
                        self.startTimer()
                        
                        
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
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showRemainTime), userInfo: nil, repeats: true)
                
    }
    
    @objc func showRemainTime() {
        
        //++나 --는 사용할 수 없음
        pastTimeInSec += 1
     
        //TODO: 시간 제대로 표시되는지 확인하세요
        let remainTime : Int = directionModel.getTotalTime()! - pastTimeInSec
        let formattedTotalTime = getFormattedTotalTime(time: remainTime)
        
        timeInfoView.text = formattedTotalTime
    }
    
    func showTotalTime() {
        let totalTime: Int = directionModel.getTotalTime()!
        
        let formattedTotalTime = getFormattedTotalTime(time: totalTime)
        
        timeInfoView.text = formattedTotalTime
        
    }
    
    func getFormattedTotalTime(time: Int) -> String{
        
        
        if(time < 0) {
            return "00:00:00"
        }
        
        let sec: Int = time % 60
        let min: Int = Int(time % 3600 / 60)
        let hour: Int = Int(time / 3600)
        
        //swift도 삼항연산자를 사용할 수 있는데 ?를 괄호에 붙이면 오류발생하니 반드시 띄워야 함
        let hourString : String = (hour < 10) ? "0" + String(hour): "" + String(hour)
        let minString : String = (min < 10) ? "0" + String(min): "" + String(min)
        let secString : String = (sec < 10) ? "0" + String(sec): "" + String(sec)
        
        return hourString + ":" + minString + ":" + secString
        
        
    }
    
    
    
    func setInitialRemainDistance() {
        remainDistance = directionModel.getTotalDistance()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // TODO: Info.plist 수정하세요
        
        
        userLocation = locations[0] as CLLocation
        
        handleGpsAvailability()
        
        
        
        if(isFirstLocation) {
            isFirstLocation = false;
            
            getDirection()
        } else {
            
            showRemainDistance()
            checkIfEnteredGeofence()
            checkIfEnteredRoutePoint()
            refreshMap()
        }
        
        previousLocation = userLocation



        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("navigation user latitude = \(userLocation.coordinate.latitude)")
        print("navigation user longitude = \(userLocation.coordinate.longitude)")
    }
    
    
    private func checkIfEnteredRoutePoint() {
        
        currentRoutePointModel = directionModel.getRoutePointModels()![routePointModelIndex]
        
        currentRoutePointLocation = CLLocation(latitude: currentRoutePointModel.getLat()!, longitude: currentRoutePointModel.getLng()!)
        
        if(isFirstCheck) {
            isFirstCheck = false
            setFirstDistanceFromCurrentLocationToRoutePoint()
            
        }
        
        
        if(isEnteredRoutePoint()) {
            
            handleRoutePointEntered()
           
        }
    }
    
    private func isEnteredRoutePoint() -> Bool {
        
       
        
        if(routePointModelIndex == 0) {
            return Int(currentRoutePointLocation.distance(from: userLocation)) < DISTANCE_FIRST_ENTER_ROUTE_POINT
        } else {
        
        return Int(currentRoutePointLocation.distance(from: userLocation)) < DISTANCE_ENTER_ROUTE_POINT
            
        }
    }
    
    private func handleRoutePointEntered() {
        
        routePointModelIndex += 1
        
        if(routePointModelIndex == directionModel.getRoutePointModels()?.count) {
            routePointModelIndex -= 1
        }
        
        setFirstDistanceFromCurrentLocationToRoutePoint()
        
    }
    
    
    private func setFirstDistanceFromCurrentLocationToRoutePoint() {
        
        
        let distance : Int = Int(currentRoutePointLocation.distance(from: userLocation))
        
        googleMapDrawingManager.setFirstDistanceFromCurrentLocationToRoutePoint(distance: distance)
    }
    
    private func refreshMap() {
        googleMapDrawingManager.refreshMap(geofenceModel: currentRoutePointModel, currentRoutePointLocation: currentRoutePointLocation, currentLocation: userLocation)
    }
    
    
    private func checkIfEnteredGeofence() {
        
        currentGeofenceModel = directionModel.getGeofenceModels()![geofenceModelIndex]
        
        if(isEnteredGeofence()) {
            
            handleGeofenceEntered()
            
        }
        
    }
    
    func handleGeofenceEntered() {
        
        geofenceModelIndex += 1
        
        if(geofenceModelIndex == directionModel.getGeofenceModels()?.count) {
            //TODO: 도착 처리하세요
            
            showDirection()
            
            showGeofenceMarker()
            
            showDescription()
            
            speakDescription()
            
        }
        
    }
    
    func  showGeofenceMarker() {
        
        googleMapDrawingManager.showGeofenceMarker(geofenceModel: currentGeofenceModel)
    }
    
    func showDescription() {
        
        descriptionView.text = currentGeofenceModel.getDescription()
    }
    
    func speakDescription() {
        
        //TODO: TTS 구현하세요
        
        
    }
    
    
    
    func showDirection() {
        
        if (!(currentGeofenceModel.getDescription()?.contains("좌회전") ?? false) &&
            !(currentGeofenceModel.getDescription()?.contains("우회전") ?? false) ) {
            return
        }
        
        directionBoard.isHidden = false
        
        directionArrow.image = (currentGeofenceModel.getDescription()?.contains("좌회전") ?? false) ? UIImage(named: "turn_left_big_white.png") : UIImage(named: "turn_right_big_white.png")
        
        
       let distanceToGeofence : Int = getDistanceToGeofence()
        
        
        directionInfo.text = String(distanceToGeofence) + "m"
        
        
        ActionDelayManager.run(seconds: Double(distanceToGeofence)) { () -> () in
            self.directionBoard.isHidden = true
        }
    }
    
    
    
    func isEnteredGeofence() -> Bool {
        
        let distanceToGeofence : Int = getDistanceToGeofence()
        
        return distanceToGeofence < DISTANCE_ENTER_GEOFENCE
        
    }
    
    func getDistanceToGeofence() -> Int {
        
        let geofenceLocation:CLLocation = CLLocation(latitude: currentGeofenceModel.getLat()!, longitude: currentGeofenceModel.getLng()!)
        
        
        return Int(geofenceLocation.distance(from: userLocation))
    }
    
    
    
    
    
    
    func showTotalDistance() {
        let totalDistance: Int = directionModel.getTotalDistance()!
        
        //나누기할 때에는 Float보다 Double이 권장됨
        //나누기 기호 "/"은 앞뒤로 띄워써야 함
        //모든 숫자에 대해 Float로 캐스팅해야 함
        //Double이어도 "%.2d"가 아니라 "%.2f" 사용해야 함
        
        let remainDistanceString =  String(format: "%.2f", locale: Locale.current,Double(totalDistance) / Double(1000))
        
        
        distanceInfoView.text = remainDistanceString + "km"
    }
    
    
    func showRemainDistance() {
        
        let remainDistance: Int = getRemainDistance()
     
        //나누기할 때에는 Float보다 Double이 권장됨
        //나누기 기호 "/"은 앞뒤로 띄워써야 함
        
        let remainDistanceString =  String(format: "%.2f", locale: Locale.current,Double(remainDistance) / Double(1000))
        
        
        distanceInfoView.text = remainDistanceString + "km"
    }
    
    
    func getRemainDistance() -> Int {
        if(previousLocation == nil) {
            return remainDistance
        }
        
        let distance: Int = Int(previousLocation.distance(from: userLocation))
        
        remainDistance = remainDistance - distance
        
        if(remainDistance <= 0) {
            remainDistance = 0
        }
        
        return remainDistance
        
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
    
    
        func initFloaty() {
            floaty.buttonColor = UIColor.white
            floaty.hasShadow = true
    
    
            floaty.addItem(icon: UIImage(named: "refresh")) { item in
    
                //TODO: TTS 처리하세요("경로를 재시작합니다")
                
                self.getDirection()
            }
    
            //기본적으로 오른쪽 하단에 위치, 아래는 padding 값을 주는 것임
    //        floaty.paddingX = 40
    //        floaty.paddingY = 120
    
    
            floaty.fabDelegate = self
    
            self.view.addSubview(floaty)
    
        }
    
    // MARK: - Floaty Delegate Methods
    func floatyWillOpen(_ floaty: Floaty) {
        print("Floaty Will Open")
    }
    
    func floatyDidOpen(_ floaty: Floaty) {
        print("Floaty Did Open")
    }
    
    func floatyWillClose(_ floaty: Floaty) {
        print("Floaty Will Close")
    }
    
    func floatyDidClose(_ floaty: Floaty) {
        print("Floaty Did Close")
    }
    
}

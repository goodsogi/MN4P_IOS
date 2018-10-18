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
import AVFoundation
import GoogleMobileAds

class NavigationViewController: UIViewController, GMSMapViewDelegate,  CLLocationManagerDelegate, FloatyDelegate{
    
    var selectedPlaceModel:SearchPlaceModel?
    var selectedRouteOption:String?
    var directionModel:DirectionModel!
    @IBOutlet weak var noGpsAlertBar: UIView!
    var floaty:Floaty = Floaty()
    @IBOutlet weak var distanceInfoView: UILabel!
    @IBOutlet weak var timeInfoView: UILabel!
    var timer: Timer!
    var pastTimeInSec:Int = 0;
    @IBOutlet weak var directionBoard: UIView!
    @IBOutlet weak var directionArrow: UIImageView!
    @IBOutlet weak var directionInfo: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    var isGetDirection : Bool = false
    @IBOutlet weak var debugInfo: UILabel!
    
    //Google Map
    @IBOutlet weak var mapView: GMSMapView!
    var googleMapDrawingManager:GoogleMapDrawingManager!
    
    //Location
    var userLocation:CLLocation!
    var isFirstLocation:Bool = true
    var locationManager:CLLocationManager!
    var locationCatchedTime:Double!
    var isGpsUnavailable: Bool! = true
    var remainDistance:Int!
    var previousLocation:CLLocation!
    var currentRoutePointLocation:CLLocation!
    
    
    //Alamofire
    var alamofireManager : AlamofireManager!
    
    //경로엔진
    let DISTANCE_ENTER_GEOFENCE: Int = 20
    var geofenceModelIndex:Int = 0;
    var currentGeofenceModel : RoutePointModel!
    var isFirstCheck : Bool = true
    var routePointModelIndex:Int = 0;
    var currentRoutePointModel : RoutePointModel!
    let DISTANCE_FIRST_ENTER_ROUTE_POINT : Int = 35
    let DISTANCE_ENTER_ROUTE_POINT : Int = 12
    
    //TTS 엔진
    var synthesizer : AVSpeechSynthesizer!
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawDirectionBoardBackground()
        initGoogleMapDrawingManager()
        determineMyCurrentLocation()
        initFloaty()
        initTTS()
        showAd()
        initAlamofireManager()
    }
    
    
    //안드로이드의 onDestroy와 같음
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(false)
        //TODO: 호출되는지 확인하세요
        timer.invalidate()
        
        locationManager.stopUpdatingLocation()
    }
    
    private func drawDirectionBoardBackground() {
        let img = ImageMaker.getRoundRectangleByCorners(width: 200, height: 102, colorHexString: "#288353", byRoundingCorners: [UIRectCorner.topRight , UIRectCorner.bottomRight], cornerRadii: 6.0, alpha: 0.7)
        
        directionBoard.backgroundColor = UIColor(patternImage: img)
    }
    
    //********************************************************************************************************
    //
    // TTS
    //
    //********************************************************************************************************
    
    private func initTTS() {
        synthesizer = AVSpeechSynthesizer()
    }
    
    private func speakTTS(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.4
        
        synthesizer.speak(utterance)
    }
    
    
    //********************************************************************************************************
    //
    // 경로 엔진
    //
    //********************************************************************************************************
    
    private func startTimer() {
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
    
    private func showTotalTime() {
        let totalTime: Int = directionModel.getTotalTime()!
        
        let formattedTotalTime = getFormattedTotalTime(time: totalTime)
        
        timeInfoView.text = formattedTotalTime
        
    }
    
    private func getFormattedTotalTime(time: Int) -> String{
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
    
    
    private func setInitialRemainDistance() {
        remainDistance = directionModel.getTotalDistance()
    }
    
    private func setCurrentRoutePointLocation() {
        
        currentRoutePointModel = directionModel.getRoutePointModels()![routePointModelIndex]
        
        currentRoutePointLocation = CLLocation(latitude: currentRoutePointModel.getLat()!, longitude: currentRoutePointModel.getLng()!)
        
    }
    
    private func checkIfEnteredRoutePoint() {
        
        setCurrentRoutePointLocation()
        
        
        
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
        
        setCurrentRoutePointLocation()
        
        setFirstDistanceFromCurrentLocationToRoutePoint()
        
    }
    
    private func checkIfEnteredGeofence() {
        
        currentGeofenceModel = directionModel.getGeofenceModels()![geofenceModelIndex]
        
        if(isEnteredGeofence()) {
            
            handleGeofenceEntered()
            
        }
        
    }
    
    private func handleGeofenceEntered() {
        
        geofenceModelIndex += 1
        
        if(geofenceModelIndex <= (directionModel.getGeofenceModels()?.count)!) {
        
            
            showDirection()
            
            showGeofenceMarker()
            
            showDescription()
            
            speakDescription()
            
        }
        
    }
    
    private func  showGeofenceMarker() {
        
        googleMapDrawingManager.showGeofenceMarker(geofenceModel: currentGeofenceModel)
    }
    
    private func showDescription() {
        
        descriptionView.text = currentGeofenceModel.getDescription()
    }
    
    private func speakDescription() {
        
        speakTTS(text: currentGeofenceModel.getDescription()!)
    }
    
    private func showDirection() {
        
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
    
    private func isEnteredGeofence() -> Bool {
        
        let distanceToGeofence : Int = getDistanceToGeofence()
        
        return distanceToGeofence < DISTANCE_ENTER_GEOFENCE
        
    }
    
    private func getDistanceToGeofence() -> Int {
        
        let geofenceLocation:CLLocation = CLLocation(latitude: currentGeofenceModel.getLat()!, longitude: currentGeofenceModel.getLng()!)
        
        
        return Int(geofenceLocation.distance(from: userLocation))
    }
    
    
    private func showTotalDistance() {
        let totalDistance: Int = directionModel.getTotalDistance()!
        
        //나누기할 때에는 Float보다 Double이 권장됨
        //나누기 기호 "/"은 앞뒤로 띄워써야 함
        //모든 숫자에 대해 Float로 캐스팅해야 함
        //Double이어도 "%.2d"가 아니라 "%.2f" 사용해야 함
        
        let remainDistanceString =  String(format: "%.2f", locale: Locale.current,Double(totalDistance) / Double(1000))
        
        
        distanceInfoView.text = remainDistanceString + "km"
    }
    
    
    private func showRemainDistance() {
        
        let remainDistance: Int = getRemainDistance()
        
        //나누기할 때에는 Float보다 Double이 권장됨
        //나누기 기호 "/"은 앞뒤로 띄워써야 함
        
        let remainDistanceString =  String(format: "%.2f", locale: Locale.current,Double(remainDistance) / Double(1000))
        
        
        distanceInfoView.text = remainDistanceString + "km"
    }
    
    
    private func getRemainDistance() -> Int {
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
    
    //********************************************************************************************************
    //
    // 경로검색(Alamofire)
    //
    //********************************************************************************************************
    
    private func initAlamofireManager() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NavigationViewController.receiveAlamofireGetDirectionNotification(_:)),
                                               name: NSNotification.Name(rawValue: PPNConstants.NOTIFICATION_ALAMOFIRE_GET_DIRECTION),
                                               object: nil)
        
        alamofireManager = AlamofireManager()
    }
    
    @objc func receiveAlamofireGetDirectionNotification(_ notification: NSNotification) {
        if notification.name.rawValue == PPNConstants.NOTIFICATION_ALAMOFIRE_GET_DIRECTION {
            
            SpinnerView.remove()
            
            
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:Any] else { return }
                
                let result : String = userInfo["result"] as! String
                
                switch result {
                case "success" :
   
                    
                    self.directionModel = userInfo["directionModel"] as! DirectionModel
                        
                        
                    self.drawRouteOnMap()
                    
                    self.setInitialRemainDistance()
                    
                    self.showTotalTime()
                    
                    self.showTotalDistance()
                    
                    self.startTimer()
                    
                    self.speakTTS(text: "경로안내를 시작합니다")
                    
                    isGetDirection = true
                    
                    break;
                case "overApi" :
                    
                     self.showOverApiAlert()
                    
                     break;
                    
                case "fail" :
                    //TODO: 필요시 구현하세요
                   
                    break;
                default:
                   
                    break;
                }
                
            }
        }
    }
    
    private func getDirection() {
        
        SpinnerView.show(onView: self.view)
        
        alamofireManager.getDirection(selectedPlaceModel: selectedPlaceModel!, userLocation: userLocation, selectedRouteOption: selectedRouteOption!, notificationName : PPNConstants.NOTIFICATION_ALAMOFIRE_GET_DIRECTION)
        
      
    }
 
    private func showOverApiAlert() {
        
        OverApiManager.showOverApiAlertPopup(parentViewControler: self)
    }
    
    //********************************************************************************************************
    //
    // Location
    //
    //********************************************************************************************************
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // TODO: Info.plist 수정하세요
        
        
        userLocation = locations[0] as CLLocation
        
        
        
        
        handleGpsAvailability()
        
        
        
        if(isFirstLocation) {
            isFirstLocation = false;
            showCurrentLocationOnMap()
            getDirection()
        } else {
            
            if(isGetDirection) {
          
            showRemainDistance()
            checkIfEnteredGeofence()
            checkIfEnteredRoutePoint()
            refreshMap()
                
            }
        }
        
        previousLocation = userLocation
        
        
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        //print("navigation user latitude = \(userLocation.coordinate.latitude)")
        //print("navigation user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    private func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    private func showCurrentLocationOnMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 14)
        mapView.camera = camera
    }
    
    
    private func handleGpsAvailability() {
        
        locationCatchedTime = getCurrentTimeInMillis()
        
        //print("locationCatchedTime: " + locationCatchedTime.description)
        
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
        //print("currentTime: " + currentTime.description)
        
        let interval: Double = currentTime - locationCatchedTime
        //print("locationCatchedTime: " + locationCatchedTime.description)
        
        //왜 interval이 5가 아니고 10이지??
        //print("interval: " + interval.description)
        
        return interval >= 4.5
    }
    
    //********************************************************************************************************
    //
    // Google Map
    //
    //********************************************************************************************************
    
    
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
    
    
    //    private func initMapView() {
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
    
    private func setFirstDistanceFromCurrentLocationToRoutePoint() {
        
        
        let distance : Int = Int(currentRoutePointLocation.distance(from: userLocation))
        
        googleMapDrawingManager.setFirstDistanceFromCurrentLocationToRoutePoint(distance: distance)
    }
    
    private func refreshMap() {
        googleMapDrawingManager.refreshMap(geofenceModel: currentRoutePointModel, currentRoutePointLocation: currentRoutePointLocation, currentLocation: userLocation)
    }
    
    
    private func drawRouteOnMap() {
        
        googleMapDrawingManager.drawRouteOnMap(firstDirectionModel: directionModel, secondDirectionModel: directionModel, isShowSecondRoute: false)
        
    }
    
    private func initGoogleMapDrawingManager() {
        googleMapDrawingManager = GoogleMapDrawingManager()
        googleMapDrawingManager.setMapView(mapView:mapView)
        googleMapDrawingManager.setDebugInfo(debugInfo: debugInfo)
        
        //지도에 padding을 주면 zoom이 이상하게 표시됨. 일단 뺌 
//        let topPadding : CGFloat = mapView.frame.height - 110
//        googleMapDrawingManager.setMapPadding(topPadding: topPadding)
    }
    
    
    //********************************************************************************************************
    //
    // Admob
    //
    //********************************************************************************************************
    
    private func showAd() {
        
        let interstitial :  GADInterstitial = GADInterstitial(adUnitID: "ca-app-pub-7576584379236747/1626231340")
        let request = GADRequest()
        interstitial.load(request)
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    //********************************************************************************************************
    //
    // Floaty
    //
    //********************************************************************************************************
    
    private func initFloaty() {
        floaty.buttonColor = UIColor.white
        floaty.hasShadow = true
        
        
        floaty.addItem(icon: UIImage(named: "refresh")) { item in
            
            //TODO: TTS 처리하세요("경로를 재시작합니다")
            
            self.getDirection()
        }
        
        //기본적으로 오른쪽 하단에 위치, 아래는 padding 값을 주는 것임
        //        floaty.paddingX = 40
        floaty.paddingY = 60
        
        
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

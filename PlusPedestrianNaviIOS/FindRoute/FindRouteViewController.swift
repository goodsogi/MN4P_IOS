//
//  FindRouteViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 7..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import CoreLocation

class FindRouteViewController: UIViewController, GMSMapViewDelegate, UIScrollViewDelegate , CLLocationManagerDelegate{
    
    var selectedPlaceModel:SearchPlaceModel?
    
    @IBOutlet weak var dot1: UIView!
    @IBOutlet weak var dot2: UIView!
    
    @IBOutlet weak var startPointView: UITextField!
    @IBOutlet weak var endPointView: UITextField!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var userLocation:CLLocation!
    
    var isFirstLocation:Bool = true
    
    let TMAP_APP_KEY:String = "c605ee67-a552-478c-af19-9675d1fc8ba3"; // 티맵 앱 key
    
    var locationManager:CLLocationManager!
    
    var selectedRouteOption:Int?
    
    var firstDirectionModel:DirectionModel!
    var secondDirectionModel:DirectionModel!
    
    
    @IBOutlet weak var firstDotOnIndicator: UIImageView!
    
    @IBOutlet weak var secondDotOnIndicator: UIImageView!
    
    @IBOutlet weak var routeSelectBoard: UIScrollView!
    
    @IBOutlet weak var pagerIndicator: UIView!
    
    
    @IBOutlet weak var startButtonOnMainRoute: UIView!
    
    @IBOutlet weak var startButtonOnSubRoute: UIView!
    
    
    
    @IBOutlet weak var findRouteTopBar: UIView!
    
    @IBOutlet weak var firstRouteType: UITextField!
    
    @IBOutlet weak var firstRouteTotalTime: UITextField!
    
    @IBOutlet weak var firstRouteTotalDistance: UITextField!
    
    
    @IBOutlet weak var firstRouteDetail: UITextField!
    
    
    @IBOutlet weak var firstRouteCalorie: UITextField!
    
    
    @IBOutlet weak var secondRouteType: UITextField!
    
    
    @IBOutlet weak var secondRouteTotalTime: UITextField!
    
    
    @IBOutlet weak var secondRouteTotalDistance: UITextField!
    
    
    @IBOutlet weak var secondRouteDetail: UITextField!
    
    @IBOutlet weak var secondRouteCalorie: UITextField!
    
    var routeSelectBoardManager:RouteSelectBoardManager!
    var googleMapDrawingManager:GoogleMapDrawingManager!
    
    @IBOutlet weak var firstRouteContent: UIView!
    
    @IBOutlet weak var secondRouteContent: UIView!
    
    var previousPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routeSelectBoard.delegate = self
        ViewElevationMaker.run(view:findRouteTopBar)
        
        initGoogleMapDrawingManager()
        initRouteSelectBoardManager()
        drawMarkerLine()
        showStartPointName()
        showEndPointName()
        
        
    }
    
    func initGoogleMapDrawingManager() {
        googleMapDrawingManager = GoogleMapDrawingManager()
        googleMapDrawingManager.setMapView(mapView:mapView)
    }
    
    
    func initRouteSelectBoardManager() {
        routeSelectBoardManager = RouteSelectBoardManager()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageWidth: CGFloat = scrollView.frame.size.width
        let fractionalPage: CGFloat = scrollView.contentOffset.x / pageWidth
        let page: Int = lround(Double(fractionalPage))
        
        print("pageWidth: " + pageWidth.description + " fractionalPage: " + fractionalPage.description + "  scrollView.contentOffset.x: " + scrollView.contentOffset.x.description + " page: " + page.description + " previousPage: " + previousPage.description)
        
        if (previousPage != page) {
            // Page has changed, do your thing!
            // ...
            // Finally, update previous page
            if(page == 0) {
                showFirstRoute()
            } else if(page == 1) {
                showSecondRoute()
            }
            
            
            previousPage = page;
            
            
            
        }
    }
    
    func showFirstRoute() {
        
        //pager indicator 표시
        
        
        
        let blueDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#32AAFF", alpha: 1)
        
        
        
        firstDotOnIndicator.backgroundColor = UIColor(patternImage: blueDot)
        
        
        
        let grayDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#D9D9D9", alpha: 1)
        
        secondDotOnIndicator.backgroundColor = UIColor(patternImage: grayDot)
        
        
        googleMapDrawingManager.showFirstRoute(firstDirectionModel: firstDirectionModel, secondDirectionModel: secondDirectionModel)
        
        
    }
    
    func showSecondRoute() {
        //pager indicator 표시
        
        
        
        let grayDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#D9D9D9", alpha: 1)
        
        firstDotOnIndicator.backgroundColor = UIColor(patternImage: grayDot)
        
        
        
        let blueDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#32AAFF", alpha: 1)
        
        secondDotOnIndicator.backgroundColor = UIColor(patternImage: blueDot)
        
        googleMapDrawingManager.showSecondRoute(firstDirectionModel: firstDirectionModel, secondDirectionModel: secondDirectionModel)
        
        
    }
    
    
    func showStartPointName() {
        //TODO: 나중에 수정하세요
        startPointView.text = "내 위치"
    }
    
    func showEndPointName() {
        endPointView.text = selectedPlaceModel?.getName()
    }
    
    func getSearchOption() -> String {
        switch selectedRouteOption {
        case PPNConstants.FIRST_ROUTE_OPTION:
            //TODO 수정하세요
            return "0"
            
        case PPNConstants.SECOND_ROUTE_OPTION:
            //TODO 수정하세요
            return "4"
            
        default:
            print("getSearchOption default")
        }
        
        return "0"
    }
    
    
    func getRoute() {
        
        let url:String = "https://api2.sktelecom.com/tmap/routes/pedestrian?version=1&appKey=" + TMAP_APP_KEY
        
        //TODO: 나중에 passList(경유점), angle, searchOption 수정하세요
        //각도는 경로에 영향을 안미치는 듯 보임. 유효값: 0 ~ 359
        //검색 옵션 0: 추천 (기본값), 4: 추천+번화가우선, 10: 최단, 30: 최단거리+계단제외
        
        
        let searchOption:String = getSearchOption()
        
        
        let param = [  "startX": String(userLocation.coordinate.longitude) , "startY": String(userLocation.coordinate.latitude) , "endX": String(selectedPlaceModel?.getLng()! ?? 0) , "endY": String(selectedPlaceModel?.getLat()! ?? 0) , "angle": "0" , "searchOption": searchOption , "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO","startName": startPointView.text!, "endName": endPointView.text!]
        
        
        
        //headers: ["Content-Type":"application/json", "Accept":"application/json"] 값을 지정하면 오류 발생
        Alamofire.request(url,
                          method: .post,
                          parameters: param,
                          encoding: URLEncoding.default
            )
            .validate(statusCode: 200..<300)
            .responseJSON {
                response in
                if let responseData = response.result.value {
                    
                    //마지막으로 첫 번째 옵션의 경로 가져옴
                    if (self.selectedRouteOption == PPNConstants.FIRST_ROUTE_OPTION) {
                        
                        
                        self.firstDirectionModel = self.getDirectionModel(responseData: responseData);
                        
                        self.drawRouteOnMap()
                        self.fillOutRouteSelectBoard()
                        
                        
                        
                    }
                    
                    //두 번째 옵션의 경로를 가져옴
                    if (self.selectedRouteOption == PPNConstants.SECOND_ROUTE_OPTION) {
                        
                        
                        self.secondDirectionModel = self.getDirectionModel(responseData: responseData);
                        self.selectedRouteOption = PPNConstants.FIRST_ROUTE_OPTION
                        self.getRoute();
                    }
                    
                    
                } else {
                    //TODO: 오류가 발생한 경우 처리하세요
                    
                }
                
        }
    }
    
    func fillOutRouteSelectBoard() {
        
        
        ViewElevationMaker.run(view:firstRouteContent)
        
        ViewElevationMaker.run(view: secondRouteContent)
        
        showFirstRouteType()
        
        showFirstRouteTotalTime()
        
        showFirstRouteTotalDistance()
        
        showFirstRouteDetail()
        
        showFirstRouteCalorie()
        
        
        showSecondRouteType()
        
        showSecondRouteTotalTime()
        
        showSecondRouteTotalDistance()
        
        showSecondRouteDetail()
        
        showSecondRouteCalorie()
        
        
    }
    
    func showFirstRouteType() {
        //TODO: 수정하세요
        
        firstRouteType.text = "추천"
        
    }
    
    func showFirstRouteTotalTime() {
        let formattedTime:String = routeSelectBoardManager.getFormattedTime(time: firstDirectionModel.getTotalTime()!)
        firstRouteTotalTime.text = formattedTime
    }
    
    func showFirstRouteTotalDistance() {
        let formattedDistance:String = routeSelectBoardManager.getFormattedDistance(distance: firstDirectionModel.getTotalDistance()!)
        firstRouteTotalDistance.text = formattedDistance
    }
    
    func showFirstRouteDetail() {
        
        let routeDetail: String = routeSelectBoardManager.getRouteDetail(geofenceModels:firstDirectionModel.getGeofenceModels()!)
        firstRouteDetail.text = routeDetail
        
        
    }
    
    func showFirstRouteCalorie() {
        let calorie:String = routeSelectBoardManager.getCalorie(totalTime: firstDirectionModel.getTotalTime()!)
        firstRouteCalorie.text = calorie
    }
    
    
    func showSecondRouteType() {
        //TODO: 수정하세요
        
        secondRouteType.text = "최단거리"
        
        
        
    }
    
    func showSecondRouteTotalTime() {
        let formattedTime:String = routeSelectBoardManager.getFormattedTime(time: secondDirectionModel.getTotalTime()!)
        secondRouteTotalTime.text = formattedTime
    }
    
    func showSecondRouteTotalDistance() {
        let formattedDistance:String = routeSelectBoardManager.getFormattedDistance(distance: secondDirectionModel.getTotalDistance()!)
        secondRouteTotalDistance.text = formattedDistance
    }
    
    func showSecondRouteDetail() {
        let routeDetail: String = routeSelectBoardManager.getRouteDetail(geofenceModels:secondDirectionModel.getGeofenceModels()!)
        secondRouteDetail.text = routeDetail
    }
    
    func showSecondRouteCalorie() {
        let calorie:String = routeSelectBoardManager.getCalorie(totalTime: secondDirectionModel.getTotalTime()!)
        secondRouteCalorie.text = calorie
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
    
    
    
    func drawRouteOnMap() {
        
        googleMapDrawingManager.drawRouteOnMap(firstDirectionModel: firstDirectionModel, secondDirectionModel: secondDirectionModel, isShowSecondRoute: true)
        
        
        //경로 선택 보드 표시
        
        routeSelectBoard.isHidden = false
        pagerIndicator.isHidden = false
        
        
        
        
        let blueDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#32AAFF", alpha: 1)
        
        
        firstDotOnIndicator.backgroundColor = UIColor(patternImage: blueDot)
        
        
        
        let grayDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#D9D9D9", alpha: 1)
        
        secondDotOnIndicator.backgroundColor = UIColor(patternImage: grayDot)
        
        //시작 버튼 생성
        
        drawStartButtonBackground()
        addTapGestureToStartButton()
    }
    
    func drawStartButtonBackground() {
        
        
        let img = ImageMaker.getRoundRectangle(width: 85, height: 40, colorHexString: "#0078FF", cornerRadius: 6.0, alpha: 1)
        
        startButtonOnMainRoute.backgroundColor = UIColor(patternImage: img)
        
        startButtonOnSubRoute.backgroundColor = UIColor(patternImage: img)
    }
    
    func addTapGestureToStartButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.startButtonOnMainRouteTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        startButtonOnMainRoute.addGestureRecognizer(tapGesture)
        startButtonOnMainRoute.isUserInteractionEnabled = true
        
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.startButtonOnSubRouteTapped(_:)))
        tapGesture2.numberOfTapsRequired = 1
        tapGesture2.numberOfTouchesRequired = 1
        startButtonOnSubRoute.addGestureRecognizer(tapGesture)
        startButtonOnSubRoute.isUserInteractionEnabled = true
    }
    
    
    @objc func startButtonOnMainRouteTapped(_ sender: UITapGestureRecognizer) {
        
        let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "Navigation")
        
        //TODO: 추가 처리하세요
        
        self.present(viewController!, animated: true, completion: nil)
    }
    
    @objc func startButtonOnSubRouteTapped(_ sender: UITapGestureRecognizer) {
        
        let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "Navigation")
        
        //TODO: 추가 처리하세요
        
        self.present(viewController!, animated: true, completion: nil)
    }
    
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        let when = DispatchTime.now() + seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            completion()
        }
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
    
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func drawMarkerLine() {
        
        
        let img = ImageMaker.getCircle(width: 3, height: 3, colorHexString: "#000000", alpha: 1)
        
        
        dot1.backgroundColor = UIColor(patternImage: img)
        dot2.backgroundColor = UIColor(patternImage: img)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineMyCurrentLocation()
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
    
    func showCurrentLocationOnMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 14)
        mapView.camera = camera
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // TODO: Info.plist 수정하세요
        
        
        userLocation = locations[0] as CLLocation
        
        showCurrentLocationOnMap()
        
        if(isFirstLocation) {
            isFirstLocation = false;
            selectedRouteOption = PPNConstants.SECOND_ROUTE_OPTION
            getRoute()
        }
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("find route user latitude = \(userLocation.coordinate.latitude)")
        print("find route user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func initMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 37.534459, longitude: 126.983314, zoom: 14)
        mapView.camera = camera
    }
    
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

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

class FindRouteViewController: UIViewController, GMSMapViewDelegate , CLLocationManagerDelegate{
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawMarkerLine()
        showStartPointName()
        showEndPointName()
        
    }
    
    func showStartPointName() {
        //TODO: 나중에 수정하세요
        startPointView.text = "내 위치"
    }
    
    func showEndPointName() {
        endPointView.text = selectedPlaceModel?.getName()
    }
    
    
    func getRoute() {
        
        let url:String = "https://api2.sktelecom.com/tmap/routes/pedestrian?version=1&appKey=" + TMAP_APP_KEY
        
        //TODO: 나중에 passList(경유점), angle, searchOption 수정하세요
        //각도는 경로에 영향을 안미치는 듯 보임. 유효값: 0 ~ 359
        //검색 옵션 0: 추천 (기본값), 4: 추천+번화가우선, 10: 최단, 30: 최단거리+계단제외
        
        
        let param = [  "startX": String(userLocation.coordinate.longitude) , "startY": String(userLocation.coordinate.latitude) , "endX": String(selectedPlaceModel?.getLng()! ?? 0) , "endY": String(selectedPlaceModel?.getLat()! ?? 0) , "angle": "0" , "searchOption": "0" , "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO","startName": startPointView.text!, "endName": endPointView.text!]
        
        
        
        print("startX: " + String(userLocation.coordinate.longitude) + " startY: " +  String(userLocation.coordinate.latitude) + " endX: " +  String(selectedPlaceModel?.getLng()! ?? 0) + " endY: " + String(selectedPlaceModel?.getLat()! ?? 0)
            + " startName: " + startPointView.text! + " endName: " + endPointView.text!
        )
              
              
              
              //        let param = ["version": "1", "appKey": TMAP_APP_KEY, "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO", "startX": userLocation.coordinate.longitude , "startY": userLocation.coordinate.latitude , "endX": selectedPlaceModel?.getLng()! , "endY": selectedPlaceModel?.getLat()! , "passList": ""
//            , "angle": "0" , "searchOption": "0" , "startName": startPointView.text!, "endName": endPointView.text!] as [String : Any]
//
//
        
        
        
        
     
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
//                    let swiftyJsonVar = JSON(responseData)
//
//                    var searchPlaceModel:SearchPlaceModel
//
//                    for subJson in swiftyJsonVar["searchPoiInfo"]["pois"]["poi"].arrayValue {
//                        searchPlaceModel = SearchPlaceModel()
//
//                        let name = subJson["name"].stringValue
//                        let telNo = subJson["telNo"].stringValue
//                        let upperAddrName = subJson["upperAddrName"].stringValue
//                        let middleAddrName = subJson["middleAddrName"].stringValue
//                        let roadName = subJson["roadName"].stringValue
//                        let firstBuildNo = subJson["firstBuildNo"].stringValue
//                        let secondBuildNo = subJson["secondBuildNo"].stringValue
//                        let bizName = subJson["lowerBizName"].stringValue
//                        let lat = subJson["noorLat"].doubleValue
//                        let lng = subJson["noorLon"].doubleValue
//
//                        var address = upperAddrName + " " + middleAddrName + " " + roadName + " " + firstBuildNo
//                        if secondBuildNo != "" {
//                            address = address + "-" + secondBuildNo
//                        }
//
//
//                        searchPlaceModel.setName(name: name)
//                        searchPlaceModel.setAddress(address: address)
//                        searchPlaceModel.setLat(lat: lat)
//                        searchPlaceModel.setLng(lng: lng)
//                        searchPlaceModel.setBizname(bizName: bizName)
//                        searchPlaceModel.setTelNo(telNo: telNo)
//
//                        self.searchPlaceModels.append(searchPlaceModel)
//
//
//                    }
//
//                    self.searchPlaceTable.reloadData()
                    
                    print(responseData as Any)
                } else {
                    //TODO: 오류가 발생한 경우 처리하세요
                    
                }
                
        }
    }
        
        
    
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func drawMarkerLine() {
        
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 3, height: 3))
        let img = renderer.image {
            
            ctx in
           
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 3, height: 3)).cgPath
                        
            ctx.cgContext.addPath(circlePath)
            ctx.cgContext.setFillColor(HexColorManager.colorWithHexString(hexString: "#000000", alpha: 1).cgColor)
            
            ctx.cgContext.closePath()
            ctx.cgContext.fillPath()
            
        }
        
        
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
    
    func getScaledImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
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

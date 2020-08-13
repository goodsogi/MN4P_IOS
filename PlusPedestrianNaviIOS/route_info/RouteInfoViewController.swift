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
import GoogleMobileAds

class RouteInfoViewController: UIViewController, GMSMapViewDelegate, UIScrollViewDelegate , CLLocationManagerDelegate{
    
    var selectedPlaceModel:SearchPlaceModel?
    
    //상단 섹션
    @IBOutlet weak var dot1OnMarkerLine: UIView!
    @IBOutlet weak var dot2OnMarkerLine: UIView!
    @IBOutlet weak var startPointView: UITextField!
    @IBOutlet weak var endPointView: UITextField!
    
    //Google Map
    @IBOutlet weak var mapView: GMSMapView!
    var googleMapDrawingManager:GoogleMapDrawingManager!
    
    //Location
    var userLocation:CLLocation!
    var isFirstLocation:Bool = true
    var locationManager:CLLocationManager!
    
    //Alamofire
    var alamofireManager : AlamofireManager!
    
    //경로선택 보드
    var selectedRouteNo:Int?
    var firstDirectionModel:DirectionModel!
    var secondDirectionModel:DirectionModel!
    @IBOutlet weak var firstDotOnIndicator: UIImageView!
    @IBOutlet weak var secondDotOnIndicator: UIImageView!
    @IBOutlet weak var routeSelectBoard: UIScrollView!
    @IBOutlet weak var pagerIndicator: UIView!
    @IBOutlet weak var startButtonOnMainRoute: UIView!
    @IBOutlet weak var startButtonOnSubRoute: UIView!
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
    @IBOutlet weak var firstRouteContent: UIView!
    @IBOutlet weak var secondRouteContent: UIView!
    var previousPage: Int = 0
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeSelectBoard.delegate = self
        
        initGoogleMapDrawingManager()
        initRouteSelectBoardManager()
        drawMarkerLine()
        showStartPointName()
        showEndPointName()
        showAd()
        initAlamofireManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineMyCurrentLocation()
    }
    
    //안드로이드의 onDestroy와 같음
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(false)
        
        locationManager.stopUpdatingLocation()
    }
    
    private func showStartPointName() {
        //TODO: 나중에 수정하세요
        startPointView.text = "내 위치"
    }
    
    private func showEndPointName() {
        endPointView.text = selectedPlaceModel?.getName()
    }
    
    private func drawMarkerLine() {
        let img = ImageMaker.getCircle(width: 3, height: 3, colorHexString: "#000000", alpha: 1)
        
        dot1OnMarkerLine.backgroundColor = UIColor(patternImage: img)
        dot2OnMarkerLine.backgroundColor = UIColor(patternImage: img)
        
    }
    
    private func getRouteOption() -> String {
        switch selectedRouteNo {
        case PPNConstants.FIRST_ROUTE:
            //추천
            return PPNConstants.RECOMMEND_ROUTE_OPTION
            
        case PPNConstants.SECOND_ROUTE:
            //최단거리
            return PPNConstants.SHORTEST_ROUTE_OPTION
            
        default:
            print("getSearchOption 추천")
        }
        
        return PPNConstants.RECOMMEND_ROUTE_OPTION
    }
    
    //********************************************************************************************************
    //
    // Admob
    //
    //********************************************************************************************************
    
    
    private func showAd() {
        
        //광고가 표시안됨. simulator라서 그런가??
        
        // In this case, we instantiate the banner with desired ad size.
        let bannerView : GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide ,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        
        
        
        bannerView.adUnitID = "ca-app-pub-7576584379236747/6909922581"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    
    //********************************************************************************************************
    //
    // 경로검색(Alamofire)
    //
    //********************************************************************************************************
    
    
    private func initAlamofireManager() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NavigationViewController.receiveAlamofireGetDirectionNotification(_:)),
                                               name: NSNotification.Name(rawValue: PPNConstants.NOTIFICATION_ALAMOFIRE_FIND_ROUTE),
                                               object: nil)
        
        alamofireManager = AlamofireManager()
    }
    
    @objc func receiveAlamofireGetDirectionNotification(_ notification: NSNotification) {
        if notification.name.rawValue == PPNConstants.NOTIFICATION_ALAMOFIRE_FIND_ROUTE {
            
            SpinnerView.remove()
            
            
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:Any] else { return }
                
                let result : String = userInfo["result"] as! String
                
                switch result {
                case "success" :
                    
                    //마지막으로 첫 번째 옵션의 경로 가져옴
                    if (self.selectedRouteNo == PPNConstants.FIRST_ROUTE) {
                        
                        self.firstDirectionModel = userInfo["directionModel"] as! DirectionModel
                        
                        self.drawRouteOnMap()
                        self.showRouteSelectBoard()
                        
                    }
                    
                    //두 번째 옵션의 경로를 가져옴
                    if (self.selectedRouteNo == PPNConstants.SECOND_ROUTE) {
                       
                        self.secondDirectionModel = userInfo["directionModel"] as! DirectionModel
                        self.selectedRouteNo = PPNConstants.FIRST_ROUTE
                        self.getRoute();
                    }
                    
                 
                    
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
    
    private func getRoute() {
        
        SpinnerView.show(onView: self.view)
        
        let routeOption:String = getRouteOption()
        
        alamofireManager.getDirection(selectedPlaceModel: selectedPlaceModel!, userLocation: userLocation, selectedRouteOption: routeOption, notificationName : PPNConstants.NOTIFICATION_ALAMOFIRE_FIND_ROUTE)
        
        
    }
    
    
  
    func showOverApiAlert() {
        
       OverApiManager.showOverApiAlertPopup(parentViewControler: self)
        
    }
    
    
    //********************************************************************************************************
    //
    // 경로선택 보드
    //
    //********************************************************************************************************
    
    private func initRouteSelectBoardManager() {
        routeSelectBoardManager = RouteSelectBoardManager()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageWidth: CGFloat = scrollView.frame.size.width
        let fractionalPage: CGFloat = scrollView.contentOffset.x / pageWidth
        let page: Int = lround(Double(fractionalPage))
        
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
    
    private func showFirstRoute() {
        
        //pager indicator 표시
        let blueDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#32AAFF", alpha: 1)
        firstDotOnIndicator.backgroundColor = UIColor(patternImage: blueDot)
        
        let grayDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#D9D9D9", alpha: 1)
        secondDotOnIndicator.backgroundColor = UIColor(patternImage: grayDot)
        
        googleMapDrawingManager.showFirstRoute(firstDirectionModel: firstDirectionModel, secondDirectionModel: secondDirectionModel)
        
        
    }
    
    private func showSecondRoute() {
        //pager indicator 표시
        let grayDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#D9D9D9", alpha: 1)
        firstDotOnIndicator.backgroundColor = UIColor(patternImage: grayDot)
        
        let blueDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#32AAFF", alpha: 1)
        secondDotOnIndicator.backgroundColor = UIColor(patternImage: blueDot)
        
        googleMapDrawingManager.showSecondRoute(firstDirectionModel: firstDirectionModel, secondDirectionModel: secondDirectionModel)
    }
    
    
    private func drawStartButtonBackground() {
        
        
        let img = ImageMaker.getRoundRectangle(width: 85, height: 40, colorHexString: "#0078FF", cornerRadius: 6.0, alpha: 1)
        
        startButtonOnMainRoute.backgroundColor = UIColor(patternImage: img)
        
        startButtonOnSubRoute.backgroundColor = UIColor(patternImage: img)
    }
    
    private func addTapGestureToStartButton() {
        let firstStartButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTapStartButtonOnFirstRoute(_:)))
        firstStartButtonTapGesture.numberOfTapsRequired = 1
        firstStartButtonTapGesture.numberOfTouchesRequired = 1
        startButtonOnMainRoute.addGestureRecognizer(firstStartButtonTapGesture)
        startButtonOnMainRoute.isUserInteractionEnabled = true
        
        
        let secondStartButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTapStartButtonOnSecondRoute(_:)))
        secondStartButtonTapGesture.numberOfTapsRequired = 1
        secondStartButtonTapGesture.numberOfTouchesRequired = 1
        startButtonOnSubRoute.addGestureRecognizer(secondStartButtonTapGesture)
        startButtonOnSubRoute.isUserInteractionEnabled = true
    }
    
    
    @objc func onTapStartButtonOnFirstRoute(_ sender: UITapGestureRecognizer) {
        
        let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "Navigation")
        
        (viewController as! NavigationViewController).selectedPlaceModel = selectedPlaceModel
        
        (viewController as! NavigationViewController).selectedRouteOption = PPNConstants.RECOMMEND_ROUTE_OPTION
        
        self.present(viewController!, animated: true, completion: nil)
    }
    
    @objc func onTapStartButtonOnSecondRoute(_ sender: UITapGestureRecognizer) {
        
        let viewController  = self.storyboard?.instantiateViewController(withIdentifier: "Navigation")
        
        (viewController as! NavigationViewController).selectedPlaceModel = selectedPlaceModel
        
        (viewController as! NavigationViewController).selectedRouteOption = PPNConstants.SHORTEST_ROUTE_OPTION
        
        self.present(viewController!, animated: true, completion: nil)
    }
    
    private func showRouteSelectBoard() {
        routeSelectBoard.isHidden = false
        
        showPagerIndicator()
        drawStartButtonBackground()
        addTapGestureToStartButton()
        fillOutRouteSelectBoard()
    }
    
    private func showPagerIndicator() {
        pagerIndicator.isHidden = false
        
        let blueDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#32AAFF", alpha: 1)
        firstDotOnIndicator.backgroundColor = UIColor(patternImage: blueDot)
        
        let grayDot = ImageMaker.getCircle(width: 5, height: 5, colorHexString: "#D9D9D9", alpha: 1)
        secondDotOnIndicator.backgroundColor = UIColor(patternImage: grayDot)
        
    }
    
    private func fillOutRouteSelectBoard() {
        
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
    
    
    //********************************************************************************************************
    //
    // Location
    //
    //********************************************************************************************************
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // TODO: Info.plist 수정하세요
        
        
        userLocation = locations[0] as CLLocation
        
        
        
        if(isFirstLocation) {
            isFirstLocation = false;
            showCurrentLocationOnMap()
            selectedRouteNo = PPNConstants.SECOND_ROUTE
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
        
        googleMapDrawingManager.showFirstCurrentLocationOnMap(userLocation: userLocation! , isNavigationViewController: false)
     
    }
    
    //********************************************************************************************************
    //
    // Google Map
    //
    //********************************************************************************************************
    
    
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
    
    private func drawRouteOnMap() {
        
        googleMapDrawingManager.drawRouteOnMap(firstDirectionModel: firstDirectionModel, secondDirectionModel: secondDirectionModel, isFindRouteViewController: true)
    }
    
    private func initGoogleMapDrawingManager() {
        googleMapDrawingManager = GoogleMapDrawingManager()
        googleMapDrawingManager.setMapView(mapView:mapView)
    }
    
}

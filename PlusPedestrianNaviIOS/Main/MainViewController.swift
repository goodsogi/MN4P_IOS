//
//  ViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 8. 23..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import FloatingPanel

class MainViewController: UIViewController, GMSMapViewDelegate , SelectPlaceDelegate, FloatingPanelControllerDelegate, LocationListenerDelegate {
   
    
    
    
    @IBOutlet var settingButtonContainer: UIView!
    @IBOutlet var findCurrentLocationButtonContainer: UIView!
    
    var selectedPlaceModel:PlaceModel!
      
   
    //Google Map
    @IBOutlet weak var mapView: GMSMapView!
    var googleMapDrawingManager:GoogleMapDrawingManager!
    
    //Location
    var locationManager:LocationManager?
    //var isFirstLocation:Bool = true
    //var userLocation:CLLocation?
    
   
 
    
     
        
    override func viewDidLoad() {
        super.viewDidLoad() 
        initLocationManager()
        makeLayout()
        addTapListenerTest()
        initMapView()
        initGoogleMapDrawingManager()
        showPanelTest()
        initInternetConnectionChecker()
        
        //drawTicketViewBackground()
        
     
    }
    
    private func initLocationManager() {
       LocationManager.sharedInstance.initialize()
       LocationManager.sharedInstance.startUpdatingLocation()
        LocationManager.sharedInstance.setLocationListener(locationListener: self)
    }
    
    
    
    private func initInternetConnectionChecker() {
        InternetConnectionChecker.sharedInstance.run()
    }
        
    private func makeLayout() {
        
        let settingButtonContainerBackgroundImg = ImageMaker.getRoundRectangle(width: 60, height: 60, colorHexString: "#333536", cornerRadius: 10.0, alpha: 1.0)
            
                      settingButtonContainer.backgroundColor = UIColor(patternImage: settingButtonContainerBackgroundImg)
        
        
        let findCurrentLocationButtonContainerBackgroundImg = ImageMaker.getCircle(width: 60, height: 60, colorHexString: "#333536", alpha: 1.0)
                      findCurrentLocationButtonContainer.backgroundColor = UIColor(patternImage: findCurrentLocationButtonContainerBackgroundImg)
        
        
        
    }
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }
    
    
    func showPanelTest() {
       let fpc = FloatingPanelController()
        
        fpc.delegate = self
        
        fpc.surfaceView.backgroundColor = HexColorManager.colorWithHexString(hexString: "#333536", alpha: 1)
        fpc.surfaceView.cornerRadius = 10.0
        
        //TODO 테스트후 삭제하세요
//        guard let mainPanelViewController = self.storyboard?.instantiateViewController(withIdentifier: "search_nearby_bottom_panel") as? SearchNearbyPanelViewController else {
//                   return
//               }
         //TODO 테스트후 주석푸세요
        guard let mainPanelViewController = self.storyboard?.instantiateViewController(withIdentifier: "main_bottom_panel") as? MainPanelViewController else {
            return
        }

        mainPanelViewController.selectPlaceDelegate = self
        
        fpc.set(contentViewController: mainPanelViewController)
       
        
        fpc.addPanel(toParent: self)
        
    }
    
        private func addTapListenerTest() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.settingButtonTapped(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            settingButtonContainer.addGestureRecognizer(tapGesture)
            settingButtonContainer.isUserInteractionEnabled = true
    
        }
    
    @objc func settingButtonTapped(_ sender: UITapGestureRecognizer) {
        showScreenOnOtherStoryboard(storyboardName: "Setting", viewControllerStoryboardId: "setting")
    }
    
   
    
    //안드로이드의 onDestroy와 같음
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(false)
        
        //locationManager.stopUpdatingLocation()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onPlaceSelected(placeModel: PlaceModel, searchType: Int) {
        //TODO searchType 구현하세요 
        
        //Toast는 안뜨는 듯
        //        Toast.show(message: placeModel.getName() ?? "", controller: self)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            
            
            self.selectedPlaceModel = placeModel
            
            self.googleMapDrawingManager.showSelectedPlaceOnMap(selectedPlaceModel: placeModel)   
        })
    }
    
    
   
    
    @objc func telNoViewTapped(_ sender: UITapGestureRecognizer) {
        
        guard let telUrl = URL(string: "tel://" + selectedPlaceModel.getTelNo()!) else { return }
        UIApplication.shared.open(telUrl)
        
    }
    
 
//    private func addTapGestureToFindRouteButton() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.findRouteButtonTapped(_:)))
//        tapGesture.numberOfTapsRequired = 1
//        tapGesture.numberOfTouchesRequired = 1
//        findRouteButton.addGestureRecognizer(tapGesture)
//        findRouteButton.isUserInteractionEnabled = true
//
//    }
    
    @objc func findRouteButtonTapped(_ sender: UITapGestureRecognizer) {
        showScreen(viewControllerStoryboardId: "FindRoute")
    }
     
    //@objc가 없으면 오류 발생
    @objc func showFindRouteScreen(_ sender: UITapGestureRecognizer) {
          
        //왜 작동을 멈추지 않지??
        //locationManager.stopUpdatingLocation()
        
        showScreen(viewControllerStoryboardId: "FindRoute")
    }
        
    private func showScreen(viewControllerStoryboardId:String) {
        let viewController  = self.storyboard?.instantiateViewController(withIdentifier: viewControllerStoryboardId)
      
        
//        if(viewControllerStoryboardId == "FindRoute") {
//
//            (viewController as! RouteInfoViewController).selectedPlaceModel  = selectedPlaceModel
//        }
        
        self.present(viewController!, animated: true, completion: nil)
    }
    
    private func showScreenOnOtherStoryboard(storyboardName:String, viewControllerStoryboardId:String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let mainTopBarViewController = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId)
             
        self.present(mainTopBarViewController, animated: true, completion: nil)
    }
    
    
    
    
    //    //폰의 status bar를 숨기려면 ViewController 마다 아래 코드를 호출해야 함
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
    
    //status bar의 텍스트나 이미지를 흰색으로 지정
    //    override var preferredStatusBarStyle: UIStatusBarStyle {
    //        return .lightContent
    //    }
    
    
    
    
    
   
    
    @objc func showSearchPlaceScreenWithOutCloseDrawer(_ sender: UITapGestureRecognizer) {
        
        showScreen(viewControllerStoryboardId: "SearchPlace")
    }
    
    @objc func emptyViewTapped(_ sender: UITapGestureRecognizer) {
      
    }
    
     
    //    @objc func showFavoritesScreen(_ sender: UITapGestureRecognizer) {
    //        handleDrawer()
    //        showScreen(viewControllerStoryboardId: "Favorites")
    //
    //    }
    
    @objc func showSettingsScreen(_ sender: UITapGestureRecognizer) {
       
        showScreen(viewControllerStoryboardId: "Settings")
        
    }
    
   
   
    
    //********************************************************************************************************
    //
    // Google Map
    //
    //********************************************************************************************************
    
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        NSLog("marker was tapped")
        
        //TODO: 나중에 마커 탭 처리할 때 참조하세요
        
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
        //TODO: 나중에 참조하세요
        //        customInfoWindow?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //TODO: 나중에 참조하세요
        //        let position = tappedMarker?.position
        //        customInfoWindow?.center = mapView.projection.point(for: position!)
        //        customInfoWindow?.center.y -= 140
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
    }
    
    private func initMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 37.534459, longitude: 126.983314, zoom: 14)
        mapView.camera = camera
        
        //이 메소드가 viewDidLoad보다 먼저 호출됨
        
        
    }
    
    
    //********************************************************************************************************
    //
    // Location
    //
    //********************************************************************************************************
    func onLocationCatched(location: CLLocation) {
//          googleMapDrawingManager.showCurrentLocationOnMap(userLocation: location)
       }
       
       func onFirstLocationCatched(location: CLLocation) {
          googleMapDrawingManager.showFirstCurrentLocationOnMap(userLocation: location , isNavigationViewController: false)
        googleMapDrawingManager.showCurrentLocationMarker(userLocation: location)
        
       }
    
    
    private func initGoogleMapDrawingManager() {
        googleMapDrawingManager = GoogleMapDrawingManager()
        googleMapDrawingManager.setMapView(mapView:mapView)
        googleMapDrawingManager.createCurrentLocationMarker()
    }
    
    
    
  
    
    
}

class MyFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .full: return 16.0 // A top inset from safe area
            case .half: return 500 // A bottom inset from the safe area
            case .tip: return 320// A bottom inset from the safe area
            default: return nil // Or `case .hidden: return nil`
        }
    }
}


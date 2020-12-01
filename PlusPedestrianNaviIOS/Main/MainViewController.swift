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

protocol SelectPanelDelegate {
   func showRouteInfoPanel()
}

class MainViewController: UIViewController, GMSMapViewDelegate , SelectPlaceDelegate, FloatingPanelControllerDelegate, LocationListenerDelegate, SelectPanelDelegate {
    
    
    func showRouteInfoPanel() {
       hidePlaceInfoPanel()
       showRouteInfoScreen()
    }
    
   
    @IBOutlet weak var routeInfoPanel: UIView!
    
    var mainPanelFpc: FloatingPanelController!
    var placeInfoPanelFpc: FloatingPanelController!
    
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
    
   
    var panelType: Int = 0
    let MAIN: Int = 0
    let PLACE_INFO: Int = 1
    
    // 경로정보화면
    @IBOutlet var goButton: UIView!
    @IBOutlet var closeButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        initLocationManager()
        makeLayout()
        addTapListenerTest()
        initMapView()
        initGoogleMapDrawingManager()
        showMainPanel()
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
        if (panelType == MAIN) {
            print("plusapps MainPanelLayout")
        return MainPanelLayout()
        } else if (panelType == PLACE_INFO) {
            print("plusapps PlaceInfoPanelLayout")
            return PlaceInfoPanelLayout()
        }
        print("plusapps MainPanelLayout2")
        return MainPanelLayout()
    }
    
    private func hidePlaceInfoPanel() {
        // Inform the panel controller that it will be removed from the hierarchy.
        placeInfoPanelFpc.willMove(toParentViewController: nil)
            
        // Hide the floating panel.
        placeInfoPanelFpc.hide(animated: true) {
            // Remove the floating panel view from your controller's view.
            self.placeInfoPanelFpc.view.removeFromSuperview()
            // Remove the floating panel controller from the controller hierarchy.
            self.placeInfoPanelFpc.removeFromParentViewController()
        }
    }
    
    
    private func hideMainPanel() {
        // Inform the panel controller that it will be removed from the hierarchy.
        mainPanelFpc.willMove(toParentViewController: nil)
            
        // Hide the floating panel.
        mainPanelFpc.hide(animated: true) {
            // Remove the floating panel view from your controller's view.
            self.mainPanelFpc.view.removeFromSuperview()
            // Remove the floating panel controller from the controller hierarchy.
            self.mainPanelFpc.removeFromParentViewController()
        }
    }
    
    private func showPlaceInfoPanel() {
        print("plusapps showPlaceInfoPanel")
        panelType = PLACE_INFO
        
       placeInfoPanelFpc = FloatingPanelController()
        
        placeInfoPanelFpc.delegate = self
        
        placeInfoPanelFpc.surfaceView.backgroundColor = HexColorManager.colorWithHexString(hexString: "#333536", alpha: 1)
        placeInfoPanelFpc.surfaceView.cornerRadius = 10.0
        
        guard let placeInfoPanelViewController = self.storyboard?.instantiateViewController(withIdentifier: "place_info_panel") as? PlaceInfoPanelViewController else {
            return
        }
        
        placeInfoPanelViewController.selectPanelDelegate = self
 
        placeInfoPanelFpc.set(contentViewController: placeInfoPanelViewController)
       
        
        placeInfoPanelFpc.addPanel(toParent: self)
       
        
    }
    
    private func showMainPanel() {
        print("plusapps showMainPanel")
       panelType = MAIN
        
       mainPanelFpc = FloatingPanelController()
        
        mainPanelFpc.delegate = self
        
        mainPanelFpc.surfaceView.backgroundColor = HexColorManager.colorWithHexString(hexString: "#333536", alpha: 1)
        mainPanelFpc.surfaceView.cornerRadius = 10.0
        
       
        guard let mainPanelViewController = self.storyboard?.instantiateViewController(withIdentifier: "main_panel") as? MainPanelViewController else {
            return
        }

        mainPanelViewController.selectPlaceDelegate = self
        
        mainPanelFpc.set(contentViewController: mainPanelViewController)
       
        
        mainPanelFpc.addPanel(toParent: self)
       
        
        
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
        
        
        showPlaceInfoScreen(placeModel: placeModel)
        
    }
    
    private func showPlaceInfoScreen(placeModel: PlaceModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.settingButtonContainer.isHidden = true
            
            self.findCurrentLocationButtonContainer.isHidden = true
                       
            self.hideMainPanel()
           
            self.showPlaceInfoPanel()
                      
            self.selectedPlaceModel = placeModel
            
            self.googleMapDrawingManager.showSelectedPlaceOnMap(selectedPlaceModel: placeModel)
        })
    }
    
    private func showRouteInfoScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.routeInfoPanel.isHidden = false
            let screenWidth = UIScreen.main.bounds.width
            let routeInfoPanelBackgroundImg = ImageMaker.getRoundRectangleByCorners(width: screenWidth, height: 266, colorHexString: "#333536",byRoundingCorners:[UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: 10, alpha: 1.0)
                
            self.routeInfoPanel.backgroundColor = UIColor(patternImage: routeInfoPanelBackgroundImg)
            
            
            let goButtonBackgroundImg = ImageMaker.getRoundRectangle(width:81, height: 81, colorHexString: "#228B22", cornerRadius: 10.0, alpha: 1.0)
            
            self.goButton.backgroundColor = UIColor(patternImage: goButtonBackgroundImg)
            
            let closeButtonBackgroundImg = ImageMaker.getCircle(width: 37, height: 37, colorHexString: "#444447", alpha: 1.0)
            self.closeButton.backgroundColor = UIColor(patternImage: closeButtonBackgroundImg)
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

class MainPanelLayout: FloatingPanelLayout {
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

class PlaceInfoPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .full: return 16.0 // A top inset from safe area
            case .half: return 500 // A bottom inset from the safe area
            case .tip: return 100// A bottom inset from the safe area
            default: return nil // Or `case .hidden: return nil`
        }
    }
}


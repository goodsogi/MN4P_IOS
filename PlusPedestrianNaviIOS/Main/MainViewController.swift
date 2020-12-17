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
import AVFoundation

protocol SelectScreenDelegate {
    func showMainScreen()
    func showRouteInfoScreen()
}

protocol ToastDelegate {
    func showToast(message: String)
}

class MainViewController: UIViewController, GMSMapViewDelegate , SelectPlaceDelegate, FloatingPanelControllerDelegate, LocationListenerDelegate, SelectScreenDelegate, ToastDelegate {
    
    func showToast(message: String) {
        Toast.show(message: message, controller: self)
    }
    
    
    /*
     공통
     */
    //Google Map
    @IBOutlet weak var mapView: GMSMapView!
    var googleMapDrawingManager: GoogleMapDrawingManager!
    
    //TTS 엔진
    var synthesizer : AVSpeechSynthesizer!
    
    var panelType: Int = 0
    var previousScreenType: Int = 0
    
    let NONE: Int = -1
    let MAIN: Int = 0
    let PLACE_INFO: Int = 1
    let NAVIGATION: Int = 2
    let ROUTE_INFO: Int = 3
    
    
    
    //    //폰의 status bar를 숨기려면 ViewController 마다 아래 코드를 호출해야 함
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
    
    //status bar의 텍스트나 이미지를 흰색으로 지정
    //    override var preferredStatusBarStyle: UIStatusBarStyle {
    //        return .lightContent
    //    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previousScreenType = NONE
        
        initTTS()
        
        initLocationManager()
        
        initMapView()
        
        initGoogleMapDrawingManager()
        
        initInternetConnectionChecker()
        
        showMainScreen()
        
        addNotificationObserver()
        
    }
    
    deinit {
        
        removeNotificationObserver()
          
       }

      
    
    //안드로이드의 onDestroy와 같음
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(false)
        
    }
    
    private func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "clickFirebaseDynamicLink"), object: nil)
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationReceived(notification:)), name: Notification.Name(rawValue: "clickFirebaseDynamicLink"), object: nil)
         
    }
    
    @objc func onNotificationReceived(notification: Notification) {
        if let placeModel = notification.object as? PlaceModel {
            if ( previousScreenType != PLACE_INFO) {
            showPlaceInfoScreen(placeModel: placeModel)
            }
        }
    }
    
    private func initLocationManager() {
        LocationManager.sharedInstance.initialize()
        LocationManager.sharedInstance.startUpdatingLocation()
        LocationManager.sharedInstance.setLocationListener(locationListener: self)
    }
    
    private func initGoogleMapDrawingManager() {
        googleMapDrawingManager = GoogleMapDrawingManager()
        googleMapDrawingManager.setMapView(mapView:mapView)
       
    }
    
    private func initInternetConnectionChecker() {
        InternetConnectionChecker.sharedInstance.run()
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
    
    private func hideViewsOnPreviousScreen() {
        
        print("plusapps hideViewsOnPreviousScreen 1")
        if (previousScreenType == NONE) {
            return
        }
        
        print("plusapps hideViewsOnPreviousScreen 2")
        
        if (previousScreenType == MAIN) {
            hideViewsOnMainScreen()
        } else if (previousScreenType == PLACE_INFO) {
            hideViewsOnPlaceInfoScreen()
        } else if (previousScreenType == ROUTE_INFO) {
            hideViewsOnRouteInfoScreen()
        } else if (previousScreenType == NAVIGATION) {
            hideViewsOnNavigationScreen()
        }
    }
    
    /*
     메인 화면
     */
    var mainPanelFpc: FloatingPanelController!
    @IBOutlet var settingButton: UIView!
    @IBOutlet var findCurrentLocationButton: UIView!
    
    private func makeMainScreenLayout() {
        
        let settingButtonContainerBackgroundImg = ImageMaker.getRoundRectangle(width: 60, height: 60, colorHexString: "#333536", cornerRadius: 10.0, alpha: 1.0)
        
        settingButton.backgroundColor = UIColor(patternImage: settingButtonContainerBackgroundImg)
        
        let findCurrentLocationButtonContainerBackgroundImg = ImageMaker.getCircle(width: 60, height: 60, colorHexString: "#333536", alpha: 1.0)
        findCurrentLocationButton.backgroundColor = UIColor(patternImage: findCurrentLocationButtonContainerBackgroundImg)
        
    }
    
    
    
    internal func showMainScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.hideViewsOnPreviousScreen()
            self.showViewsOnMainScreen()
            self.showMainMap()
            self.previousScreenType = self.MAIN
        })
        
    }
    
    private func showMainMap() {
        let userLocation: CLLocation? = LocationManager.sharedInstance.getCurrentLocation()
        if let location = userLocation {
            showCurrentLocation(userLocation: location)
            
        }
        googleMapDrawingManager.setMapPadding(bottomPadding: 240)
        
    }
    
    private func showViewsOnMainScreen() {
        makeMainScreenLayout()
        addTapListenerMain()
        showMainPanel()
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
    
    private func addTapListenerMain() {
        let settingButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onSettingButtonTapped(_:)))
        settingButtonTapGesture.numberOfTapsRequired = 1
        settingButtonTapGesture.numberOfTouchesRequired = 1
        settingButton.addGestureRecognizer(settingButtonTapGesture)
        settingButton.isUserInteractionEnabled = true
        
        let findCurrentLocationButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onFindCurrentLocationButtonTapped(_:)))
        findCurrentLocationButtonTapGesture.numberOfTapsRequired = 1
        findCurrentLocationButtonTapGesture.numberOfTouchesRequired = 1
        findCurrentLocationButton.addGestureRecognizer(findCurrentLocationButtonTapGesture)
        findCurrentLocationButton.isUserInteractionEnabled = true
        
    }
    
    @objc func onFindCurrentLocationButtonTapped(_ sender: UITapGestureRecognizer) {
        //TODO  location permission 체크해야 하나?
      
        let userLocation: CLLocation? = LocationManager.sharedInstance.getCurrentLocation()
        if let location = userLocation {
            showCurrentLocation(userLocation: location)
            
            speakCurrentLocation(userLocation: location)
            
        }   
        
    }
    
    private func showCurrentLocation(userLocation: CLLocation) {
        
        googleMapDrawingManager.moveMapToPosition(userLocation: userLocation , isNavigationViewController: false)
        googleMapDrawingManager.showCurrentLocationMarker(userLocation: userLocation)
        
    }
    
    private func speakCurrentLocation(userLocation: CLLocation) {
        
        AddressManager.getSimpleAddressForCurrentLocation(location: userLocation, completion: {(addressString, error ) in
                                                            
                                                            if let error = error {
                                                                print(error)
                                                                return
                                                            }
                                                            
                                                            if let addressString = addressString {
                                                                self.speakTTS(text: addressString)}})        
     
    }
    
    @objc func onSettingButtonTapped(_ sender: UITapGestureRecognizer) {
        showScreenOnOtherStoryboard(storyboardName: "Setting", viewControllerStoryboardId: "setting")
    }
    
    //    @objc func showFavoritesScreen(_ sender: UITapGestureRecognizer) {
    //        handleDrawer()
    //        showScreen(viewControllerStoryboardId: "Favorites")
    //
    //    }
    
    @objc func showSettingsScreen(_ sender: UITapGestureRecognizer) {
        
        showScreen(viewControllerStoryboardId: "Settings")
        
    }
    
    private func hideViewsOnMainScreen() {
        settingButton.isHidden = true
        findCurrentLocationButton.isHidden = true
        hidePanel(fpc: mainPanelFpc)
    }
    
    /*
     장소정보 화면
     */
    var placeInfoPanelFpc: FloatingPanelController!
    var selectedPlaceModel:PlaceModel!
    
    
    func showPlaceInfoScreen(placeModel: PlaceModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            
            self.hideViewsOnMainScreen()
            
            self.showPlaceInfoPanel(placeModel: placeModel)
            
            self.selectedPlaceModel = placeModel
            
            self.showPlaceInfoMap(placeModel: placeModel)
            
            self.previousScreenType = self.PLACE_INFO
        })
    }
    
    
    private func showPlaceInfoMap(placeModel: PlaceModel) {
        googleMapDrawingManager.showPlaceMarker(selectedPlaceModel: placeModel)
        
    }
    
    private func showPlaceInfoPanel(placeModel: PlaceModel) {
        print("plusapps showPlaceInfoPanel")
        panelType = PLACE_INFO
        
        placeInfoPanelFpc = FloatingPanelController()
        
        placeInfoPanelFpc.delegate = self
        
        placeInfoPanelFpc.surfaceView.backgroundColor = HexColorManager.colorWithHexString(hexString: "#333536", alpha: 1)
        placeInfoPanelFpc.surfaceView.cornerRadius = 10.0
        
        guard let placeInfoPanelViewController = self.storyboard?.instantiateViewController(withIdentifier: "place_info_panel") as? PlaceInfoPanelViewController else {
            return
        }
        placeInfoPanelViewController.toastDelegate = self
        placeInfoPanelViewController.selectScreenDelegate = self
        placeInfoPanelViewController.selectedPlaceModel = placeModel
        
        placeInfoPanelFpc.set(contentViewController: placeInfoPanelViewController)
        
        
        placeInfoPanelFpc.addPanel(toParent: self)
        
        
    }
    
//    @IBAction func onCloseButtonTapped(_ sender: Any) {
//        print("plusapps onCloseButtonTapped")
//        showMainScreen()
//    }
    
    //    @objc func telNoViewTapped(_ sender: UITapGestureRecognizer) {
    //
    //        guard let telUrl = URL(string: "tel://" + selectedPlaceModel.getTelNo()!) else { return }
    //        UIApplication.shared.open(telUrl)
    //
    //    }
    
    private func hideViewsOnPlaceInfoScreen() {
        googleMapDrawingManager.clearPlaceInfoOverlays()
        hidePanel(fpc: placeInfoPanelFpc)
    }
    
    /*
     경로정보 화면
     */
    @IBOutlet var goButton: UIView!
    @IBOutlet var closeButton: UIView!
    @IBOutlet weak var routeInfoPanel: UIView!
    
    @IBOutlet weak var clearWaypointsButton: UIView!
    
    @IBOutlet weak var publicTransportButton: UIView!
  
    @IBOutlet weak var startPointName: UITextField!
    
    @IBOutlet weak var destinationName: UITextField!
    
    @IBOutlet weak var routeOption: UITextField!
    
    @IBOutlet weak var totalDistance: UITextField!
   
    @IBOutlet weak var totalTime: UITextField!
    
    @IBOutlet weak var routeDetail: UITextField!
    
    @IBOutlet weak var calorie: UITextField!
    
    
    @IBAction func onGoButtonClicked(_ sender: Any) {
        showNavigationScreen()
    }
    
    private func showViewsOnRouteInfoScreen() {
        makeRouteInfoScreenLayout()
        addTapListenerRouteInfo()
    }
    
    internal func showRouteInfoScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.setStartPoint()
            self.hideViewsOnPlaceInfoScreen()
            self.showViewsOnRouteInfoScreen()
            self.addTapListenerRouteInfo()
            self.previousScreenType = self.ROUTE_INFO
        })
    }
    
    private func setStartPoint() {
        
        if let location = LocationManager.sharedInstance.getCurrentLocation(), Mn4pSharedDataStore.startPointModel == nil {
            let placeModel: PlaceModel = PlaceModel()
            placeModel.setLatitude(latitude: location.coordinate.latitude)
            
            placeModel.setLongitude(longitude: location.coordinate.longitude)
            
            let name = (UserInfoManager.isLanguageKorean()) ? "나의 위치": "Your location"
            placeModel.setName(name: name)
            placeModel.setAccuracy(accuracy: location.horizontalAccuracy)
            
            Mn4pSharedDataStore.startPointModel = placeModel
        }
        
    }
    
    private func hideViewsOnRouteInfoScreen() {
        clearWaypointsButton.isHidden = true
        publicTransportButton.isHidden = true
        
        routeInfoPanel.isHidden = true
    }
    
    private func makeRouteInfoScreenLayout() {
        let screenWidth = UIScreen.main.bounds.width
        let routeInfoPanelBackgroundImg = ImageMaker.getRoundRectangleByCorners(width: screenWidth, height: 266, colorHexString: "#333536",byRoundingCorners:[UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: 10, alpha: 1.0)
        
        routeInfoPanel.backgroundColor = UIColor(patternImage: routeInfoPanelBackgroundImg)
        
        routeInfoPanel.isHidden = false
        
        let goButtonBackgroundImg = ImageMaker.getRoundRectangle(width:81, height: 81, colorHexString: "#228B22", cornerRadius: 10.0, alpha: 1.0)
        
        goButton.backgroundColor = UIColor(patternImage: goButtonBackgroundImg)
        
        let closeButtonBackgroundImg = ImageMaker.getCircle(width: 37, height: 37, colorHexString: "#444447", alpha: 1.0)
         closeButton.backgroundColor = UIColor(patternImage: closeButtonBackgroundImg)
        
        clearWaypointsButton.isHidden = false
        publicTransportButton.isHidden = false
        //TODO: clearWaypointsButton, publicTransportButton 버튼 리스터 구현하세요
        
        let settingButtonContainerBackgroundImg = ImageMaker.getRoundRectangle(width: 60, height: 60, colorHexString: "#333536", cornerRadius: 10.0, alpha: 1.0)
        
        settingButton.backgroundColor = UIColor(patternImage: settingButtonContainerBackgroundImg)
        
        let clearWaypointsButtonBackgroundImg = ImageMaker.getCircle(width: 60, height: 60, colorHexString: "#333536", alpha: 1.0)
        clearWaypointsButton.backgroundColor = UIColor(patternImage: clearWaypointsButtonBackgroundImg)
        
        let publicTransportButtonBackgroundImg = ImageMaker.getCircle(width: 60, height: 60, colorHexString: "#333536", alpha: 1.0)
        publicTransportButton.backgroundColor = UIColor(patternImage: publicTransportButtonBackgroundImg)
        
         
        
        
        destinationName.text = selectedPlaceModel.getName() ?? "" + "까지"
        startPointName.text = Mn4pSharedDataStore.startPointModel?.getName() ?? ""
        
        //TODO 계속 구현하세요 
        
        
        
        
        
    }
    
    private func addTapListenerRouteInfo() {
        let clearWaypointsButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onClearWaypointsButtonTapped(_:)))
        clearWaypointsButtonTapGesture.numberOfTapsRequired = 1
        clearWaypointsButtonTapGesture.numberOfTouchesRequired = 1
        clearWaypointsButton.addGestureRecognizer(clearWaypointsButtonTapGesture)
        clearWaypointsButton.isUserInteractionEnabled = true
        
        let publicTransportButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onPublicTransportButtonTapped(_:)))
        publicTransportButtonTapGesture.numberOfTapsRequired = 1
        publicTransportButtonTapGesture.numberOfTouchesRequired = 1
        publicTransportButton.addGestureRecognizer(publicTransportButtonTapGesture)
        publicTransportButton.isUserInteractionEnabled = true
        
        
        let closeButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onCloseButtonTapped(_:)))
        closeButtonTapGesture.numberOfTapsRequired = 1
        closeButtonTapGesture.numberOfTouchesRequired = 1
        closeButton.addGestureRecognizer(closeButtonTapGesture)
        closeButton.isUserInteractionEnabled = true
        
        let goButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onGoButtonTapped(_:)))
        goButtonTapGesture.numberOfTapsRequired = 1
        goButtonTapGesture.numberOfTouchesRequired = 1
        goButton.addGestureRecognizer(goButtonTapGesture)
        goButton.isUserInteractionEnabled = true
    }
    
    @objc func onGoButtonTapped(_ sender: UITapGestureRecognizer) {
        showNavigationScreen()
    }
    
    @objc func onClearWaypointsButtonTapped(_ sender: UITapGestureRecognizer) {
        //TODO  구현하세요
      
        
    }
    
    @objc func onPublicTransportButtonTapped(_ sender: UITapGestureRecognizer) {
        //TODO  구현하세요
      
        
    }
    
    //closeButton은 경로정보화면의 객체만 있음
    @objc func onCloseButtonTapped(_ sender: UITapGestureRecognizer) {
        showMainScreen()
    }
    
    /*
     경로안내 화면
     */
    @IBOutlet weak var directionBoard: UIView!
    var navigationPanelFpc: FloatingPanelController!
    
    @IBOutlet weak var stepDetector: UIImageView!
    
    @IBOutlet weak var rescanDirectionButton: UIView!
    
    
    private func showNavigationScreen() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            
            self.hideViewsOnRouteInfoScreen()
            
            self.showViewsOnNavigationScreen()
            
            self.previousScreenType = self.NAVIGATION
        })
        
    }
    
    
    private func showNavigationPanel() {
        print("plusapps showNavigationPanel")
        panelType = NAVIGATION
        
        navigationPanelFpc = FloatingPanelController()
        
        navigationPanelFpc.delegate = self
        
        navigationPanelFpc.surfaceView.backgroundColor = HexColorManager.colorWithHexString(hexString: "#333536", alpha: 1)
        navigationPanelFpc.surfaceView.cornerRadius = 10.0
        
        guard let navigationPanelViewController = self.storyboard?.instantiateViewController(withIdentifier: "navigation_panel") as? NavigationPanelViewController else {
            return
        }
        
        navigationPanelViewController.selectScreenDelegate = self
        
        navigationPanelFpc.set(contentViewController: navigationPanelViewController)
        
        
        navigationPanelFpc.addPanel(toParent: self)
    }
    
    
    
    private func hideViewsOnNavigationScreen() {
        directionBoard.isHidden = true
        rescanDirectionButton.isHidden = true
        stepDetector.isHidden = true
        hidePanel(fpc: navigationPanelFpc)
    }
    
    private func showViewsOnNavigationScreen() {
        directionBoard.isHidden = false
        rescanDirectionButton.isHidden = false
        
        stepDetector.isHidden = false
        
        //TODO: rescanDirectionButton 버튼 리스터 구현하세요
        
        showNavigationPanel()
    }
    
    /*
     Panel
     */
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        if (panelType == MAIN) {
            print("plusapps MainPanelLayout")
            return MainPanelLayout()
        } else if (panelType == PLACE_INFO) {
            print("plusapps PlaceInfoPanelLayout")
            return PlaceInfoPanelLayout()
        } else if (panelType == NAVIGATION) {
            print("plusapps NavigationPanelLayout")
            return NavigationPanelLayout()
        }
        print("plusapps MainPanelLayout2")
        return MainPanelLayout()
    }
    
    private func hidePanel(fpc: FloatingPanelController!) {
        // Inform the panel controller that it will be removed from the hierarchy.
        fpc.willMove(toParentViewController: nil)
        
        // Hide the floating panel.
        fpc.hide(animated: true) {
            // Remove the floating panel view from your controller's view.
            fpc.view.removeFromSuperview()
            // Remove the floating panel controller from the controller hierarchy.
            fpc.removeFromParentViewController()
        }
    }
    
    
    /*
     Google Map
     */
    
    
    
    
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
    
    /*
     Location
     */
    
    
    
    func onLocationCatched(location: CLLocation) {
        
        //          googleMapDrawingManager.showCurrentLocationOnMap(userLocation: location)
    }
    
    func onFirstLocationCatched(location: CLLocation) {
        
        showCurrentLocation(userLocation: location)
        
    }
    
    
    
    /*
     TTS
     */
    
    private func initTTS() {
        synthesizer = AVSpeechSynthesizer()
    }
    private func gainAudioFocus() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //음악 재생용
            //setCategory와 setMode를 정확히 사용해야함
            //setCategory와 setMode를 다른 것으로 지정하면 갱신되는 듯
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setMode(AVAudioSessionModeDefault)
            try audioSession.setActive(true)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    private func loseAudioFocusWithNotify() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //with: .notifyOthersOnDeactivation 파라미터는 setActive를 false로 지정할 때 사용해야 제대로 작동
            try audioSession.setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    private func speakTTS(text: String) {
        gainAudioFocus()
        
        print("plusapps text: " + text)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.4
        
        synthesizer.speak(utterance)
        
        //음악이 재생되고 있는 경우 gainAudioFocus()를 호출한 다음 음성출력하고 loseAudioFocusWithNotify()를 호출해야 음성출력이 끝나면 음악이 다시 재생됨 
        loseAudioFocusWithNotify()
    }
    
}

/*
 FloatingPanelLayout
 */

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
        case .tip: return 250// A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
}

class NavigationPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 500 // A bottom inset from the safe area
        case .tip: return 300// A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
}



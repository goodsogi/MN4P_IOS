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

protocol RouteOptionPopupDelegate {
    func onRouteOptionSelected()
}

protocol ToastDelegate {
    func showToast(message: String)
}

protocol OverviewExitListenerDelegate {
    func onExitFromOverview()
}

protocol GeofenceListenerDelegate {
    func onEntered(currentGeofence: GeofenceModel, nextGeofence: GeofenceModel?)
    func onApproachedByFiftyMeters(description: String, distanceToGeofenceEnter: Int)
    func onApproached(distanceToGeofenceEnter: Int)
    func onOutOfGeofence()
    func onOutOfGeofenceAgain()
    func onExit(previousGeofence: GeofenceModel?, currentGeofence: GeofenceModel)
   }

protocol SegmentedRoutePointListenerDelegate {
    func onGetNearestSegmentedRoutePoint(nearestSegmentedRoutePoint: CLLocation)
}

protocol ArriveDestinationListenerDelegate {
    func onArrivedToDestination()
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}


class MainViewController: UIViewController, GMSMapViewDelegate , SelectPlaceDelegate, FloatingPanelControllerDelegate, LocationListenerDelegate, SelectScreenDelegate, ToastDelegate, RouteOptionPopupDelegate, OverviewExitListenerDelegate, GeofenceListenerDelegate, SegmentedRoutePointListenerDelegate, ArriveDestinationListenerDelegate {
   
    
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
    var screenType: Int = 0
    
    let NONE: Int = -1
    let MAIN: Int = 0
    let PLACE_INFO: Int = 1
    let NAVIGATION: Int = 2
    let ROUTE_INFO: Int = 3
    
    //Alamofire
    var alamofireManager : AlamofireManager!
    
    
    
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
        
        screenType = NONE
        
        initTTS()
        
        initLocationManager()
        
        initMapView()
        
        initGoogleMapDrawingManager()
        
        initInternetConnectionChecker()
        
        showMainScreen()
        
        addNotificationObserver()
        
        initAlamofireManager()
        
    }
    
    deinit {
        
        removeNotificationObserver()
          
       }
    private func initAlamofireManager() {
        
        alamofireManager = AlamofireManager()
    }
      
    
    //안드로이드의 onDestroy와 같음
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(false)
        
    }
    
    private func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "clickFirebaseDynamicLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: PPNConstants.NOTIFICATION_ALAMOFIRE_FIND_ROUTE), object: nil)
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationReceived(notification:)), name: Notification.Name(rawValue: "clickFirebaseDynamicLink"), object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onAlamofireGetDirectionNotificationReceived(_:)),
                                               name: NSNotification.Name(rawValue: PPNConstants.NOTIFICATION_ALAMOFIRE_FIND_ROUTE),
                                               object: nil)
         
    }
    
    @objc func onNotificationReceived(notification: Notification) {
        if let placeModel = notification.object as? PlaceModel {
            if ( screenType != PLACE_INFO) {
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
     
        
        switch (searchType) {
                    case SearchPlaceViewController.PIN_LOCATION:
                        Mn4pSharedDataStore.placeType = SearchPlaceViewController.PIN_LOCATION
                        Mn4pSharedDataStore.placeModel = placeModel
                        showPlaceInfoScreen(placeModel: placeModel)
                        break
                    case SearchPlaceViewController.PLACE:
                        Mn4pSharedDataStore.placeType = SearchPlaceViewController.PLACE
                        Mn4pSharedDataStore.placeModel = placeModel
                        showPlaceInfoScreen(placeModel: placeModel)
                        break
                    case SearchPlaceViewController.START_POINT:
                        Mn4pSharedDataStore.startPointModel = placeModel
                        showPlaceInfoScreen(placeModel: placeModel)
                        break;
                    case SearchPlaceViewController.DESTINATION:
                        Mn4pSharedDataStore.destinationModel = placeModel
                        //TODO 나중에 구현하세요
                        // showSetPointFragment();
                        break
                    case SearchPlaceViewController.HOME:
                        placeModel.setName(name: LanguageManager.getString(key: "home"))
                        UserDefaultManager.saveHomeModel(placeModel: placeModel)
                        Toast.show(message: LanguageManager.getString(key: "home_is_set"), controller: self)
                        showMainScreen()
                        break
                    case SearchPlaceViewController.WORK:
                        placeModel.setName(name: LanguageManager.getString(key: "work"))
                        UserDefaultManager.saveWorkModel(placeModel: placeModel)
                        Toast.show(message: LanguageManager.getString(key: "work_is_set"), controller: self)
                        showMainScreen()
                        break
                    case SearchPlaceViewController.HOME_FROM_SETTING:
                        Toast.show(message: LanguageManager.getString(key: "home_is_set"), controller: self)
                        placeModel.setName(name: LanguageManager.getString(key: "home"))
                        UserDefaultManager.saveHomeModel(placeModel: placeModel)
                        showScreen(viewControllerStoryboardId: "Settings")
                        break
                    case SearchPlaceViewController.WORK_FROM_SETTING:
                        placeModel.setName(name: LanguageManager.getString(key: "work"))
                        UserDefaultManager.saveWorkModel(placeModel: placeModel)
                        Toast.show(message: LanguageManager.getString(key: "work_is_set"), controller: self)
                        showScreen(viewControllerStoryboardId: "Settings")
                        break
                    default:
                        break
                
            }

     
        
        
        
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
        if (screenType == NONE) {
            return
        }
        
        print("plusapps hideViewsOnPreviousScreen 2")
        
        if (screenType == MAIN) {
            hideViewsOnMainScreen()
        } else if (screenType == PLACE_INFO) {
            hideViewsOnPlaceInfoScreen()
        } else if (screenType == ROUTE_INFO) {
            hideViewsOnRouteInfoScreen()
        } else if (screenType == NAVIGATION) {
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
            self.screenType = self.MAIN
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
            
            self.screenType = self.PLACE_INFO
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
    
    var wayPoints : [CLLocationCoordinate2D] = []
    
    
    @IBAction func onGoButtonClicked(_ sender: Any) {
        showNavigationScreen()
    }
    
    func onRouteOptionSelected() {
        findRoute()
    }
    
    private func findRoute() {
        if (InternetConnectionChecker.sharedInstance.isOffline()) {            InternetConnectionChecker.sharedInstance.showOfflineAlertPopup(parentViewControler: self)
            return
        }
        
       //TODO 접근성 구현하세요
        //현재 오류 발생
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            UIAccessibility.post(notification: .announcement, argument: "접근성 웹페이지")
//        }
        
        callGetDirectionApi(notificationName: PPNConstants.NOTIFICATION_ALAMOFIRE_FIND_ROUTE)
        
    }
    
    private func showViewsOnRouteInfoScreen() {
        makeRouteInfoScreenLayout()
        addTapListenerRouteInfo()
    }
    
    internal func showRouteInfoScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.setStartPoint()
            self.setDestinationMdel()
            self.hideViewsOnPlaceInfoScreen()
            self.showViewsOnRouteInfoScreen()
            self.hideClearWaypointsButton()
            self.hidePublicTransportButton()
            self.findRoute()
            self.addTapListenerRouteInfo()
            self.screenType = self.ROUTE_INFO
        })
    }
    
    private func hidePublicTransportButton() {
        publicTransportButton.isHidden = true
    }
    
    private func showPublicTransportButton() {
        publicTransportButton.isHidden = false
    }
    
    private func hideClearWaypointsButton() {
        clearWaypointsButton.isHidden = true
    }
    
    private func showClearWaypointsButton() {
        clearWaypointsButton.isHidden = false
    }
    
    private func setDestinationMdel() {
        Mn4pSharedDataStore.destinationModel = Mn4pSharedDataStore.placeModel
    }
    
    private func onErrorOccurred() {
        print("plusapps onErrorOccurred")
        showMainScreen()
    }
    
    private func showProgressBar() {
        SpinnerView.show(onView: self.view)
    }
    
    private func callGetDirectionApi(notificationName: String) {
      
       
        
        if (Mn4pSharedDataStore.startPointModel == nil || Mn4pSharedDataStore.destinationModel == nil) {
            //토스트가 다른 위치에서는 뜨는데 여기서는 왜 안뜨지?
            Toast.show(message: LanguageManager.getString(key: "error_ocurred_set_destination_again"), controller: self)
            onErrorOccurred()
            return
                }

        showProgressBar()

        let routeOption : String = UserDefaultManager.getRouteOption()

        alamofireManager.getDirection(startPointModel: Mn4pSharedDataStore.startPointModel!, destinationModel: Mn4pSharedDataStore.destinationModel!, selectedRouteOption: routeOption, wayPoints: wayPoints, notificationName : notificationName)
        
    }
    
    
    private func saveDirectionToDB() {
        RealmManager.sharedInstance.addDirectionToDirectionHistory()
    }
    
    private func handleShowPublicTransportButton() {
        let totalDistance: Int = Mn4pSharedDataStore.directionModel!.getTotalDistance() ?? 0
        
        if (totalDistance < 1000) {
            hidePublicTransportButton()
        } else {
            showPublicTransportButton()
        }
    }
        
    
    @objc func onAlamofireGetDirectionNotificationReceived(_ notification: NSNotification) {
        
        print("plusapps onAlamofireGetDirectionNotificationReceived")
        if (notification.name.rawValue == PPNConstants.NOTIFICATION_ALAMOFIRE_FIND_ROUTE ||  notification.name.rawValue == PPNConstants.NOTIFICATION_ALAMOFIRE_GET_DIRECTION) {
            
            SpinnerView.remove()
            
            
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:Any] else { return }
                
                let result : String? = userInfo["result"] as? String
                
                switch result {
                case "success" :
                    
                    Mn4pSharedDataStore.directionModel =  userInfo["directionModel"] as? DirectionModel
                    
                    if (notification.name.rawValue == PPNConstants.NOTIFICATION_ALAMOFIRE_FIND_ROUTE) {
                    saveDirectionToDB()
                    //TODO 계속 구현하세요 
                    showRouteOnMap()
                    handleShowPublicTransportButton()
                    fillOutInfo()
                    }  else if (notification.name.rawValue == PPNConstants.NOTIFICATION_ALAMOFIRE_GET_DIRECTION) {
                        googleMapDrawingManager.showNavigationOverlays(directionModel: Mn4pSharedDataStore.directionModel!)
                        
                        //TODO step detector 구현하세요
                        
                        NavigationEngine.sharedInstance.initEngine()
                        speakHourDirectionAtStartOfRescan()
                        NavigationEngine.sharedInstance.restart()
                        
                    }
                    
                    break;
                case "overApi" :
                    
                    showOverApiAlert()
                    
                    break;
                    
                case "fail" :
                    //TODO: 오류처리 구현하세요
                    
                    break;
                default:
                    
                    break;
                }
                
            }
        }
    }
    
   
    
    
    private func showRouteOnMap() {
        
        googleMapDrawingManager.showRouteOverlays(directionModel: Mn4pSharedDataStore.directionModel!)
        
    }
    
  
    func showOverApiAlert() {
        
       OverApiManager.showOverApiAlertPopup(parentViewControler: self)
        
    }
    
    private func setStartPoint() {
        
        if let location = LocationManager.sharedInstance.getCurrentLocation(), Mn4pSharedDataStore.startPointModel == nil {
            let placeModel: PlaceModel = PlaceModel()
            placeModel.setLatitude(latitude: location.coordinate.latitude)
            
            placeModel.setLongitude(longitude: location.coordinate.longitude)
            
            print("plusapps isLanguageKorean: " + String(UserInfoManager.isLanguageKorean()))
            
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
    
    private func fillOutInfo() {
        showDestinationName()
               showStartPointName()
               showRouteOption()
               showTotalDistance()
               showTotalTime()
               showRouteDetail()
               showCalorie()
    }
    
    private func showDestinationName() {
        destinationName.text = selectedPlaceModel.getName()! + "까지"
    }
    
    private func showStartPointName() {
        startPointName.text = Mn4pSharedDataStore.startPointModel?.getName() ?? ""
        
    }
    
    private func showRouteOption() {
        routeOption.text = getRouteOption()
    }
    
    private func showTotalDistance() {
        var distanceString: String = DistanceStringFormatter.getFormattedDistanceWithUnit(distance: Mn4pSharedDataStore.directionModel!.getTotalDistance() ?? 0)
                if (distanceString == "0m") {
                    distanceString = ""
                }
        
        totalDistance.text = distanceString
    }
    
    private func showTotalTime() {
        let totalTimeString: String = getTotalTime()
        //bullet point까지 공백생기는 이유는 폰트 사이즈가 커서 그런 듯. 어떻게 할 수 없는 듯 
        totalTime.text = totalTimeString
    }
    
    private func getTotalTime() -> String {
        return getFormattedTime(time: Mn4pSharedDataStore.directionModel!.getTotalTime() ?? 0)
    }
    
    private func getFormattedTime(time: Int) -> String {
        var resultTime: Int = 0
        if (time < 0) {
            resultTime = 0
        } else {
            resultTime = time
        }
        
       
        let min: Int = resultTime % 3600 / 60
        let hour: Int = resultTime / 3600
        
        var resultString: String = ""
        
               if (hour > 0) {
                //Int를 String으로 변환할 때 String(format:"%f", value)를 사용하면 안됨
                resultString.append(String(hour))
                
                resultString.append(LanguageManager.getString(key: "hour") + " ")
                }

                if (min > 0) {
                     resultString.append(String(min))
                    resultString.append(LanguageManager.getString(key: "min") + " ")
                }

                if (hour == 0 && min == 0) {
                     resultString.append(String(resultTime))
                    resultString.append(LanguageManager.getString(key: "sec") + " ")
                }
        
         
               return resultString
    }
    
    private func showRouteDetail() {
        let routeDetailString: String = getRouteDetail()
        routeDetail.text = routeDetailString
    }
    
    private func getRouteDetail() -> String {
        //TODO 외국의 경로안내할 경우 지하도와 횡단보도 갯수가 틀릴 수 있으니 수정하세요
        if (UserInfoManager.isLanguageKorean()) {
                   return getKoreanRouteDetail()
               } else {
                   return getEnglishRouteDetail()
               }
    }
    
    private func getKoreanRouteDetail() -> String {
        let undergroundCount: Int = getUndergroundCount()
        let crosswalkCount: Int = getCrosswalkCount()

        var resultString: String = ""

               if (undergroundCount > 0) {
                resultString.append("지하도 ")
                resultString.append(String(undergroundCount))
                resultString.append("회")
               }

               if (undergroundCount > 0 && crosswalkCount > 0) {
                resultString.append("+")
               }

               if (crosswalkCount > 0) {
                resultString.append("횡단보도 ")
                resultString.append(String(crosswalkCount))
                resultString.append("회")
             
               }

               return resultString
    }
    
    private func getUndergroundCount() -> Int {
      
        var undergroundCount: Int = 0
        for geofenceModel in Mn4pSharedDataStore.directionModel!.getGeofenceModels()! {
            if let description = geofenceModel.getDescription(), description.contains("지하") {
                undergroundCount = undergroundCount + 1
            }
        }
                       return undergroundCount;
    }
    
    private func getCrosswalkCount() -> Int {
        
        var crosswalkCount: Int = 0
        for geofenceModel in Mn4pSharedDataStore.directionModel!.getGeofenceModels()! {
            if let description = geofenceModel.getDescription(), description.contains("횡단") {
                crosswalkCount = crosswalkCount + 1
            }
        }
                       return crosswalkCount
     
    }
    
    private func getEnglishRouteDetail() -> String {
        let undergroundCount: Int = getUndergroundCount()
        let crosswalkCount: Int = getCrosswalkCount()

        var resultString: String = ""

               if (undergroundCount > 0) {
                resultString.append("Underpass ")
                resultString.append(String(undergroundCount))
               }

               if (undergroundCount > 0 && crosswalkCount > 0) {
                resultString.append("+")
               }

               if (crosswalkCount > 0) {
                resultString.append("Crosswalk ")
                resultString.append(String(crosswalkCount))
             
               }

               return resultString
    }
    
    private func showCalorie() {
        
        let calorieString: String = getCalorie() + LanguageManager.getString(key: "kcal")
        calorie.text = calorieString
        
        
    }
    
    private func getCalorie() -> String {
        let hour: Int = Mn4pSharedDataStore.directionModel!.getTotalTime()! / 3600
        let min: Int =  (Mn4pSharedDataStore.directionModel!.getTotalTime()! % 3600) / 60
        
        let totalMin = hour * 60 + min
        
        let result1: Double = 3.5 * 70 * Double(totalMin)
        let result2: Double = ((3.3 * result1) / 1000) * 5

        
        var totalCalorie: Int = Int(result2)
        
        if (totalCalorie == 0) {
            totalCalorie = 1
        }
        
        return totalCalorie.formattedWithSeparator
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
              
        
        
    }
    
    private func getRouteOption() -> String {
        
        let routeOption : String = UserDefaultManager.getRouteOption()
        return getRouteOptionName(routeOption: routeOption)
    }
    
    private func getRouteOptionName(routeOption: String) -> String  {
        switch routeOption {
        case "0":
            return LanguageManager.getString(key: "recommended")
        case "4":
            return LanguageManager.getString(key: "main_street")
        case "10":
            return LanguageManager.getString(key: "min_distance")
        case "30":
            return LanguageManager.getString(key: "no_stairs")
        default:
            return LanguageManager.getString(key: "recommended")
        }
        
    }
    
    private func showRouteOptionPopup() {
        
        let storyboard = UIStoryboard(name: "AlertPopup", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "RouteOptionPopup")
         
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        (modalViewController as! RouteOptionPopupViewController).routeOptionPopupDelegate  = self
         
        self.present(modalViewController, animated: true, completion: nil)
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
        
        let routeOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onRouteOptionTapped(_:)))
        routeOptionTapGesture.numberOfTapsRequired = 1
        routeOptionTapGesture.numberOfTouchesRequired = 1
        routeOption.addGestureRecognizer(routeOptionTapGesture)
        routeOption.isUserInteractionEnabled = true
        
        let startPointNameTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onStartPointNameTapped(_:)))
        startPointNameTapGesture.numberOfTapsRequired = 1
        startPointNameTapGesture.numberOfTouchesRequired = 1
        startPointName.addGestureRecognizer(startPointNameTapGesture)
        startPointName.isUserInteractionEnabled = true
    }
    
    private func showSetPointScreen() {
        showScreenOnOtherStoryboard(storyboardName: "SetPoint", viewControllerStoryboardId: "set_point")
    }
        
        
    @objc func onStartPointNameTapped(_ sender: UITapGestureRecognizer) {
        showSetPointScreen()
    }
    
    @objc func onRouteOptionTapped(_ sender: UITapGestureRecognizer) {
        showRouteOptionPopup()
    }
    
    @objc func onGoButtonTapped(_ sender: UITapGestureRecognizer) {
        showNavigationScreen()
    }
    
    @objc func onClearWaypointsButtonTapped(_ sender: UITapGestureRecognizer) {
        hideClearWaypointsButton()
        wayPoints.removeAll()
        findRoute()
        
    }
    
    @objc func onPublicTransportButtonTapped(_ sender: UITapGestureRecognizer) {
        
        var url:String = ""
        
        if (UserInfoManager.isUserInKorea()) {
              
            //카카오맵이 설치되어 있는 경우에만 열림
            //카카오맵 웹페이지를 열려고 하니 웹페이지를 열지만 경로를 표시하지는 않음
            url.append("kakaomap://route?sp=")
            url.append(String(format: "%f", Mn4pSharedDataStore.startPointModel!.getLatitude() ?? 0))
            url.append(",")
            url.append(String(format: "%f", Mn4pSharedDataStore.startPointModel!.getLongitude() ?? 0))
            url.append("&ep=")
            url.append(String(format: "%f", Mn4pSharedDataStore.destinationModel!.getLatitude() ?? 0))
            url.append(",")
            url.append(String(format: "%f", Mn4pSharedDataStore.destinationModel!.getLongitude() ?? 0))
            url.append("&by=PUBLICTRANSIT")
            
            print("plusapps url: " + url)
            //canOpenUrl이 항상 false 리턴
            //카카오맵의 url scheme(kakaomap)을 info.plist파일의 LSApplicatinQueriesSchemes에 추가하면 canOpenUrl이 정상적인 값 리턴
            if (UIApplication.shared.canOpenURL(URL(string:url)!) != true) {
                if let url = URL(string: "itms-apps://apple.com/app/id304608425") {
                    UIApplication.shared.open(url)
                }
                return
            }

        } else {
            //구글맵은 앱이 설치되었으면 앱으로 설치 안되었으면 웹으로 이동
            url.append("http://www.google.com/maps/dir/?api=1&f=d&origin=")
            url.append(String(format: "%f", Mn4pSharedDataStore.startPointModel!.getLatitude() ?? 0))
            url.append(",")
            url.append(String(format: "%f", Mn4pSharedDataStore.startPointModel!.getLongitude() ?? 0))
            url.append("&destination=")
            url.append(String(format: "%f", Mn4pSharedDataStore.destinationModel!.getLatitude() ?? 0))
            url.append(",")
            url.append(String(format: "%f", Mn4pSharedDataStore.destinationModel!.getLongitude() ?? 0))
            url.append("&travelmode=transit")
         }
        
        UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
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
    
    
    @IBOutlet weak var directionIcon: UIImageView!
    
    @IBOutlet weak var directionText: UITextView!
    
    private var navigationPanelVieweController: NavigationPanelViewController?
    
    func onExitFromOverview() {
        //TODO 구현하세요 
    }
    
    func onEntered(currentGeofence: GeofenceModel, nextGeofence: GeofenceModel?) {
        
        let currentGeofenceLocation = CLLocation(latitude: currentGeofence.getLat() ?? 0, longitude: currentGeofence.getLng() ?? 0)
        let nextGeofenceLocation = CLLocation(latitude: nextGeofence?.getLat() ?? 0, longitude: nextGeofence?.getLng() ?? 0)
       
        googleMapDrawingManager.updateMapBearingAndZoom(currentGeofenceLocation: currentGeofenceLocation ,nextGeofenceLocation: nextGeofenceLocation )
        
        googleMapDrawingManager.showGeofenceMarker(geofenceModel: currentGeofence)
        showDirectionTextAndIcon(text: currentGeofence.getDescription() ?? "")
        runVibration(text: currentGeofence.getDescription() ?? "" )
        speakTTS(text: currentGeofence.getDescription() ?? "")
    }
    
    func onApproachedByFiftyMeters(description: String, distanceToGeofenceEnter: Int) {
        let message: String = LanguageManager.getGeofenceApproachMessage(distanceToGeofenceEnter: String(distanceToGeofenceEnter))
        showDirectionTextAndIcon(text: message);

                        if (UserDefaultManager.isUseDistanceVoice()) {
                            speakTTS(text: message)
                        }
    }
    
    func onApproached(distanceToGeofenceEnter: Int) {
        let message: String = LanguageManager.getGeofenceApproachMessage(distanceToGeofenceEnter: String(distanceToGeofenceEnter))
        showDirectionTextAndIcon(text: message);
    }
    
    func onOutOfGeofence() {
        speakTTS(text: LanguageManager.getString(key: "out_of_route_search_route_again"))
        showDirectionTextAndIcon(text: "")
        getDirection()
    }
    
    func onOutOfGeofenceAgain() {
        NavigationEngine.sharedInstance.pauseEngine()
        speakTTS(text: LanguageManager.getString(key: "out_of_route_again_go_back"))
        showDirectionTextAndIcon(text: "")
        getDirection()
    }
    
    func onExit(previousGeofence: GeofenceModel?, currentGeofence: GeofenceModel) {
        
        if (previousGeofence == nil) {
            return
        }
        
        let currentGeofenceLocation = CLLocation(latitude: previousGeofence?.getLat() ?? 0, longitude: previousGeofence?.getLng() ?? 0)
        let nextGeofenceLocation = CLLocation(latitude: currentGeofence.getLat() ?? 0, longitude: currentGeofence.getLng() ?? 0)
       
        googleMapDrawingManager.updateMapBearingAndZoom(currentGeofenceLocation: currentGeofenceLocation ,nextGeofenceLocation: nextGeofenceLocation )
    }
    
    func onGetNearestSegmentedRoutePoint(nearestSegmentedRoutePoint: CLLocation) {
        //TODO background location service 처리하세요
        refreshNavigationInfo()
        googleMapDrawingManager.showNavigationMarker(nearestSegmentedRoutePoint: nearestSegmentedRoutePoint)
        var progress: Double = NavigationEngine.sharedInstance.getProgress()
        
        //TODO 아래 코드 구현하세요.
        //현재 google map에서 progress는 구현 불가능함
        //googleMapDrawingManager.showProgress(progress: progress)
    }
    
    
    
    func onArrivedToDestination() {
        speakTTS(text: LanguageManager.getString(key: "you_have_arrived"))
        runVibration(text: LanguageManager.getString(key: "you_have_arrived"))
       
        showDirectionTextAndIcon(text: LanguageManager.getString(key: "you_have_arrived"))
        
        //TODO Firebase Analytics 추가해야 하나?
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: {
            
            self.finishNavigation()
            
      
        })
        
    }
    
    private func refreshNavigationInfo() {
        let remainingDistance: Int = NavigationEngine.sharedInstance.getRemainingDistance()
        showRemainingDistance(distance: remainingDistance)

        var remainingMinInt: Int = remainingDistance / 60

            //거리가 몇 미터 남았는데 남은 시간이 0으로 표시되는 이슈 수정
            if (remainingDistance > 0 && remainingMinInt == 0) {
                remainingMinInt = 1
            }

        showRemainingTime(time: remainingMinInt);
        showArrivalTime(time: remainingMinInt);
        }
    
    private func showArrivalTime(time: Int) {
        
        let startDate = Date()
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .minute, value: time, to: startDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let arrivalTimeIn24Format = dateFormatter.string(from: date!)
        
        let contentDescription: String = LanguageManager.getString(key: "expected_arrival_time") + arrivalTimeIn24Format
        
        
        navigationPanelVieweController?.showArrivalTime(arrivalTimeString: arrivalTimeIn24Format, contentDescription: contentDescription)
        
         }
    
    private func showRemainingTime(time: Int) {
        
        var timeUnitForContentDescription: String = ""
        if (time > 1) {
            timeUnitForContentDescription =  LanguageManager.getString(key: "minutes")
        } else {
            timeUnitForContentDescription = LanguageManager.getString(key: "minute")
        }
        
        let contentDescription: String = LanguageManager.getString(key: "remaining_time") + String(time)
            + timeUnitForContentDescription
        
        navigationPanelVieweController?.showRemainingTime(remainingTimeString: String(time), contentDescription: contentDescription)
        
             }

    
    private func showRemainingDistance(distance: Int) {
        let formattedRemainingDistance: String = DistanceStringFormatter.getFormattedDistance(distance: distance)
        let distanceUnit: String = DistanceStringFormatter.getDistanceUnit(distance: distance)

        var distanceUnitForContentDescription: String = ""
        if (distanceUnit == "km") {
            if (distance > 1) {
                distanceUnitForContentDescription = LanguageManager.getString(key: "kilometers")
            } else {
                distanceUnitForContentDescription = LanguageManager.getString(key: "kilometer")
            }
        } else {
            if (distance > 1) {
                distanceUnitForContentDescription = LanguageManager.getString(key: "meters_full_name")
            } else {
                distanceUnitForContentDescription = LanguageManager.getString(key: "meter_full_name")
            }
        }
        
        let contentDescription: String = LanguageManager.getString(key: "remaining_distance") + formattedRemainingDistance
            + distanceUnitForContentDescription
        
        
        navigationPanelVieweController?.showRemainingDistance(formattedRemainingDistance: formattedRemainingDistance, distanceUnit: distanceUnit, contentDescription: contentDescription)
        
       
       }
    
    
    private func speakHourDirectionAtStartOfRescan() {
        
        let currentLocation: CLLocation? = LocationManager.sharedInstance.getCurrentLocation()
        let bearingValue: Double = NavigationEngine.sharedInstance.getBearingValueForStartMessage(currentLocation: currentLocation)
        
        //TODO compass 구현하세요
        //final float angleValue = NewCompassManager.getInstance(activity).getAngleValue();
        let message: String = LanguageManager.getNavigationStartMessageForRescan(bearingValue: bearingValue, angleValue: 0)
        speakTTS(text: message)
        
    }
    
    
    private func getDirection() {
        if (InternetConnectionChecker.sharedInstance.isOffline()) {            InternetConnectionChecker.sharedInstance.showOfflineAlertPopup(parentViewControler: self)
            return
        }
        
       //TODO 접근성 구현하세요
        //현재 오류 발생
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            UIAccessibility.post(notification: .announcement, argument: "접근성 웹페이지")
//        }
        
        
        resetCurrentLocationOnStartPoint()
        
        callGetDirectionApi(notificationName: PPNConstants.NOTIFICATION_ALAMOFIRE_GET_DIRECTION)
    }
    
    private func resetCurrentLocationOnStartPoint() {
        setStartPoint()
    }
    
    private func runVibration(text: String) {
        VibrationManager.sharedInstance.runVibration(text: text)
    }
    
    private func finishNavigation() {
        stopTTS()
        NavigationEngine.sharedInstance.stop()
        handleNavitionFinished()
        
    }
    
    private func handleNavitionFinished() {
        showMainScreen()
    }
    
    private func stopTTS() {
        //TODO 정상적으로 작동하는지 확인하세요
        
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    
    private func showDirectionTextAndIcon(text: String) {
        //TODO background location service 처리하세요
        
        directionText.text = text
        
        directionIcon.image = getDirectionIcon(text: text)
        
        
        
    }
    
    private func getDirectionIcon(text: String) -> UIImage? {
        
        if (text.isEmpty) {
            return nil
        }
        
        if (text == LanguageManager.getString(key: "you_have_arrived")) {
            return nil
        }
        
        
        if (text.contains(LanguageManager.getString(key:"turn_left"))) {
            return UIImage(named: "turn_left_big_white")
        } else if (text.contains(LanguageManager.getString(key: "turn_left"))) {
            return UIImage(named: "turn_right_big_white")
        } else {
            return UIImage(named: "go_straight_big_white")
        }
        
    }
    
    
    
    private func showNavigationScreen() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            
            self.hideViewsOnRouteInfoScreen()
            
            self.showViewsOnNavigationScreen()
            self.initNavigationEngine()
                      
            self.screenType = self.NAVIGATION
        })
        
    }
    
    
    private func showNavigationPanel() {
        print("plusapps showNavigationPanel")
        panelType = NAVIGATION
        
        navigationPanelFpc = FloatingPanelController()
        
        navigationPanelFpc.delegate = self
        
        navigationPanelFpc.surfaceView.backgroundColor = HexColorManager.colorWithHexString(hexString: "#333536", alpha: 1)
        navigationPanelFpc.surfaceView.cornerRadius = 10.0
        
        navigationPanelVieweController = self.storyboard?.instantiateViewController(withIdentifier: "navigation_panel") as? NavigationPanelViewController
        
        if (navigationPanelVieweController == nil) {
            return
        }
        
        navigationPanelVieweController?.selectScreenDelegate = self
        
        navigationPanelFpc.set(contentViewController: navigationPanelVieweController)
        
        
        navigationPanelFpc.addPanel(toParent: self)
    }
    
    
    
    private func hideViewsOnNavigationScreen() {
        directionBoard.isHidden = true
        rescanDirectionButton.isHidden = true
        stepDetector.isHidden = true
        hidePanel(fpc: navigationPanelFpc)
    }
    
    private func showViewsOnNavigationScreen() {
        
        makeNavigationScreenLayout()
        addTapListenerNavigation()
        initNavigationMap()
        //TODO: rescanDirectionButton 버튼 리스터 구현하세요
        
        showNavigationPanel()
    }
    
    private func initNavigationEngine() {
        NavigationEngine.sharedInstance.initEngine()
    }
    
    
    private func initNavigationMap() {
        
        googleMapDrawingManager.showNavigationOverlays(directionModel: Mn4pSharedDataStore.directionModel!)
        googleMapDrawingManager.setMapPadding(bottomPadding: 0)
    }
    
    private func makeNavigationScreenLayout() {
        directionBoard.isHidden = false
        rescanDirectionButton.isHidden = false
        
        stepDetector.isHidden = false
        
        let rescanDirectionButtonBackgroundImg = ImageMaker.getCircle(width: 60, height: 60, colorHexString: "#333536", alpha: 1.0)
        rescanDirectionButton.backgroundColor = UIColor(patternImage: rescanDirectionButtonBackgroundImg)
       
        //TODO step detector 배경이미지 처리하세요
    }
    
    
    private func addTapListenerNavigation() {
        
        let rescanDirectionButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onRescanDirectionButtonTapped(_:)))
        rescanDirectionButtonTapGesture.numberOfTapsRequired = 1
        rescanDirectionButtonTapGesture.numberOfTouchesRequired = 1
        rescanDirectionButton.addGestureRecognizer(rescanDirectionButtonTapGesture)
        rescanDirectionButton.isUserInteractionEnabled = true
    }
  
    @objc func onRescanDirectionButtonTapped(_ sender: UITapGestureRecognizer) {
        rescanDirection()
    }
    
    private func rescanDirection() {
        //TODO 구현하세요
        
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
        print("plusapps mapView didTapAt")
        if (screenType == ROUTE_INFO) {
            let wayPoint : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
         
            wayPoints.append(wayPoint)
            showClearWaypointsButton()
            findRoute()
            
        }
        
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
        mapView.delegate = self
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
        case .tip: return 180// A bottom inset from the safe area
        default: return nil // Or `case .hidden: return nil`
        }
    }
}



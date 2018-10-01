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
import Floaty


protocol MainViewControllerDelegate {
    func onPlaceSelected(placeModel: SearchPlaceModel)
}


class MainViewController: UIViewController, GMSMapViewDelegate , CLLocationManagerDelegate, MainViewControllerDelegate, FloatyDelegate{
    
    
    @IBOutlet weak var writeAppReviewMenu: UIView!
    @IBOutlet weak var settingsMenu: UIView!
    @IBOutlet weak var favoritesMenu: UIView!
    @IBOutlet weak var searchMenu: UIView!
    @IBOutlet weak var findRouteMenu: UIView!
    @IBOutlet weak var mainScreen: UIView!
    
    @IBOutlet weak var drawerView: UIStackView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var drawerViewTrailing: NSLayoutConstraint!
    var hamburgerMenuIsVisible = false
    
//    @IBOutlet weak var ticketView: UITextView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var topSearchBar: UIView!
    @IBOutlet weak var topSearchBarLabel: UILabel!
    
    
    @IBOutlet weak var placeNameView: UILabel!
    @IBOutlet weak var bizNameView: UILabel!
    @IBOutlet weak var addressView: UILabel!
    @IBOutlet weak var telNoView: UILabel!
    
    @IBOutlet weak var placeInfoBoard: UIView!    
    @IBOutlet weak var findRouteButton: UIView!
    
    var selectedPlaceModel:SearchPlaceModel!
    
    var isFirstLocation:Bool = true
    var googleMapDrawingManager:GoogleMapDrawingManager!
    
    var floaty:Floaty = Floaty()
    
    @IBAction func hamburgerButtonTapped(_ sender: Any) {
        //if the hamburger menu is NOT visible, then move the ubeView back to where it used to be
        
        handleDrawer()
        
        
    }
    
    func onPlaceSelected(placeModel: SearchPlaceModel) {
        
        
        //Toast는 안뜨는 듯
        //        Toast.show(message: placeModel.getName() ?? "", controller: self)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            
            
            self.selectedPlaceModel = placeModel
            
            self.googleMapDrawingManager.showSelectedPlaceOnMap(selectedPlaceModel: placeModel)
            
            self.moveFloaty()
            self.showSelectedPlaceOnBoard()
            self.drawFindRouteButtonBackground()
            self.addTapGestureToFindRouteButton()
            self.addTapGestureToTelNoView(telNo: placeModel.getTelNo() ?? "")
        })
    }
    
    func moveFloaty() {
//        floaty.paddingX = 40
        floaty.paddingY = floaty.frame.height + 20
        
    
    }
    
    func addTapGestureToTelNoView(telNo:String) {
        
        guard !(selectedPlaceModel?.getTelNo()?.isEmpty)! else {
            print("No tel no")
            return
        }
        
        //#selector는 parameter를 못넘기는 듯
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.telNoViewTapped(_: )))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        telNoView.addGestureRecognizer(tapGesture)
        telNoView.isUserInteractionEnabled = true
        
    }
    
    
    @objc func telNoViewTapped(_ sender: UITapGestureRecognizer) {
        
        guard let telUrl = URL(string: "tel://" + selectedPlaceModel.getTelNo()!) else { return }
        UIApplication.shared.open(telUrl)
        
    }
    
    func drawFindRouteButtonBackground() {
        
        
        let img = ImageMaker.getRoundRectangle(width: 100, height: 40, colorHexString: "#0078FF", cornerRadius: 6.0, alpha: 1)
        
        
        findRouteButton.backgroundColor = UIColor(patternImage: img)
    }
    
    func addTapGestureToFindRouteButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.findRouteButtonTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        findRouteButton.addGestureRecognizer(tapGesture)
        findRouteButton.isUserInteractionEnabled = true
        
        
    }
    
    @objc func findRouteButtonTapped(_ sender: UITapGestureRecognizer) {
        
        showScreen(viewControllerStoryboardId: "FindRoute")
    }
    
    
    
    
    func showSelectedPlaceOnBoard() {
        
        placeInfoBoard.isHidden = false
        
        ViewElevationMaker.run(view:placeInfoBoard)
        
        
        
        placeNameView.text = selectedPlaceModel.getName()
        addressView.text = selectedPlaceModel.getAddress()
        bizNameView.text = selectedPlaceModel.getBizName()
        telNoView.text = selectedPlaceModel.getTelNo()
        
        
    }
    
    
    func handleDrawer() {
        if !hamburgerMenuIsVisible {
            
            drawerViewTrailing.constant = self.view.frame.size.width;
            
            hamburgerMenuIsVisible = true
        } else {
            
            drawerViewTrailing.constant = 0
            
            hamburgerMenuIsVisible = false
        }
        
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            //self.view를 사용해야 애니메이션이 작동함. self.drawer는 작동하지 않음
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        initMapView()
        initFloaty()
        initTopSearchBar()
        initGoogleMapDrawingManager()
        addTapGestureToDrawer()
        addTapGestureToDrawerMenu()
//        drawTicketViewBackground()
        
    }
    
    func initFloaty() {
        
        floaty.buttonColor = UIColor.white
        floaty.hasShadow = true
       
        
        floaty.addItem(icon: UIImage(named: "current_location_big")) { item in
           
            
        }
       
        //기본적으로 오른쪽 하단에 위치, 아래는 padding 값을 주는 것임
//        floaty.paddingX = 40
//        floaty.paddingY = floaty.frame.height + 20
        
       
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
    
    func initGoogleMapDrawingManager() {
        googleMapDrawingManager = GoogleMapDrawingManager()
        googleMapDrawingManager.setMapView(mapView:mapView)
        googleMapDrawingManager.createCurrentLocationMarker()
    }
    
//    func drawTicketViewBackground() {
//
//        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 30))
//        let img = renderer.image { ctx in
//            ctx.cgContext.setFillColor(HexColorManager.colorWithHexString(hexString: "#000000", alpha: 0).cgColor)
//            ctx.cgContext.setStrokeColor(HexColorManager.colorWithHexString(hexString: "#0078FF", alpha: 1.0).cgColor)
//            ctx.cgContext.setLineWidth(10)
//
//            let rectangle = CGRect(x: 0, y: 0, width: 50, height: 30)
//            ctx.cgContext.addRect(rectangle)
//            ctx.cgContext.drawPath(using: .fillStroke)
//        }
//
//
//        ticketView.backgroundColor = UIColor(patternImage: img)
//    }
    
    
    func addTapGestureToDrawer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.emptyViewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        emptyView.addGestureRecognizer(tapGesture)
        emptyView.isUserInteractionEnabled = true
        
        
    }
    
    func addTapGestureToDrawerMenu() {
        
        let searchMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showSearchPlaceScreen(_:)))
        searchMenuTapGesture.numberOfTapsRequired = 1
        searchMenuTapGesture.numberOfTouchesRequired = 1
        searchMenu.addGestureRecognizer(searchMenuTapGesture)
        searchMenu.isUserInteractionEnabled = true
        
//        let findRouteMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showFindRouteScreen(_:)))
//        findRouteMenuTapGesture.numberOfTapsRequired = 1
//        findRouteMenuTapGesture.numberOfTouchesRequired = 1
//        findRouteMenu.addGestureRecognizer(findRouteMenuTapGesture)
//        findRouteMenu.isUserInteractionEnabled = true
//
//        let favoritesMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showFavoritesScreen(_:)))
//        favoritesMenuTapGesture.numberOfTapsRequired = 1
//        favoritesMenuTapGesture.numberOfTouchesRequired = 1
//        favoritesMenu.addGestureRecognizer(favoritesMenuTapGesture)
//        favoritesMenu.isUserInteractionEnabled = true
        
        let settingsMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showSettingsScreen(_:)))
        settingsMenuTapGesture.numberOfTapsRequired = 1
        settingsMenuTapGesture.numberOfTouchesRequired = 1
        settingsMenu.addGestureRecognizer(settingsMenuTapGesture)
        settingsMenu.isUserInteractionEnabled = true
        
        let writeAppReviewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.writeAppReview(_:)))
        writeAppReviewTapGesture.numberOfTapsRequired = 1
        writeAppReviewTapGesture.numberOfTouchesRequired = 1
        writeAppReviewMenu.addGestureRecognizer(writeAppReviewTapGesture)
        writeAppReviewMenu.isUserInteractionEnabled = true
    }
    
    //@objc가 없으면 오류 발생
    @objc func showFindRouteScreen(_ sender: UITapGestureRecognizer) {
        
        handleDrawer()
        
        //왜 작동을 멈추지 않지??
        locationManager.stopUpdatingLocation()
        
        showScreen(viewControllerStoryboardId: "FindRoute")
        
        
        
    }
    
    func showScreen(viewControllerStoryboardId:String) {
        let viewController  = self.storyboard?.instantiateViewController(withIdentifier: viewControllerStoryboardId)
        
        if(viewControllerStoryboardId == "SearchPlace") {
            
            (viewController as! SearchPlaceViewController).delegate  = self
        }
        
        if(viewControllerStoryboardId == "FindRoute") {
            
            (viewController as! FindRouteViewController).selectedPlaceModel  = selectedPlaceModel
        }
        
        self.present(viewController!, animated: true, completion: nil)
    }
    
    
    @objc func emptyViewTapped(_ sender: UITapGestureRecognizer) {
        handleDrawer()
    }
    
    
    @objc func showSearchPlaceScreen(_ sender: UITapGestureRecognizer) {
        handleDrawer()
        
        showScreen(viewControllerStoryboardId: "SearchPlace")
    }
    
    @objc func showFavoritesScreen(_ sender: UITapGestureRecognizer) {
        handleDrawer()
        showScreen(viewControllerStoryboardId: "Favorites")
        
    }
    
    @objc func showSettingsScreen(_ sender: UITapGestureRecognizer) {
        handleDrawer()
        showScreen(viewControllerStoryboardId: "Settings")
        
    }
    
    @objc func writeAppReview(_ sender: UITapGestureRecognizer) {
        // TODO: 구현하세요
        
    }
    
    
    //    //폰의 status bar를 숨기려면 ViewController 마다 아래 코드를 호출해야 함
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
    
    //status bar의 텍스트나 이미지를 흰색으로 지정
    //    override var preferredStatusBarStyle: UIStatusBarStyle {
    //        return .lightContent
    //    }
    
    
    
    
    func initTopSearchBar() {
        //안드로이드 material design의 elevation 효과
        ViewElevationMaker.run(view: topSearchBar)
        
        //Double 변수 선언은 아래처럼 함. var대신 let사용 권장. let은 상수로 한번 지정하면 변경 불가
        //        let elevation: Double = 2.0
        //        topSearchBar.layer.shadowColor = UIColor.black.cgColor
        //        topSearchBar.layer.shadowOffset = CGSize(width: 0, height: elevation)
        //        topSearchBar.layer.shadowOpacity = 0.24
        //        topSearchBar.layer.shadowRadius = CGFloat(elevation)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showSearchPlaceScreenWithOutCloseDrawer(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        topSearchBarLabel.addGestureRecognizer(tapGesture)
        topSearchBarLabel.isUserInteractionEnabled = true
        
    }
    
    @objc func showSearchPlaceScreenWithOutCloseDrawer(_ sender: UITapGestureRecognizer) {
        
        showScreen(viewControllerStoryboardId: "SearchPlace")
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
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // TODO: Info.plist 수정하세요 
        
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        if(isFirstLocation) {
            isFirstLocation = false
            googleMapDrawingManager.showFirstCurrentLocationOnMap(userLocation: userLocation)
        } else {
            //        googleMapDrawingManager.showCurrentLocationOnMap(userLocation: userLocation)
        }
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("main user latitude = \(userLocation.coordinate.latitude)")
        print("main user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func initMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 37.534459, longitude: 126.983314, zoom: 14)
        mapView.camera = camera
        
        //이 메소드가 viewDidLoad보다 먼저 호출됨
        
        
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        NSLog("marker was tapped")
        
        //TODO 나중에 마커 탭 처리할 때 참조하세요
        
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }  
}


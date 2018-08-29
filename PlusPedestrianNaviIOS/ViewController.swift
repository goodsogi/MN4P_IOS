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

class ViewController: UIViewController, GMSMapViewDelegate , CLLocationManagerDelegate{
   
  
    @IBOutlet weak var drawerTrailing: NSLayoutConstraint!
    @IBOutlet weak var mainScreen: UIView!
    
    
    var hamburgerMenuIsVisible = false
    
    @IBOutlet weak var drawer: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var emptyView: UIView!
    var locationManager:CLLocationManager!
   
    @IBOutlet weak var topSearchBar: UIView!
    
    @IBAction func hamburgerButtonTapped(_ sender: Any) {
        //if the hamburger menu is NOT visible, then move the ubeView back to where it used to be
       
        handleDrawer()
        
        
    }
    
    func handleDrawer() {
        if !hamburgerMenuIsVisible {
            
            drawerTrailing.constant = self.view.frame.size.width;
            //1
            hamburgerMenuIsVisible = true
        } else {
            
            drawerTrailing.constant = 0
            //2
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
        initTopSearchBar()
        
        addTapGestureToDrawer()
    }
    
    func addTapGestureToDrawer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.drawerTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        drawer.addGestureRecognizer(tapGesture)
        drawer.isUserInteractionEnabled = true
        
        
        let emptyViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.emptyViewTapped(_:)))
        emptyViewTapGesture.numberOfTapsRequired = 1
        emptyViewTapGesture.numberOfTouchesRequired = 1
        emptyView.addGestureRecognizer(emptyViewTapGesture)
        emptyView.isUserInteractionEnabled = true

    }
    
    @objc func emptyViewTapped(_ sender: UITapGestureRecognizer) {
        
    }
    
    @objc func drawerTapped(_ sender: UITapGestureRecognizer) {
        
        handleDrawer()
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
        
        //Double 변수 선언은 아래처럼 함. var대신 let사용 권장. let은 상수로 한번 지정하면 변경 불가
        let elevation: Double = 2.0
        topSearchBar.layer.shadowColor = UIColor.black.cgColor
        topSearchBar.layer.shadowOffset = CGSize(width: 0, height: elevation)
        topSearchBar.layer.shadowOpacity = 0.24
        topSearchBar.layer.shadowRadius = CGFloat(elevation)
       
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
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func initMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 37.583442, longitude: 127.096359, zoom: 14)
        mapView.camera = camera
        
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.583442, longitude: 127.096359)
        marker.title = "My marker"
        marker.map = self.mapView
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
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }  
}


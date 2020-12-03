//
//  LocationManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 28/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import CoreLocation

//CLLocationManagerDelegate를 사용하려면 NSObject를 상속받아야 하는 듯
class LocationManager: NSObject,CLLocationManagerDelegate {
    //swift에서 singleton 사용하는 방법
    static let sharedInstance = LocationManager()
    var locationManager:CLLocationManager!
    var isFirstLocation:Bool = true
    weak var locationListener:LocationListenerDelegate?
    var location: CLLocation?
    private override init() {}
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // TODO: Info.plist 수정하세요
        
        
        location = locations[0] as CLLocation
        
        if(isFirstLocation) {
            isFirstLocation = false
            locationListener?.onFirstLocationCatched(location: location!)
        } else {
           locationListener?.onLocationCatched(location: location!)
        }
        
        //문자열안에 \()를 사용하여 int, float등을 사용할 수 있는 듯
        print("location latitude:  \(location!.coordinate.latitude), longitude: \(location!.coordinate.longitude)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    
    public func initialize() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    public func getCurrentLocation() -> CLLocation? {
        //TODO 테스트후 삭제하세요
        //fake location
        let location:CLLocation? = CLLocation(latitude: 37.58238158377066, longitude: 127.09463025298389)        
        return location
       
        //TODO 테스트후 주석푸세요
        //return location
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    public func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    public func setLocationListener(locationListener:LocationListenerDelegate?) {
        self.locationListener = locationListener
        
    }
}

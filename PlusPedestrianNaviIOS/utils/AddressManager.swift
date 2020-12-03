//
//  AddressManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 13/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import Foundation
//UIKit에 필수 클래스가 많이 들어 있는 듯
import UIKit
import CoreLocation

public class AddressManager {
    
//    public static func getSimpleAddressForCurrentLocation(location: CLLocation?, completion: ([CLPlacemark]?, Error?)) -> String {
//        let geoCoder = CLGeocoder()
//        var userAddress: String = ""
//        geoCoder.reverseGeocodeLocation(location!) { (placemarks, error) -> Void in
//            if error != nil {
//                NSLog("\(String(describing: error))")
//                return
//            }
//            //TODO: 수정하세요
//            guard let placemark = placemarks?.first,
//                let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
//                    return
//            }
//            let subLocalityString: String? = placemark.addressDictionary?["SubLocality"] as? String
//            let streetString: String? = placemark.addressDictionary?["Street"] as? String
//            let addressString: String = (subLocalityString ?? "") + " " + (streetString ?? "")
//            print("plusapps address: " + addressString)
//            userAddress = addressString
//        }
//        
//        return userAddress
//        
//    }    
  

    
    public static func getSimpleAddressForCurrentLocation(location: CLLocation, completion: @escaping (String?, Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemarks = placemarks, error == nil else {
                completion(nil, error)
                return
            }
            
            guard let placemark = placemarks.first,
                let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                   completion(nil, nil)
                    return
            }
            let subLocalityString: String? = placemark.addressDictionary?["SubLocality"] as? String
            let streetString: String? = placemark.addressDictionary?["Street"] as? String
            let addressString: String = (subLocalityString ?? "") + " " + (streetString ?? "")
            print("plusapps address: " + addressString)
            completion(addressString, nil)
            
        }
    }
    
    static func getFullAddressForCurrentLocation(location: CLLocation, completion: @escaping (String?, Error?) -> PlaceModel?) {
     
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            guard let placemarks = placemarks, error == nil else {
                completion(nil, error)
                return
            }
            
            guard let placemark = placemarks.first,
                let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                   completion(nil, nil)
                    return
            }
          
            let addressString = addrList.joined(separator: " ")
                 completion(addressString, nil)
        }
        
        
    }
}

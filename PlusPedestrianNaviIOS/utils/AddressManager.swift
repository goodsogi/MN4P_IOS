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
    
    public static func getSimpleAddressForCurrentLocation(coordinate: CLLocation) -> String {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(coordinate) { (placemarks, error) -> Void in
            if error != nil {
                NSLog("\(error)")
                return
            }
            //TODO: 수정하세요
            guard let placemark = placemarks?.first,
                let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                    return
            }
            let address = addrList.joined(separator: " ")
            print(address)
        }
        
        return address
        
    }
    
    
}

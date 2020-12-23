//
//  MapDataConverter.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/23.
//  Copyright © 2020 박정규. All rights reserved.
//

import CoreLocation

class MapDataConverter {
    
    public static func convertToLocation(latitude: Double, longitude: Double) -> CLLocation {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        return location
    }
    
}



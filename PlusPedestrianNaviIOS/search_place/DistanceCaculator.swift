//
//  DistanceCaculator.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 21/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import CoreLocation

public class DistanceCaculator {

    public static func getDistanceInt(currentLocation: CLLocation?, lattitude: Double, longitude: Double) -> Int {
        let destination: CLLocation = CLLocation(latitude: lattitude, longitude: longitude)
       
        //CLLocationDistance를 Int로 casting
        return Int(currentLocation?.distance(from: destination) ?? 0)
        
    }
}

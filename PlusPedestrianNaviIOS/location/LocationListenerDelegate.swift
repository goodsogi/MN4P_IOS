//
//  LocationListener.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 28/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import CoreLocation

protocol LocationListenerDelegate : class {
    func onLocationCatched(location: CLLocation)
    func onFirstLocationCatched(location: CLLocation)
}


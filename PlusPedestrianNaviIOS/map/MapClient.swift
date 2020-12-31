//
//  MapClient.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 13/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import UIKit

protocol MapClient {
    func createMap(mapContainer: UIView)
    func getRenderer() -> IMapRenderer?
    func initRenderer(mapView: Any)
}



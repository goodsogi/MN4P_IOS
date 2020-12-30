//
//  NaverMapClient.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 13/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import UIKit
import NMapsMap

public class NaverMapClient : MapClient {
    var mapContainer: UIView?
    
    func setMapContainer(mapContainer: UIView) {
         
        self.mapContainer = mapContainer
    }
    
    
    func createMap() {
        print("plusapps NaverMapClient createMap")
        let mapView = NMFMapView(frame: mapContainer!.frame)
        mapContainer!.addSubview(mapView)
    }
}

//
//  NaverMapClient.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 13/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import UIKit
import NMapsMap

public class NaverMapClient : NSObject, MapClient, NMFMapViewTouchDelegate {
   
       
    var renderer: IMapRenderer?
    
    func createMap(mapContainer: UIView) {
        print("plusapps NaverMapClient createMap")
        let mapView = NMFMapView(frame: mapContainer.frame)
        mapContainer.addSubview(mapView)
        mapView.touchDelegate = self
        renderer = NaverMapRenderer()
        (renderer as! NaverMapRenderer).setMapContainer(mapContainer: mapContainer)
        
        initRenderer(mapView: mapView)
      
    }
    
    func initRenderer(mapView: Any) {
        //renderer = NaverMapRenderer()
        renderer?.setMap(mapView: mapView)
        }
    
    
    
    
    
    func getRenderer() -> IMapRenderer? {
        return renderer
    }
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print("\(latlng.lat), \(latlng.lng)")
    }
 

    func mapView(_ mapView: NMFMapView, didTap symbol: NMFSymbol) -> Bool {
        if symbol.caption == "서울특별시청" {
            print("서울시청 탭")
            return true

        } else {
            print("symbol 탭")
            return false
        }
    }
}

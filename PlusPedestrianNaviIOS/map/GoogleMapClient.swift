//
//  GoogleMapClient.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 13/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import UIKit
import GoogleMaps

public class GoogleMapClient: NSObject, MapClient, GMSMapViewDelegate {
   
     var renderer: IMapRenderer?
    
    func createMap(mapContainer: UIView) {
        print("plusapps GoogleMapClient createMap")
        let camera =  GMSCameraPosition.camera(withLatitude: 37.534459, longitude: 126.983314, zoom: 14)
        let mapView = GMSMapView.map(withFrame: mapContainer.frame, camera: camera)
        mapView.delegate = self
        
        //mapContainer = mapView라고 하면 지도가 표시 안됨 
        mapContainer.addSubview(mapView)
      
        initRenderer(mapView: mapView)
    }
    
    func initRenderer(mapView: Any) {
        renderer = GoogleMapRenderer()
        renderer?.setMap(mapView: mapView)
        }
    
    func getRenderer() -> IMapRenderer? {
        print("plusapps GoogleMapClient getRenderer")
        return renderer
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        print("marker was tapped")
        
        //TODO: 나중에 마커 탭 처리할 때 참조하세요
        
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
        print("plusapps mapView didTapAt")
//        if (screenType == ROUTE_INFO) {
//            let wayPoint : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//
//            wayPoints.append(wayPoint)
//            showClearWaypointsButton()
//            findRoute()
//
//        }
        
        //TODO: 나중에 참조하세요
        //        customInfoWindow?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        
        //TODO: 나중에 참조하세요
        //        let position = tappedMarker?.position
        //        customInfoWindow?.center = mapView.projection.point(for: position!)
        //        customInfoWindow?.center.y -= 140
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
    }
    
    
}

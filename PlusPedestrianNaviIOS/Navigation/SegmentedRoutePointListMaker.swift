//
//  SegmentedRoutePointListMaker.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/23.
//  Copyright © 2020 박정규. All rights reserved.
//

import CoreLocation

class SegmentedRoutePointListMaker {
    
    public static func run() -> [RoutePointModel] {
        
        let routePointList = Mn4pSharedDataStore.directionModel!.getRoutePointModels()
        print("plusapps routePointList size: " + String(routePointList?.count ?? 0))
        
        var segmentedRoutePointList: [RoutePointModel] = [RoutePointModel]()
        
        var firstRoutePointLocation: CLLocation
        var secondRoutePointLocation: CLLocation
        
        var distance: Int
        var firstRoutePointLatitude: Double
        var firstRoutePointLongitude: Double
        var secondRoutePointLatitude: Double
        var secondRoutePointLongitude: Double
        
        var segmentedRoutePoint: RoutePointModel
        var routePointLatitudeDelta: Double
        var routePointLongitudeDelta: Double
        
        
        
        for i in 0..<routePointList!.count - 1 {
            
            firstRoutePointLocation = MapDataConverter.convertToLocation(latitude: routePointList![i].getLat() ?? 0, longitude:  routePointList![i].getLng() ?? 0)
            
            secondRoutePointLocation = MapDataConverter.convertToLocation(latitude: routePointList![i + 1].getLat() ?? 0, longitude:  routePointList![i + 1].getLng() ?? 0)
            
            
            firstRoutePointLatitude = routePointList![i].getLat() ?? 0
            firstRoutePointLongitude = routePointList![i].getLng() ?? 0
            
            secondRoutePointLatitude = routePointList![i + 1].getLat() ?? 0
            secondRoutePointLongitude = routePointList![i + 1].getLng() ?? 0
            
           
            distance = Int(secondRoutePointLocation.distance(from: firstRoutePointLocation))
            
            if (distance == 0) {
                segmentedRoutePoint = RoutePointModel()
                segmentedRoutePoint.setLat(lat: firstRoutePointLatitude)
                segmentedRoutePoint.setLng(lng: firstRoutePointLongitude)
                segmentedRoutePointList.append(segmentedRoutePoint)
                continue
            }
            
            routePointLatitudeDelta = (secondRoutePointLatitude - firstRoutePointLatitude) / Double(distance)
            routePointLongitudeDelta = (secondRoutePointLongitude - firstRoutePointLongitude) / Double(distance)
            
            for j in 0..<distance {
                            segmentedRoutePoint = RoutePointModel()
                segmentedRoutePoint.setLat(lat: firstRoutePointLatitude + (routePointLatitudeDelta * Double(j)))
                segmentedRoutePoint.setLng(lng: firstRoutePointLongitude + (routePointLongitudeDelta * Double(j)))
                            segmentedRoutePointList.append(segmentedRoutePoint)
                        }
        }
        
        
        segmentedRoutePointList.append(routePointList![routePointList!.count - 1])
        return segmentedRoutePointList
    }
    
    
}

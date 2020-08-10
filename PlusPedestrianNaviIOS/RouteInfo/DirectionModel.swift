//
//  DirectionModel.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 10..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import GoogleMaps

class DirectionModel {
    private var geofenceModels: [RoutePointModel]? = nil
    private var routePointModels: [RoutePointModel]? = nil
    private var wayPoints: [CLLocationCoordinate2D]? = nil
    private var totalDistance: Int? = nil
    private var totalTime: Int? = nil
    
    
    func setGeofenceModels(geofenceModels:[RoutePointModel]) {
        self.geofenceModels = geofenceModels
    }
    
    func setRoutePointModels(routePointModels:[RoutePointModel]) {
        self.routePointModels = routePointModels
    }
    
    func setWayPoints(wayPoints:[CLLocationCoordinate2D]) {
        self.wayPoints = wayPoints
    }
    
    func setTotalDistance(totalDistance:Int) {
        self.totalDistance = totalDistance
    }
    
    func setTotalTime(totalTime:Int) {
        self.totalTime = totalTime
    }
    
    
    func getGeofenceModels() -> [RoutePointModel]? {
        return self.geofenceModels
    }
    
    func getRoutePointModels() -> [RoutePointModel]? {
        return self.routePointModels
    }
    
    func getWayPoints() -> [CLLocationCoordinate2D]? {
        return self.wayPoints
    }
    
    func getTotalDistance() -> Int? {
        return self.totalDistance
    }
    
    func getTotalTime() -> Int? {
        return self.totalTime
    }
    
}

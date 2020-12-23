//
//  NavigationEngine.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/23.
//  Copyright © 2020 박정규. All rights reserved.
//
import CoreLocation

class NavigationEngine {
    //swift에서 singleton 사용하는 방법
    //swift에서 앱 종료시 singleton 객체에 nil을 할당할 필요는 없는 듯
    static let sharedInstance = NavigationEngine()
    private init() {}
    
    private var geofenceList: [GeofenceModel]?
    var geofenceListenerDelegate: GeofenceListenerDelegate?
    var segmentedRoutePointListenerDelegate: SegmentedRoutePointListenerDelegate?
    var arriveDestinationListenerDelegate: ArriveDestinationListenerDelegate?
    private var activeSegmentedRoutePointIndex: Int?
    private var segmentedRoutePointList: [RoutePointModel]?
    private var segmentedGeofenceIndexMap: [Int : Int]?
    private var geofenceEnterAreaMap: [Int : Bool]?
    private var geofenceIndexMap: [Int : Int]?
    private var geofenceEnterCheckMap: [Int : Bool]?
    private var geofenceExitCheckMap: [Int : Bool]?
    
    /*
     초기화
     */
    
    public func initEngine() {
        
        geofenceList = Mn4pSharedDataStore.directionModel!.getGeofenceModels()!
        activeSegmentedRoutePointIndex = 0;
        segmentedRoutePointList = SegmentedRoutePointListMaker.run()
        segmentedGeofenceIndexMap = makeSegmentedGeofenceIndexMap()
        geofenceEnterAreaMap = makeGeofenceEnterAreaMap()
        geofenceIndexMap = makeGeofenceIndexMap()
        geofenceEnterCheckMap = initGeofenceEnterCheckMap()
        geofenceExitCheckMap = initGeofenceExitCheckMap()
        isEnginePaused = true
        isEngineRunning = false
        remainDistanceToGeofence = 0
        
    }
    
    public func setGeofenceEnterListenerDelegate(geofenceListenerDelegate: GeofenceListenerDelegate) {
        self.geofenceListenerDelegate = geofenceListenerDelegate
    }
    
    public func setArriveDestinationListenerDelegate(arriveDestinationListenerDelegate: ArriveDestinationListenerDelegate) {
        self.arriveDestinationListenerDelegate = arriveDestinationListenerDelegate
    }
    
    public func setSegmentedRoutePointListenerDelegate(segmentedRoutePointListenerDelegate: SegmentedRoutePointListenerDelegate) {
        self.segmentedRoutePointListenerDelegate = segmentedRoutePointListenerDelegate
    }
    
    
    private func initGeofenceExitCheckMap() -> [Int : Bool] {
        
        var hashMap = [Int : Bool]()
        
        var index: Int = 0
        
        for _ in geofenceList! {
            
            hashMap[index] = false
            index = index + 1
            
        }
        
        return hashMap
        
    }
    
    private func initGeofenceEnterCheckMap() -> [Int : Bool] {
        
        var hashMap = [Int : Bool]()
        
        var index: Int = 0
        
        for _ in geofenceList! {
            
            hashMap[index] = false
            index = index + 1
            
        }
        
        return hashMap
        
    }
    
    
    private func makeGeofenceIndexMap() -> [Int : Int] {
        var hashMap = [Int : Int]()
        var segmentedGeofenceIndex: Int = segmentedGeofenceIndexMap![0] ?? 0
        var geofenceIndex: Int = 0
        var index: Int = 0
        
        for _ in segmentedRoutePointList! {
            
            hashMap[index] = geofenceIndex
            
            if (index == segmentedGeofenceIndex) {
                geofenceIndex = geofenceIndex + 1
                
                if (geofenceIndex < geofenceList!.count) {
                    segmentedGeofenceIndex = segmentedGeofenceIndexMap![geofenceIndex] ?? 0
                }
            }
            
            index = index + 1
            
        }
        
        return hashMap
    }
    
    private func makeGeofenceEnterAreaMap() -> [Int : Bool] {
        var hashMap = [Int : Bool]()
        var segmentedGeofenceIndex: Int = 0
        var geofenceIndex: Int = 0
        var index: Int = 0
        
        for _ in segmentedRoutePointList! {
            
            if (index >= segmentedGeofenceIndex - DISTANCE_ENTER_GEOFENCE) {
                hashMap[index] = true
            } else {
                hashMap[index] = false
            }
            
            if (index == segmentedGeofenceIndex) {
                geofenceIndex = geofenceIndex + 1
                if (geofenceIndex < geofenceList!.count) {
                    segmentedGeofenceIndex = segmentedGeofenceIndexMap![geofenceIndex] ?? 0
                }
            }
            index = index + 1
        }
        
        
        
        return hashMap
    }
    
    
    private func makeSegmentedGeofenceIndexMap() -> [Int : Int] {
        var hashMap = [Int : Int]()
        
        var minDistance: Double = 1000
        var minDistanceIndex: Int = 0
        var i: Int = 0
        var j: Int = 0
        
        
        for _ in geofenceList! {
            
            for _ in segmentedRoutePointList! {
               //자바에서는 절대값을 Math.abs()로 구하는데 swift는 abs()로 구함
                let distanceValue1 = abs((segmentedRoutePointList![j].getLat() ?? 0) - (geofenceList![i].getLng() ?? 0))
                let distanceValue2 = abs((segmentedRoutePointList![j].getLat() ?? 0) - (geofenceList![i].getLng() ?? 0))
                
                let distance = distanceValue1 + distanceValue2
                
                if (distance < minDistance) {
                    minDistance = distance
                    minDistanceIndex = j
                }
                j = j + 1
            }
            hashMap[i] =  minDistanceIndex
            minDistance = 1000
            i = i + 1
            
        }
        
        
        
        return hashMap
        
    }
    
    
    
    /*
     geofence enter/exit/approach 처리
     */
    
    private let DISTANCE_ENTER_GEOFENCE: Int = 20
    //TODO 필요시 ENTER_SEGMENTED_ROUTE_POINT 값 수정하세요
    private let ENTER_SEGMENTED_ROUTE_POINT: Int = 20
    private let DELAY_GEOFENCE_APPROACH: Int = 5000
    private let MAX_OUT_OF_ROUTE_COUNT: Int = 30
    private var outOfRouteCount: Int?
    private var approachDistanceToGeofenceEnter: Int?
    private var isGeofenceApproachDelayHandled: Bool?
    private var remainDistanceToGeofence: Int?
    
    
    public func run(location: CLLocation) {
        //gps가 튀는 현상 방지. 특정 횟수를(예를 들어 12회) 초과하면 경로 이탈 처리
                if (isLocationOnPath(location) != true) {
                    outOfRouteCount = outOfRouteCount + 1
                    if (outOfRouteCount >= MAX_OUT_OF_ROUTE_COUNT) {
                        pause()
                        outOfRouteCount = 0
                        geofenceListenerDelegate.onOutOfGeofence()
                    }
                    return
                } else {
                    outOfRouteCount = 0
                }

                setRemainDistanceToGeofence()
                handleNearestSegmentedRoutePoint()
                showNavigationMarker()
                handleGeofenceApproach()
    }
    
    
    
    /*
     엔진 일시정지/중지/재시작
     */
    
    private var isEnginePaused: Bool = false
    private var isEngineRunning: Bool = false
    
    
}

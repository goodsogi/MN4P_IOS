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
    private init() {
        //모든 변수를 초기화하지 않으면 오류발생
        //여기서 초기화를 할 수 없는 변수는 type에 ?(optional)을 붙여야 하는 듯
        //함수를 호출하여 초기화할 수 없는 듯 
        
        activeSegmentedRoutePointIndex = 0;
        
        isEnginePaused = true
        isEngineRunning = false
        remainDistanceToGeofence = 0
        
        
    }
    
    private var geofenceList: [GeofenceModel]?
    var geofenceListenerDelegate: GeofenceListenerDelegate?
    var segmentedRoutePointListenerDelegate: SegmentedRoutePointListenerDelegate?
    var arriveDestinationListenerDelegate: ArriveDestinationListenerDelegate?
    private var activeSegmentedRoutePointIndex: Int
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
        segmentedRoutePointList = SegmentedRoutePointListMaker.run()
        segmentedGeofenceIndexMap = makeSegmentedGeofenceIndexMap()
        geofenceEnterAreaMap = makeGeofenceEnterAreaMap()
        geofenceIndexMap = makeGeofenceIndexMap()
        geofenceEnterCheckMap = initGeofenceEnterCheckMap()
        geofenceExitCheckMap = initGeofenceExitCheckMap()
        
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
        if (isLocationOnPath(currentLocation: location) != true) {
            outOfRouteCount = outOfRouteCount ?? 0 + 1
            if ((outOfRouteCount ?? 0) >= MAX_OUT_OF_ROUTE_COUNT) {
                        pauseEngine()
                        outOfRouteCount = 0
                        geofenceListenerDelegate?.onOutOfGeofence()
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
    
    private func handleGeofenceApproach() {
           if( isGeofenceApproachDelayHandled == false) {
               return
           }

        let geofenceIndex: Int = geofenceIndexMap![activeSegmentedRoutePointIndex] ?? 0
        let segmentedGeofenceIndex: Int = segmentedGeofenceIndexMap![geofenceIndex ] ?? 0
        let distanceToGeofenceEnter: Int = segmentedGeofenceIndex - (activeSegmentedRoutePointIndex) - 20

           if (distanceToGeofenceEnter <= 0) {
               return
           }

        geofenceListenerDelegate?.onApproached(distanceToGeofenceEnter: distanceToGeofenceEnter)

           if (distanceToGeofenceEnter <= (approachDistanceToGeofenceEnter ?? 0) && approachDistanceToGeofenceEnter != 0) {
            geofenceListenerDelegate?.onApproachedByFiftyMeters(description: geofenceList![geofenceIndex].getDescription() ?? "", distanceToGeofenceEnter: (approachDistanceToGeofenceEnter ?? 0))
            approachDistanceToGeofenceEnter = (approachDistanceToGeofenceEnter ?? 0) - 50
               startGeofenceApproachDelayHandler()
           }
       }
    
    
    
    private func showNavigationMarker() {
        let segmentedRoutePoint: RoutePointModel = segmentedRoutePointList![activeSegmentedRoutePointIndex ]
        let segmentedRoutePointLocation: CLLocation = MapDataConverter.convertToLocation(latitude: segmentedRoutePoint.getLat() ?? 0, longitude: segmentedRoutePoint.getLng() ?? 0)
            segmentedRoutePointListenerDelegate?.onGetNearestSegmentedRoutePoint(nearestSegmentedRoutePoint: segmentedRoutePointLocation)
        }
    
    
    
    private func setRemainDistanceToGeofence() {
        remainDistanceToGeofence = (remainDistanceToGeofence ?? 0) - 1
        }
    
    
    private func isLocationOnPath(currentLocation: CLLocation) -> Bool {
        if (activeSegmentedRoutePointIndex == segmentedRoutePointList!.count) {
            pauseEngine()
                    return false
                }

        let minDistanceIndex: Int = getMinDistanceIndex(iValue: activeSegmentedRoutePointIndex, currentLocation: currentLocation)

                if (minDistanceIndex != -1) {
                    activeSegmentedRoutePointIndex = minDistanceIndex
                }

                return minDistanceIndex != -1
    }
    
    
    private func getMinDistanceIndex(iValue: Int, currentLocation: CLLocation) -> Int {
        var routePointLocation: CLLocation
        var distance: Int
        var minDistance: Int = 10000
        var minDistanceIndex: Int = -1
        var isFoundMinDistance: Bool = false
        
        
        for i in iValue..<segmentedRoutePointList!.count {
          
            routePointLocation = MapDataConverter.convertToLocation(latitude: segmentedRoutePointList![i].getLat() ?? 0, longitude:  segmentedRoutePointList![i].getLng() ?? 0)
            
            distance = Int(currentLocation.distance(from: routePointLocation))
         
                if (distance <= ENTER_SEGMENTED_ROUTE_POINT && distance < minDistance) {
                    minDistance = distance
                    minDistanceIndex = i
                    isFoundMinDistance = true
                }

                //min distance 값을 찾았고 20미터보다 큰 distance 값을 만나면 for loop 중지
                if (isFoundMinDistance && distance > ENTER_SEGMENTED_ROUTE_POINT) {
                    break
                }
            }

            return minDistanceIndex
        }
    
    private func handleNearestSegmentedRoutePoint() {
        let geofenceIndex: Int = geofenceIndexMap![activeSegmentedRoutePointIndex] ?? 0
        let previousGeofenceIndex: Int = geofenceIndex - 1
        let currentGeofenceModel: GeofenceModel = geofenceList![geofenceIndex]
        let previousGeofenceModel: GeofenceModel? = previousGeofenceIndex == -1 ? nil : geofenceList![previousGeofenceIndex]

           //minDistanceIndex가 geofence enter 영역에 있을 때 처리
        if (geofenceEnterAreaMap![activeSegmentedRoutePointIndex] ?? false) {
               //이전 geofence exit 처리했는지 확인
               if (geofenceIndex != 0) {
                   handleGeofenceExit(previousGeofenceIndex: previousGeofenceIndex, previousGeofenceModel: previousGeofenceModel, geofenceModel: currentGeofenceModel)
               }

               if (!isArriveGeofence()) {
                   return
               }

               //현재 geofence enter 처리
            var nextGeofenceModel: GeofenceModel? = nil
            if (geofenceIndex + 1 < geofenceList!.count) {
                   nextGeofenceModel = geofenceList![geofenceIndex + 1]
               }
            handleGeofenceEnter(geofenceIndex: geofenceIndex, currentGeofenceModel: currentGeofenceModel, nextGeofenceModel: nextGeofenceModel)

           } else {
               handleGeofenceExit( previousGeofenceIndex: previousGeofenceIndex, previousGeofenceModel: previousGeofenceModel, geofenceModel: currentGeofenceModel)
  
           }
       }
    
    private func isArriveGeofence() -> Bool {
        return remainDistanceToGeofence ?? 0 <= 0
        }
    
    private func handleGeofenceExit(previousGeofenceIndex: Int, previousGeofenceModel: GeofenceModel?, geofenceModel: GeofenceModel) {
           if (geofenceExitCheckMap![previousGeofenceIndex] != true) {
               geofenceExitCheckMap![previousGeofenceIndex] = true
               geofenceListenerDelegate?.onExit(previousGeofence: previousGeofenceModel, currentGeofence: geofenceModel);
               setInitialApproachDistanceToGeofence()
           }
       }
    
    private func handleGeofenceEnter(geofenceIndex: Int, currentGeofenceModel: GeofenceModel, nextGeofenceModel: GeofenceModel?) {
            if (geofenceEnterCheckMap![geofenceIndex] != true) {
                geofenceEnterCheckMap![geofenceIndex] = true
                if (geofenceIndex == geofenceList!.count - 1) {
                    arriveDestinationListenerDelegate?.onArrivedToDestination()
                } else {
                    geofenceListenerDelegate?.onEntered(currentGeofence: currentGeofenceModel, nextGeofence: nextGeofenceModel)
                    let segmentedGeofenceIndex: Int = segmentedGeofenceIndexMap![geofenceIndex] ?? 0
                    remainDistanceToGeofence = segmentedGeofenceIndex - (activeSegmentedRoutePointIndex)
                    }
            }
        }
    
    private func setInitialApproachDistanceToGeofence() {
        let geofenceIndex: Int = geofenceIndexMap![activeSegmentedRoutePointIndex] ?? 0
        let segmentedGeofenceIndex: Int = segmentedGeofenceIndexMap![geofenceIndex] ?? 0
        let distanceToGeofenceEnter: Int = segmentedGeofenceIndex - (activeSegmentedRoutePointIndex) - 20
            approachDistanceToGeofenceEnter = distanceToGeofenceEnter / 50 * 50;

            //최소한 경로안내 지점(geofence - 20)에서 10미터 앞이면 approach 안내 처리
            if (distanceToGeofenceEnter > 10) {
                geofenceListenerDelegate?.onApproachedByFiftyMeters(description: "", distanceToGeofenceEnter: distanceToGeofenceEnter);
                //같은 거리를 두 번 안내 방지
                if (distanceToGeofenceEnter % 50 == 0) {
                    approachDistanceToGeofenceEnter = (approachDistanceToGeofenceEnter ?? 0) - 50
                }
                startGeofenceApproachDelayHandler()
            }
        }

    private func startGeofenceApproachDelayHandler() {
          //TODO 자바의 handler를 제거했는데 제대로 작동하는지 확인하세요

            isGeofenceApproachDelayHandled = false
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            
            self.isGeofenceApproachDelayHandled = true
            
      
        })
    }
        

    
    
    /*
     엔진 일시정지/중지/재시작
     */
    
    private var isEnginePaused: Bool = false
    private var isEngineRunning: Bool = false
    
    public func pauseEngine() {
            isEnginePaused = true
        }
    
    public func pauseForOverview(overviewExitListenerDelegate: OverviewExitListenerDelegate) {

           if (isEnginePaused) {
               return
           }

           isEnginePaused = true

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            overviewExitListenerDelegate.onExitFromOverview()
            self.isEnginePaused = false
            
      
        })
         
       }
    
    public func restart() {
           isEnginePaused = false
       }

       public func getIsEnginePaused() -> Bool {
           return isEnginePaused
       }

       public func betIsEngineRunning() -> Bool {
           return isEngineRunning
       }

       public func stop() {
           isEnginePaused = true
           isEngineRunning = false
       }
    
    /*
     progress/남은 거리/current geofence 가져오기
     */
    
    
    public func getProgress() -> Double {
        return Double(activeSegmentedRoutePointIndex) / Double(segmentedRoutePointList!.count)
       }

       public func getRemainingDistance() -> Int {
        return segmentedRoutePointList!.count - (activeSegmentedRoutePointIndex)
       }

       public func getActiveSegmentedRoutePoint() -> RoutePointModel {
           return segmentedRoutePointList![activeSegmentedRoutePointIndex]
       }
    
    public func getAngleForOverview() -> Double {
        if ((activeSegmentedRoutePointIndex) <= 0) {
                return 0
            }

        let geofenceIndex: Int = geofenceIndexMap![activeSegmentedRoutePointIndex ] ?? 0
        let previousGeofenceIndex: Int = geofenceIndex - 1
        let geofenceModel: GeofenceModel = geofenceList![geofenceIndex]
        let previousGeofenceModel: GeofenceModel = geofenceList![previousGeofenceIndex]
      
        let geofenceLocation: CLLocation = MapDataConverter.convertToLocation(latitude: geofenceModel.getLat() ?? 0, longitude: geofenceModel.getLng() ?? 0)
        
        let previousGeofenceLocation: CLLocation = MapDataConverter.convertToLocation(latitude: previousGeofenceModel.getLat() ?? 0, longitude: previousGeofenceModel.getLng() ?? 0)
        
        
        return BearingManager.getBearingBetweenTwoPoints1(point1: previousGeofenceLocation, point2: geofenceLocation)
        }
    
    
  
    public func start() {
           isEnginePaused = false
           isEngineRunning = true
       }
    
    public func getBearingValueForStartMessage(currentLocation: CLLocation?) -> Double {

        let minDistanceIndex: Int = getMinDistanceIndex(iValue: 0, currentLocation: currentLocation)

            if (minDistanceIndex == -1) {
                return 0;
            }

            if (currentLocation == nil) {
                return 0
            }

        var firstGeofenceLocation: CLLocation
        var secondGeofenceLocation: CLLocation
      
        let geofenceIndex: Int = geofenceIndexMap![minDistanceIndex] ?? 0

            if (geofenceIndex == 0) {
                let nextGeofenceIndex: Int  = geofenceIndex + 1

                let geofenceModel: GeofenceModel = geofenceList![geofenceIndex]
                let nextGeofenceModel: GeofenceModel = geofenceList![nextGeofenceIndex]

                firstGeofenceLocation = MapDataConverter.convertToLocation(latitude: geofenceModel.getLat() ?? 0, longitude: geofenceModel.getLng() ?? 0)
                secondGeofenceLocation = MapDataConverter.convertToLocation(latitude: nextGeofenceModel.getLat() ?? 0, longitude: nextGeofenceModel.getLng() ?? 0)
               
            } else {
                let previousGeofenceIndex: Int = geofenceIndex - 1
                
                let geofenceModel: GeofenceModel = geofenceList![geofenceIndex]
                let previousGeofenceModel: GeofenceModel = geofenceList![previousGeofenceIndex]

                firstGeofenceLocation = MapDataConverter.convertToLocation(latitude: previousGeofenceModel.getLat() ?? 0, longitude: previousGeofenceModel.getLng() ?? 0)
                secondGeofenceLocation = MapDataConverter.convertToLocation(latitude: geofenceModel.getLat() ?? 0, longitude: geofenceModel.getLng() ?? 0)
            }

        return BearingManager.getBearingBetweenTwoPoints1(point1: firstGeofenceLocation, point2: secondGeofenceLocation)
        }
    
    
    private func getMinDistanceIndex(iValue: Int, currentLocation: CLLocation?) -> Int {
        var routePointLocation: CLLocation
            var distance: Int
        var minDistance: Int = 10000
        var minDistanceIndex: Int = -1
        var isFoundMinDistance: Bool = false
        
        
        for i in iValue ..< segmentedRoutePointList!.count {
            routePointLocation = MapDataConverter.convertToLocation(latitude: segmentedRoutePointList![i].getLat() ?? 0, longitude: segmentedRoutePointList![i].getLng() ?? 0)
            
            distance = Int(currentLocation?.distance(from: routePointLocation) ?? 0)
            if (distance <= ENTER_SEGMENTED_ROUTE_POINT && distance < minDistance) {
                minDistance = distance
                minDistanceIndex = i
                isFoundMinDistance = true
            }
            
            //min distance 값을 찾았고 20미터보다 큰 distance 값을 만나면 for loop 중지
            if (isFoundMinDistance && distance > ENTER_SEGMENTED_ROUTE_POINT) {
                break
            }
            
        }
        
           

            return minDistanceIndex
        }

}

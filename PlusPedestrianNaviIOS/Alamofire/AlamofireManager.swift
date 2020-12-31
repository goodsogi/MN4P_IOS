//
//  AlamofireManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 12..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Alamofire
import CoreLocation
import SwiftyJSON

class AlamofireManager {
    
    //Tmap api
    let TMAP_APP_KEY:String = "c605ee67-a552-478c-af19-9675d1fc8ba3"; // 티맵 앱 key
    
    
    //********************************************************************************************************
    //
    // 장소 검색
    //
    //********************************************************************************************************
   
    public func searchPlace(searchKeyword : String) {
      
        let url:String = "https://api2.sktelecom.com/tmap/pois"
        let param = ["version": "1", "appKey": TMAP_APP_KEY, "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO", "searchKeyword": searchKeyword]
        
        
        Alamofire.request(url,
                          method: .get,
                          parameters: param,
                          encoding: URLEncoding.default,
                          headers: ["Content-Type":"application/json", "Accept":"application/json"]
            )
            .validate(statusCode: 200..<300)
            .responseJSON {
                
                response in
                
                switch response.result {
                case .success:
                    if let responseData = response.result.value {
                        
                        NotificationCenter.default.post(
                            name: Notification.Name(rawValue: Mn4pConstants.NOTIFICATION_ALAMOFIRE_SEARCH_PLACE),
                            object: nil,
                            userInfo: ["result": "success",  "placeModels" : self.extractPlaceModels(responseData: responseData)])
                        
                    } else {
                        
                        NotificationCenter.default.post(
                            name: Notification.Name(rawValue: Mn4pConstants.NOTIFICATION_ALAMOFIRE_SEARCH_PLACE),
                            object: nil,
                            userInfo: ["result": "fail"])
                        
                    }
                    print("Validation Successful")
                case .failure(let error):
                    
                    //TODO 나중에 제대로 작동하는지 확인하세요
                    if(error.localizedDescription.contains("forbidden")) {
                        NotificationCenter.default.post(
                            name: Notification.Name(rawValue: Mn4pConstants.NOTIFICATION_ALAMOFIRE_SEARCH_PLACE),
                            object: nil,
                            userInfo: ["result": "overApi"])
                    } else {
                        
                        NotificationCenter.default.post(
                            name: Notification.Name(rawValue: Mn4pConstants.NOTIFICATION_ALAMOFIRE_SEARCH_PLACE),
                            object: nil,
                            userInfo: ["result": "fail"])
                    }
                    
                    print(error)
                }
                
                
        }
    
    }
    
    private func extractPlaceModels(responseData : Any) -> [PlaceModel]{
        
        let swiftyJsonVar = JSON(responseData)
        
        var placeModel:PlaceModel
        
        var placeModels = [PlaceModel]()
        
        for subJson in swiftyJsonVar["searchPoiInfo"]["pois"]["poi"].arrayValue {
            placeModel = PlaceModel()
            
            let name = subJson["name"].stringValue
            let telNo = subJson["telNo"].stringValue
            let upperAddrName = subJson["upperAddrName"].stringValue
            let middleAddrName = subJson["middleAddrName"].stringValue
            let roadName = subJson["roadName"].stringValue
            let firstBuildNo = subJson["firstBuildNo"].stringValue
            let secondBuildNo = subJson["secondBuildNo"].stringValue
            let bizName = subJson["lowerBizName"].stringValue
            let latitude = subJson["noorLat"].doubleValue
            let longitude = subJson["noorLon"].doubleValue
            
            var address = upperAddrName + " " + middleAddrName + " " + roadName + " " + firstBuildNo
            if secondBuildNo != "" {
                address = address + "-" + secondBuildNo
            }
            
            
            placeModel.setName(name: name)
            placeModel.setAddress(address: address)
            placeModel.setLatitude(latitude: latitude)
            placeModel.setLongitude(longitude: longitude)
            placeModel.setBizname(bizName: bizName)
            placeModel.setTelNo(telNo: telNo)
            
            placeModels.append(placeModel)
            
        }
        
        return placeModels
        
    }
    
    
    //*******************************************************************************************************
    //
    // 경로안내 데이터 가져오기(경로찾기, 경로안내 2 곳에서 사용)
    //
    //********************************************************************************************************
    
    public func getDirection(startPointModel : PlaceModel , destinationModel : PlaceModel , selectedRouteOption : String, wayPoints: [CLLocationCoordinate2D], notificationName : String) {
        let url:String = "https://api2.sktelecom.com/tmap/routes/pedestrian?version=1&appKey=" + TMAP_APP_KEY
        
        
        
        //TODO: 나중에 passList(경유점), angle, searchOption 수정하세요
        //각도는 경로에 영향을 안미치는 듯 보임. 유효값: 0 ~ 359
        //검색 옵션 0: 추천 (기본값), 4: 추천+번화가우선, 10: 최단, 30: 최단거리+계단제외
    

        var param: [String: Any] = [:]
 
        if wayPoints.count > 0 {
            let wayPointsString : String = convertWaypointsToString(wayPoints : wayPoints)
           
            
            param = [  "startX": String(format: "%f", startPointModel.getLongitude() ?? 0), "startY": String(format: "%f", startPointModel.getLatitude() ?? 0) , "endX": String(format: "%f", destinationModel.getLongitude() ?? 0) , "endY": String(format: "%f", destinationModel.getLatitude() ?? 0) , "angle": "0" , "searchOption": selectedRouteOption , "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO","startName": "start", "endName": "end", "passList": wayPointsString]
        } else {
            param = [  "startX": String(format: "%f", startPointModel.getLongitude() ?? 0), "startY": String(format: "%f", startPointModel.getLatitude() ?? 0) , "endX": String(format: "%f", destinationModel.getLongitude() ?? 0) , "endY": String(format: "%f", destinationModel.getLatitude() ?? 0) , "angle": "0" , "searchOption": selectedRouteOption , "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO","startName": "start", "endName": "end"]
        }
        
        
       print("startX: " + String(format: "%f", startPointModel.getLongitude() ?? 0))
        print("startY: " + String(format: "%f", startPointModel.getLatitude() ?? 0))
        print("endX: " + String(format: "%f", destinationModel.getLongitude() ?? 0))
        print("endY: " + String(format: "%f", destinationModel.getLatitude() ?? 0))
        print("angle: " + "0")
        print("searchOption: " + selectedRouteOption)
    
        
        
        //headers: ["Content-Type":"application/json", "Accept":"application/json"] 값을 지정하면 오류 발생
        Alamofire.request(url,
                          method: .post,
                          parameters: param,
                          encoding: URLEncoding.default
            )
            .validate(statusCode: 200..<300)
            .responseJSON {
                response in
                
                switch response.result {
                case .success:
                    if let responseData = response.result.value {
                        
                        NotificationCenter.default.post(
                            name: Notification.Name(rawValue: notificationName),
                            object: nil,
                            userInfo: ["result": "success", "directionModel" : self.getDirectionModel(responseData: responseData)])
                        
                        
                    } else {
                        //TODO: 오류가 발생한 경우 처리하세요
                        NotificationCenter.default.post(
                            name: Notification.Name(rawValue: notificationName),
                            object: nil,
                            userInfo: ["result": "fail"])
                        
                    }
                    print("Validation Successful")
                case .failure(let error):
                   
                    //TODO 나중에 제대로 작동하는지 확인하세요
                    if(error.localizedDescription.contains("forbidden")) {
                        NotificationCenter.default.post(
                            name: Notification.Name(rawValue: notificationName),
                            object: nil,
                            userInfo: ["result": "overApi"])
                    } else {
                        
                        NotificationCenter.default.post(
                            name: Notification.Name(rawValue: notificationName),
                            object: nil,
                            userInfo: ["result": "fail"])
                    }
                    
                    print(error)
                }
                
                
        }
    
    
    }
    
    
    private func convertWaypointsToString(wayPoints : [CLLocationCoordinate2D]) -> String {
          
       
        var wayPointsString : String = ""
        var index : Int = 0
        for wayPoint in wayPoints {
            wayPointsString.append(String(format: "%f", wayPoint.longitude))
            wayPointsString.append(",")
            wayPointsString.append(String(format: "%f", wayPoint.latitude))
            if (index != wayPoints.count) {
                wayPointsString.append("_")
            }
            index += 1
        }
       

          return wayPointsString
      }
    
    
//    public func getDirection(selectedPlaceModel : PlaceModel , userLocation : CLLocation , selectedRouteOption : String, notificationName : String) {
//        let url:String = "https://api2.sktelecom.com/tmap/routes/pedestrian?version=1&appKey=" + TMAP_APP_KEY
//
//        //TODO: 나중에 passList(경유점), angle, searchOption 수정하세요
//        //각도는 경로에 영향을 안미치는 듯 보임. 유효값: 0 ~ 359
//        //검색 옵션 0: 추천 (기본값), 4: 추천+번화가우선, 10: 최단, 30: 최단거리+계단제외
//
//        let param = [  "startX": String(userLocation.coordinate.longitude) , "startY": String(userLocation.coordinate.latitude) , "endX": String(selectedPlaceModel.getLongitude()! ) , "endY": String(selectedPlaceModel.getLatitude()! ) , "angle": "0" , "searchOption": selectedRouteOption , "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO","startName": "start", "endName": "end"]
//
//
//        //headers: ["Content-Type":"application/json", "Accept":"application/json"] 값을 지정하면 오류 발생
//        Alamofire.request(url,
//                          method: .post,
//                          parameters: param,
//                          encoding: URLEncoding.default
//            )
//            .validate(statusCode: 200..<300)
//            .responseJSON {
//                response in
//
//                switch response.result {
//                case .success:
//                    if let responseData = response.result.value {
//
//                        NotificationCenter.default.post(
//                            name: Notification.Name(rawValue: notificationName),
//                            object: nil,
//                            userInfo: ["result": "success", "directionModel" : self.getDirectionModel(responseData: responseData)])
//
//
//                    } else {
//                        //TODO: 오류를 좀더 구체적으로 처리하세요
//                        NotificationCenter.default.post(
//                            name: Notification.Name(rawValue: notificationName),
//                            object: nil,
//                            userInfo: ["result": "fail"])
//
//                    }
//                    print("Validation Successful")
//                case .failure(let error):
//                    //TODO: 오류를 좀더 구체적으로 처리하세요
//                    //TODO 나중에 제대로 작동하는지 확인하세요
//                    if(error.localizedDescription.contains("forbidden")) {
//                        NotificationCenter.default.post(
//                            name: Notification.Name(rawValue: notificationName),
//                            object: nil,
//                            userInfo: ["result": "overApi"])
//                    } else {
//
//                        NotificationCenter.default.post(
//                            name: Notification.Name(rawValue: notificationName),
//                            object: nil,
//                            userInfo: ["result": "fail"])
//                    }
//
//                    print(error)
//                }
//
//
//        }
//
//
//    }
    
    private func getDirectionModel(responseData:Any) -> DirectionModel {
        let swiftyJsonVar = JSON(responseData)
        
        let directionModel:DirectionModel = DirectionModel()
        
        let routePointModels:[RoutePointModel] = convertToRoutePointModels(json: swiftyJsonVar)
        let nonDuplicateroutePointModels:[RoutePointModel] = DataUtils.getNonDuplicateRoutePointModels(routePointModels: routePointModels)
        directionModel.setRoutePointModels(routePointModels: nonDuplicateroutePointModels)
        directionModel.setGeofenceModels(geofenceModels: convertToGeofenceModel(routePointModels: routePointModels))
        directionModel.setTotalTime(totalTime: swiftyJsonVar["features"][0]["properties"]["totalTime"].intValue)
        directionModel.setTotalDistance(totalDistance: swiftyJsonVar["features"][0]["properties"]["totalDistance"].intValue)
        
        return directionModel
    }
    
    private func convertToGeofenceModel(routePointModels:[RoutePointModel]) -> [GeofenceModel]{
        var geofenceModels:[GeofenceModel] = [GeofenceModel]()
        
        var geofenceModel: GeofenceModel
        for routePointModel in routePointModels {
            if (routePointModel.getType() == Mn4pConstants.TYPE_POINT) {
                geofenceModel = GeofenceModel()
                geofenceModel.setLat(lat: routePointModel.getLat() ?? 0)
                geofenceModel.setLng(lng: routePointModel.getLng() ?? 0)
                geofenceModel.setDescription(description: routePointModel.getDescription() ?? "")
                geofenceModels.append(geofenceModel)
            }
        }
        
        return geofenceModels
        
    }
    
    private func convertToRoutePointModels(json:JSON) -> [RoutePointModel]{
        var routePointModels:[RoutePointModel] = [RoutePointModel]()
        var routePointModel:RoutePointModel
        
        var isFirstIndexPassed:Bool = false
        
        for subJson in json["features"].arrayValue {
            
            if(isFirstIndexPassed && subJson["properties"]["index"].intValue == 0) {
                break
            }
            
            if(subJson["properties"]["index"].intValue == 0) {
                isFirstIndexPassed = true;
            }
            
            if (subJson["geometry"]["type"].stringValue == "Point") {
                routePointModel = RoutePointModel()
                
                routePointModel.setLat(lat: subJson["geometry"]["coordinates"][1].doubleValue);
                routePointModel.setLng(lng: subJson["geometry"]["coordinates"][0].doubleValue);
                routePointModel.setRoadNo(roadNo: 0); //0:자전거 도로 없음
                routePointModel.setDescription(description: self.convertToKindDescription(description: subJson["properties"]["description"].stringValue));
                routePointModel.setType(type: Mn4pConstants.TYPE_POINT);
                routePointModels.append(routePointModel);
                
            } else {
                
                for coordinates in subJson["geometry"]["coordinates"].arrayValue {
                    routePointModel = RoutePointModel()
                    
                    routePointModel.setLat(lat: coordinates[1].doubleValue);
                    routePointModel.setLng(lng: coordinates[0].doubleValue);
                    routePointModel.setRoadNo(roadNo: subJson["properties"]["roadType"].intValue); //0:자전거 도로 없음
                    routePointModel.setDescription(description: self.convertToKindDescription(description: subJson["properties"]["description"].stringValue));
                    routePointModel.setType(type: Mn4pConstants.TYPE_LINE);
                    routePointModels.append(routePointModel);
                    
                }
            }
            
        }
        return routePointModels
    }
    
    private func convertToKindDescription(description:String) -> String{
        //TODO 영어 처리하세요 
        if (description.contains("도착")) {
            return "잠시후 목적지에 도착합니다";
        } else {
            return description + "하세요";
        }
    }
    
}

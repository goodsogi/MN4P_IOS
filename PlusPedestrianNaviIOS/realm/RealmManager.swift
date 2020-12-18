//
//  RealmManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 26/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import RealmSwift

class RealmManager {
//swift에서 singleton 사용하는 방법
//swift에서 앱 종료시 singleton 객체에 nil을 할당할 필요는 없는 듯
static let sharedInstance = RealmManager()
private init() {}
let realm = try! Realm()

    //Swift에서 nil을 리턴할 수 없음
    //이 메소드의 반환값으로 Results<Object>가 아니라 Results<PlaceVO>로 지정해야 함
   
    
   
    
    /**
     즐겨찾기
     */  
    
    public func isPlaceAddedToFavorites(placeModel: PlaceModel) -> Bool{
       
        let latitude = placeModel.getLatitude() ?? 0
        let longitude = placeModel.getLongitude() ?? 0
        
        let results = try! Realm().objects(FavoriteVO.self).filter("latitude = %@ AND longitude = %@", latitude, longitude)
        print("plusapps isPlaceAddedToFavorites  results.count \( results.count)")
        
        return results.count != 0
    }
    
    public func addPlaceToFavorites(placeModel: PlaceModel) {
              
        if (isPlaceAddedToFavorites(placeModel: placeModel)) {
            deletePlaceOnFavorites(placeModel:placeModel);
        }

        savePlaceToFavorites(placeModel:placeModel);
       
    }
    
    public func savePlaceToFavorites(placeModel: PlaceModel) {
        print("plusapps savePlaceToFavorites")
        let favoriteVO = FavoriteVO()
        
        favoriteVO.name = placeModel.getName()
        favoriteVO.bizName = placeModel.getBizName()
        favoriteVO.latitude = placeModel.getLatitude() ?? 0
        favoriteVO.longitude = placeModel.getLongitude() ?? 0
        favoriteVO.address = placeModel.getAddress()
        favoriteVO.telNo = placeModel.getTelNo()
        
        do {
            try realm.write {
                realm.add(favoriteVO)
            }
        } catch {
            print("Error Add \(error)")
        }
    }
    
    
    public func deletePlaceOnFavorites(placeModel: PlaceModel) {
        print("plusapps deletePlaceOnFavorites")
        let latitude = placeModel.getLatitude() ?? 0
        let longitude = placeModel.getLongitude() ?? 0
        
        do {
            try realm.write {
                //아래처럼 삭제해야 함
                realm.delete( realm.objects(FavoriteVO.self).filter("latitude = %@ AND longitude = %@", latitude, longitude))
                //아래처럼 삭제하면 복사한 객체를 삭제하는 것이라 오류 발생한다고 함
                //"Can only delete an object from the Realm it belongs to"
                //realm.delete(favoriteVO)
            }
        } catch {
            print("Error Delete \(error)")
        }
    }
    
    public func getFavorites() -> Results<FavoriteVO> {
       let results = realm.objects(FavoriteVO.self)
  
       return results
       }
        
       
    
    public func convertFavoritesVOToPlaceModels(results: Results<FavoriteVO>) -> [PlaceModel]{
        var array = [PlaceModel] ()
        for result in results {
         let placeModel = PlaceModel()
            placeModel.setName(name: result.name ?? "")
            placeModel.setBizname(bizName: result.bizName ?? "")
            placeModel.setLatitude(latitude: result.latitude)
            placeModel.setLongitude(longitude: result.longitude)
            placeModel.setTelNo(telNo: result.telNo ?? "")
            placeModel.setAddress(address: result.address ?? "")
            
            array.append(placeModel)
        }
        
        return array
        
    }
    
    
    public func deleteAllFavorites() {
      
        try! realm.write {
            realm.delete(realm.objects(FavoriteVO.self))
        }
    }
        
        
        
        
    public func hasFavorites() -> Bool{
       let results = realm.objects(PlaceVO.self)
        return results.count != 0
    }
    
    
    /**
     장소검색
     */
    
    public func deletePlaceOnSearchPlaceHistory(placeModel: PlaceModel) {
        
        let latitude = placeModel.getLatitude() ?? 0
        let longitude = placeModel.getLongitude() ?? 0
   
        
        do {
            try realm.write {
                realm.delete(realm.objects(FavoriteVO.self).filter("latitude = %@ AND longitude = %@", latitude, longitude))
            }
        } catch {
            print("Error Delete \(error)")
        }
        
    }
    
    public func addPlaceToSearchHistory(placeModel: PlaceModel) {
              
        if (isPlaceAddedToSearchPlaceHistory(placeModel:placeModel)) {
            deletePlaceOnSearchPlaceHistory(placeModel:placeModel);
        }

        savePlaceToSearchHistory(placeModel:placeModel);
       
    }
    
    
    public func savePlaceToSearchHistory(placeModel: PlaceModel) {
        let placeVO = PlaceVO()
        
        placeVO.name = placeModel.getName()
        placeVO.bizName = placeModel.getBizName()
        placeVO.latitude = placeModel.getLatitude() ?? 0
        placeVO.longitude = placeModel.getLongitude() ?? 0
        placeVO.address = placeModel.getAddress()
        placeVO.telNo = placeModel.getTelNo()
        
        do {
            try realm.write {
                realm.add(placeVO)
            }
        } catch {
            print("Error Add \(error)")
        }
    }
        
        
    
    public func isPlaceAddedToSearchPlaceHistory(placeModel: PlaceModel) -> Bool{
       
        let latitude = placeModel.getLatitude() ?? 0
        let longitude = placeModel.getLongitude() ?? 0
        
        let results = try! Realm().objects(PlaceVO.self).filter("latitude = %@ AND longitude = %@", latitude, longitude)
        return results.count != 0
    }
        
    
    public func getSearchPlaceHistory() -> Results<PlaceVO>{
       let results = realm.objects(PlaceVO.self)
       return results
       }
        
       
    
    public func convertPlaceVOToPlaceModels(results: Results<PlaceVO>) -> [PlaceModel]{
        var array = [PlaceModel] ()
        for result in results {
         let placeModel = PlaceModel()
            placeModel.setName(name: result.name ?? "")
            placeModel.setBizname(bizName: result.bizName ?? "")
            placeModel.setLatitude(latitude: result.latitude)
            placeModel.setLongitude(longitude: result.longitude)
            placeModel.setTelNo(telNo: result.telNo ?? "")
            placeModel.setAddress(address: result.address ?? "")
            
            array.append(placeModel)
        }
        
        return array
        
    }
    
    
    public func deleteAllSearchPlaceHistory() {
     
        try! realm.write {
            realm.delete(realm.objects(PlaceVO.self))
        }
    }
    
    public func deleteAll() {
    
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    /*
     경로 히스토리
     */
    
    public func addDirectionToDirectionHistory() {
              
        if (isDirectionAddedToDirectionHistory() {
            deleteDirecectionOnDirectionHistory()
        }

        saveDirectionToDB()
       
    }
    
    public func deleteDirecectionOnDirectionHistory() {
        
        let startPointLatitude = Mn4pSharedDataStore.startPointModel!.getLatitude() ?? 0
        let startPointLongitude = Mn4pSharedDataStore.startPointModel!.getLongitude() ?? 0
        let destinationLatitude = Mn4pSharedDataStore.destinationModel!.getLatitude() ?? 0
        let destinationLongitude = Mn4pSharedDataStore.destinationModel!.getLongitude() ?? 0
        
   
        
        do {
            try realm.write {
                realm.delete(realm.objects(DirectionVO.self).filter("startPointLatitude = %@ AND startPointLongitude = %@ AND destinationLatitude = %@ AND destinationLongitude = %@", startPointLatitude, startPointLongitude, destinationLatitude, destinationLongitude))
            }
        } catch {
            print("Error Delete \(error)")
        }
        
    }
    public func isDirectionAddedToDirectionHistory() -> Bool{
       
        let startPointLatitude = Mn4pSharedDataStore.startPointModel!.getLatitude() ?? 0
        let startPointLongitude = Mn4pSharedDataStore.startPointModel!.getLongitude() ?? 0
        let destinationLatitude = Mn4pSharedDataStore.destinationModel!.getLatitude() ?? 0
        let destinationLongitude = Mn4pSharedDataStore.destinationModel!.getLongitude() ?? 0
        
        let results = try! Realm().objects(DirectionVO.self).filter("startPointLatitude = %@ AND startPointLongitude = %@ AND destinationLatitude = %@ AND destinationLongitude = %@", startPointLatitude, startPointLongitude, destinationLatitude, destinationLongitude)
        return results.count != 0
    }
    
    
    
    public func saveDirectionToDB(directionModel: DirectionModel) {
        let directionVO = DirectionVO()
        
     
        //TODO 장소 이름이 "Your location"인 경우 처리하세요
        
        directionVO.startPointName = Mn4pSharedDataStore.startPointModel!.getName() ?? ""
        directionVO.startPointBizName = Mn4pSharedDataStore.startPointModel!.getBizName() ?? ""
        directionVO.startPointLatitude =  Mn4pSharedDataStore.startPointModel!.getLatitude() ?? 0
        directionVO.startPointLongitude = Mn4pSharedDataStore.startPointModel!.getLongitude() ?? 0
        directionVO.startPointAddress = Mn4pSharedDataStore.startPointModel!.getAddress() ?? ""
        directionVO.startPointTelNo = Mn4pSharedDataStore.startPointModel!.getTelNo() ?? ""
        directionVO.destinationName = Mn4pSharedDataStore.destinationModel!.getName() ?? ""
        directionVO.destinationBizName = Mn4pSharedDataStore.destinationModel!.getBizName() ?? ""
        directionVO.destinationLatitude =  Mn4pSharedDataStore.destinationModel!.getLatitude() ?? 0
        directionVO.destinationLongitude = Mn4pSharedDataStore.destinationModel!.getLongitude() ?? 0
        directionVO.destinationAddress = Mn4pSharedDataStore.destinationModel!.getAddress() ?? ""
        directionVO.destinationTelNo = Mn4pSharedDataStore.destinationModel!.getTelNo() ?? ""
        
        
        directionVO.geofenceString = GeofenceModelToStringConverter.convert(geofenceModels: Mn4pSharedDataStore.directionModel.getGeofenceList())
        directionVO.routePointString = RoutePointModelToStringConverter.convert(pointModels: Mn4pSharedDataStore.directionModel?.getRoutePointModels())       
        
        do {
            try realm.write {
                realm.add(directionVO)
            }
        } catch {
            print("Error Add \(error)")
        }
    }
        
}

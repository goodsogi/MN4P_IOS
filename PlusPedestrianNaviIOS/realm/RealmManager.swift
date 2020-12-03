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
static let sharedInstance = RealmManager()
private init() {}
let realm = try! Realm()

    //Swift에서 nil을 리턴할 수 없음
    //이 메소드의 반환값으로 Results<Object>가 아니라 Results<PlaceModelForRealm>로 지정해야 함 
    public func getSearchPlaceHistory() -> Results<PlaceModelForRealm>{
       let results = try! Realm().objects(PlaceModelForRealm.self)
       return results
    }
    
    public func hasFavorites() -> Bool{
       let results = try! Realm().objects(PlaceModelForRealm.self)
        return results.count != 0
    }
}

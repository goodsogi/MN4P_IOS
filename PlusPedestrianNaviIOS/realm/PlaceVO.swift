//
//  PlaceModelForRealm.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 26/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import Foundation
import RealmSwift

class PlaceVO: Object {
    //Realm애서 Double?, Int? 타입은 지정 못하는 듯 
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var name: String? = nil
    @objc dynamic var address: String? = nil
    @objc dynamic var telNo: String? = nil
    @objc dynamic var bizName: String? = nil
    @objc dynamic var distance: Int = 0
}

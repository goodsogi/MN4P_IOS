//
//  SearchPlaceModel.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 3..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation

class PlaceModel {
    
    private var latitude: Double? = nil
    private var longitude: Double? = nil
    private var name: String? = nil
    private var address: String? = nil
    private var telNo: String? = nil
    private var bizName: String? = nil
    private var distance: Int? = nil
    private var accuracy: Double? = nil
    
    func setAccuracy(accuracy:Double) {
        self.accuracy = accuracy
    }
    
    func getAccuracy() -> Double? {
        return self.accuracy
    }
    
    func setLatitude(latitude:Double) {
        self.latitude = latitude
    }
    
    func setLongitude(longitude:Double) {
        self.longitude = longitude
    }
    
    func setName(name:String) {
        self.name = name
    }
    
    func setAddress(address:String) {
        self.address = address
    }
    
    func setBizname(bizName:String) {
        self.bizName = bizName
    }
    
    func setDistance(distance:Int) {
        self.distance = distance
    }
    
    func setTelNo(telNo:String) {
        self.telNo = telNo
    }
    
    
    func getLatitude() -> Double? {
        return self.latitude
    }
    
    func getLongitude() -> Double? {
        return self.longitude
    }
    
    func getName() -> String? {
        return self.name
    }
    
    func getTelNo() -> String? {
        return self.telNo
    }
    
    func getBizName() -> String? {
        return self.bizName
    }
    
    
    func getAddress() -> String? {
        return self.address
    }
    
    func getDistance() -> Int? {
        return self.distance
    }
    
}


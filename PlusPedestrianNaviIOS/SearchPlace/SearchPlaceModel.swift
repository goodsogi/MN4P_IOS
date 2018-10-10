//
//  SearchPlaceModel.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 3..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation

class SearchPlaceModel {
    
    private var lat: Double? = nil
    private var lng: Double? = nil
    private var name: String? = nil
    private var address: String? = nil
    private var telNo: String? = nil
    private var bizName: String? = nil
    private var distance: Int? = nil
    
    func setLat(lat:Double) {
        self.lat = lat
    }
    
    func setLng(lng:Double) {
        self.lng = lng
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
    
    
    func getLat() -> Double? {
        return self.lat
    }
    
    func getLng() -> Double? {
        return self.lng
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


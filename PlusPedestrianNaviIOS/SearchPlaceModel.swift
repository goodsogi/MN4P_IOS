//
//  SearchPlaceModel.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 3..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation

class SearchPlaceModel {
    var lat: Double? = nil
    var lng: Double? = nil
    var name: String? = nil
    var address: String? = nil
    var telNo: String? = nil
    var bizName: String? = nil
    var distance: Int? = nil
    
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
    
}


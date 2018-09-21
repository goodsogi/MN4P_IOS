//
//  RoutePointModel.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 10..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation

class RoutePointModel {
    private var lat: Double? = nil
    private var lng: Double? = nil
    private var description: String? = nil
    private var roadNo: Int? = nil
    private var type: Int? = nil
    
    func setLat(lat:Double) {
        self.lat = lat
    }
    
    func setLng(lng:Double) {
        self.lng = lng
    }
    
    func setDescription(description:String) {
        self.description = description
    }
    
    func setRoadNo(roadNo:Int) {
        self.roadNo = roadNo
    }
    
    func setType(type:Int) {
        self.type = type
    }
    
    
    func getLat() -> Double? {
        return self.lat
    }
    
    func getLng() -> Double? {
        return self.lng
    }
    
    func getDescription() -> String? {
        return self.description
    }
    
    func getRoadNo() -> Int? {
        return self.roadNo
    }
    
   
    func getType() -> Int? {
        return self.type
    }
    
    
    
}

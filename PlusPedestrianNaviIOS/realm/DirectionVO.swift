//
//  DirectionVO.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/18.
//  Copyright © 2020 박정규. All rights reserved.
//

import Foundation
import RealmSwift

class DirectionVO: Object {
    //Realm애서 Double?, Int? 타입은 지정 못하는 듯
    @objc dynamic var startPointLatitude: Double = 0.0
    @objc dynamic var startPointLongitude: Double = 0.0
    @objc dynamic var startPointName: String? = nil
    @objc dynamic var startPointAddress: String? = nil
    @objc dynamic var startPointTelNo: String? = nil
    @objc dynamic var destinationBizName: String? = nil
    @objc dynamic var destinationLatitude: Double = 0.0
    @objc dynamic var destinationLongitude: Double = 0.0
    @objc dynamic var destinationName: String? = nil
    @objc dynamic var destinationAddress: String? = nil
    @objc dynamic var destinationTelNo: String? = nil
    @objc dynamic var startPointBizName: String? = nil
    @objc dynamic var geofenceString: String? = nil
    @objc dynamic var routePointString: String? = nil
    @objc dynamic var wayPointString: String? = nil
    @objc dynamic var totalTime: Int = 0
    @objc dynamic var totalDistance: Int = 0
   
}

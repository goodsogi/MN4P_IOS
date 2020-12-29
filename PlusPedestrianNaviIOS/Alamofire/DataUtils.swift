//
//  DataUtils.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/29.
//  Copyright © 2020 박정규. All rights reserved.
//

import Foundation

class DataUtils {
    public static func getNonDuplicateRoutePointModels(routePointModels: [RoutePointModel]) -> [RoutePointModel]{
        //동일한 값 제거
        var uniqueRoutePointModels: [RoutePointModel] = [RoutePointModel]()

        var previousLat: Double = 0
        var previousLng: Double = 0

        for routePointModel in routePointModels {
            if(routePointModel.getLat() == previousLat && routePointModel.getLng() == previousLng) {
                continue;
            }

            uniqueRoutePointModels.append(routePointModel)
            previousLat = routePointModel.getLat() ?? 0
            previousLng = routePointModel.getLng() ?? 0
        }

        return uniqueRoutePointModels;
    }
}

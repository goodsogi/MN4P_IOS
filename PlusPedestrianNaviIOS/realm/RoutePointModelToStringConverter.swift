//
//  GeofenceModelToStringConverter.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/18.
//  Copyright © 2020 박정규. All rights reserved.
//

import Foundation

class RoutePointModelToStringConverter {
    private static let SPLITTER : String =  "|"
    private static let SUB_SPLITTER : String =  ","
    public static func convert(pointModels: [RoutePointModel]) -> String {
        
        var result : String? = ""
        var index : Int = 0
        for pointModel in pointModels {
            result?.append( String(format: "%f", pointModel.getLat() ?? 0))
            result?.append(SUB_SPLITTER)
            result?.append( String(format: "%f", pointModel.getLng() ?? 0))
            result?.append(SUB_SPLITTER)
            result?.append( geofenceModel.getDescription() ?? "")
            
            if (index < geofenceModels.count) {
                result?.append(SPLITTER)
            }
            index += 1
        }
        
        return result ?? ""
    }
}

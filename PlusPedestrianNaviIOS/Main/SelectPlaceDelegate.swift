//
//  SelectPlaceDelegate.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 28/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

//: class라고 선언해야 다른 곳에서 weak 사용 가능
// 선언하지 않으면 오류 발생 
protocol SelectPlaceDelegate : class {
    func onPlaceSelected(placeModel: PlaceModel, searchType: Int)
}

//
//  ViewElevationMaker.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 21..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import UIKit

//view elevation(안드로이드의 view elevation) 생성 
class ViewElevationMaker {
    
    static func run(view: UIView) {
        //Double 변수 선언은 아래처럼 함. var대신 let사용 권장. let은 상수로 한번 지정하면 변경 불가
        let elevation: Double = 2.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: elevation)
        view.layer.shadowOpacity = 0.24
        view.layer.shadowRadius = CGFloat(elevation)
    }
}

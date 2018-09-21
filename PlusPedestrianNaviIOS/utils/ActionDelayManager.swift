//
//  ActionDelayManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 21..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation

class ActionDelayManager {
    static func run(seconds: Double, completion:@escaping ()->()) {
        let when = DispatchTime.now() + seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            completion()
        }
    }
}

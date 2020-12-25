//
//  SOTWFormatter.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/25.
//  Copyright © 2020 박정규. All rights reserved.
//

import Foundation


class SOTWFormatter {
    
    let sides: [Int] = [0,  90,  180,  270,  360]
    let names: [String]
    
    
    static let sharedInstance = SOTWFormatter()
    
    private init() {
        names = [LanguageManager.getString(key: "twelve_oclock"),
                 LanguageManager.getString(key: "three_oclock"),
                 LanguageManager.getString(key: "six_oclock"),
                 LanguageManager.getString(key: "nine_oclock"),
                 LanguageManager.getString(key: "twelve_oclock")]
    }
    
    public func format(azimuth: Int) -> String {
        let index = findClosestIndex(target: azimuth)
           return names[index]
       }
    
    private func findClosestIndex(target: Int) -> Int {
        var i: Int = 0
        var j: Int = sides.count
        var mid: Int = 0
        
                while (i < j) {
                    mid = (i + j) / 2;

                    /* If target is less than array element,
                       then search in left */
                    if (target < sides[mid]) {

                        // If target is greater than previous
                        // to mid, return closest of two
                        if (mid > 0 && target > sides[mid - 1]) {
                            return getClosest(index1: mid - 1,  index2: mid,target: target);
                        }

                        /* Repeat for left half */
                        j = mid;
                    } else {
                        if (mid < sides.count - 1 && target < sides[mid + 1]) {
                            return getClosest(index1: mid,  index2: mid + 1, target: target);
                        }
                        i = mid + 1; // update i
                    }
                }

                // Only single element left after search
                return mid;
    }
    
    private func getClosest(index1: Int, index2: Int, target: Int) -> Int {
            if (target - sides[index1] >= sides[index2] - target) {
                return index2
            }
            return index1
        }
    
}

//
//  SpinnerView.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 3..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit

//로딩바 관리 
@IBDesignable
class SpinnerView : UIView {
   
    static var spinner: UIView?
    
    //class func과 static func이 거의 비슷함
        class func show(onView : UIView) {
            let spinnerView = UIView.init(frame: onView.bounds)
            spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
            ai.startAnimating()
            ai.center = spinnerView.center
            
            DispatchQueue.main.async {
                spinnerView.addSubview(ai)
                onView.addSubview(spinnerView)
            }
            
            self.spinner = spinnerView
        }
        
        class func remove() {
            
            guard let spinnerView = self.spinner else {
                return
            }
            
            DispatchQueue.main.async {
                spinnerView.removeFromSuperview()
            }
        }
}

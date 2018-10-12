//
//  OverApiManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 12..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit

class OverApiManager {
    
    public static func showOverApiAlertPopup(parentViewControler : UIViewController) {
        let modalViewController = parentViewControler.storyboard?.instantiateViewController(withIdentifier: "OverApiAlertPopup")
        modalViewController!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalViewController!.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        parentViewControler.present(modalViewController!, animated: true, completion: nil)
    }
    
}

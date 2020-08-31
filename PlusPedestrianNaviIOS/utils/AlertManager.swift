//
//  AlertManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 27/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class AlertManager {
    public func showAlert(parentViewControler : UIViewController ,message: String) {
        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let successButton = UIAlertAction(title: "확인", style: .default) { (action) in print("확인")
        }
        
        alertController.addAction(successButton)
        parentViewControler.present(alertController, animated: true, completion: nil)
    }
}


//
//  OverApiAlertModalViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 4..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit

//Tmap api 초과 경고팝업
class OfflineAlertPopupViewController: UIViewController {
    
    
    @IBOutlet weak var popup: UIView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        
        drawOfflineAlertPopupBackground()
        drawConfirmButtonBackground()
    }
    
    private func drawOfflineAlertPopupBackground() {
        let width = self.view.frame.width - 32
        let img = ImageMaker.getRoundRectangle(width: width, height: 120, colorHexString: "#FFFFFF", cornerRadius: 6.0, alpha: 1)
        
        popup.backgroundColor = UIColor(patternImage: img)
    }
    
    private func drawConfirmButtonBackground() {
        let img = ImageMaker.getRoundRectangle(width: 82, height: 36, colorHexString: "#0858B3", cornerRadius: 3.0, alpha: 1)
        
        confirmButton.backgroundColor = UIColor(patternImage: img)
    }
    
    @IBAction func onConfirmButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

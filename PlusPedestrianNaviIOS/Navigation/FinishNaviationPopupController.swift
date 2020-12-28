//
//  OverApiAlertModalViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 4..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit

//Tmap api 초과 경고팝업
class FinishNavigationPopupController: UIViewController {
    
    
    @IBOutlet weak var popup: UIView!
    
    var finishNavigationPopupDelegate: FinishNavigationPopupDelegate?
   
    override func viewDidLoad() {
        
        drawPopupBackground()
       
    }
    
    private func drawPopupBackground() {
        let width = self.view.frame.width - 32
        let img = ImageMaker.getRoundRectangle(width: width, height: 170, colorHexString: "#FFFFFF", cornerRadius: 6.0, alpha: 1)
        
        popup.backgroundColor = UIColor(patternImage: img)
    }
    
 
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func onOkButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        finishNavigationPopupDelegate?.onFinishNavigationConfirmed()
        
    }
    
}

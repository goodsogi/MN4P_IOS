//
//  MainPanel.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 29/07/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import Panels
import UIKit

class MainPanel: UIViewController, Panelable {
   
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerPanel: UIView!
    
    @IBOutlet weak var handle: UIImageView!
    
   
    override func viewDidLoad() {
           super.viewDidLoad()
        makeLayout()
    }
    
    func makeLayout() {
        let handleBackgroundImg = ImageMaker.getRoundRectangle(width: 46, height: 6, colorHexString: "#69696d", cornerRadius: 3.0, alpha: 1)
        
        handle.backgroundColor = UIColor(patternImage: handleBackgroundImg)
        
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
       
        let headerPanelBackgroundImg = ImageMaker.getRoundRectangleByCorners(width: screenWidth, height: 320, colorHexString: "#333536", byRoundingCorners: [UIRectCorner.topLeft , UIRectCorner.topRight], cornerRadii: 10.0, alpha: 1)
              
              headerPanel.backgroundColor = UIColor(patternImage: headerPanelBackgroundImg)
    }
}

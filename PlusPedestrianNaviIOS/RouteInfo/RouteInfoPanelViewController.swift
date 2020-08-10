//
//  RouteInfoPanelViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 10/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class RouteInfoPanelViewController: UIViewController {
@IBOutlet var goButton: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         makeLayout()
    }
    
     private func makeLayout() {
                      
            let goButtonBackgroundImg = ImageMaker.getRoundRectangle(width:81, height: 81, colorHexString: "#228B22", cornerRadius: 10.0, alpha: 1.0)
            
            goButton.backgroundColor = UIColor(patternImage: goButtonBackgroundImg)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

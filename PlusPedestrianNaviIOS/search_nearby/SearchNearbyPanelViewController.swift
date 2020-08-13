//
//  SearchNearbyPanelViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 12/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class SearchNearbyPanelViewController: UIViewController {
@IBOutlet var closeButton: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         makeLayout()
    }
    

     private func makeLayout() {
              let closeButtonBackgroundImg = ImageMaker.getCircle(width: 37, height: 37, colorHexString: "#444447", alpha: 1.0)
              closeButton.backgroundColor = UIColor(patternImage: closeButtonBackgroundImg)
    }

}

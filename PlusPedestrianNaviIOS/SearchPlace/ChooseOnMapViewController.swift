//
//  ChooseOnMapViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 12/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class ChooseOnMapViewController: UIViewController {
@IBOutlet var findCurrentLocationButton: UIView!
@IBOutlet var goBackButton: UIView!
@IBOutlet var confirmButton: UIView!

@IBOutlet weak var goBackButtonWidthConstraint: NSLayoutConstraint!
@IBOutlet weak var confirmButtonWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeLayout()
    }
    

   private func makeLayout() {
    let findCurrentLocationButtonBackgroundImg = ImageMaker.getCircle(width: 60, height: 60, colorHexString: "#ffffff", alpha: 1.0)
           findCurrentLocationButton.backgroundColor = UIColor(patternImage: findCurrentLocationButtonBackgroundImg)
    
    
    let screenWidth = UIScreen.main.bounds.width
    let buttonWidth = (screenWidth - 1) / 2
    
    goBackButtonWidthConstraint?.constant = buttonWidth
    confirmButtonWidthConstraint?.constant = buttonWidth
    
    }
}

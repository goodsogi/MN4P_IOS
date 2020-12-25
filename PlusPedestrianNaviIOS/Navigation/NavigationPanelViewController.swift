//
//  NavigationPanelViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 11/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class NavigationPanelViewController: UIViewController {

    var selectScreenDelegate:SelectScreenDelegate?
    
    @IBOutlet var showOverviewButton: UIView!
    @IBOutlet var showStreetViewButton: UIView!
    @IBOutlet var finishNavigationButton: UIView!
    
    
    @IBOutlet weak var arrivalTimeTextWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var remainingTimeTextWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var remainingDistanceTextWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var showOverviewButtonLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showStreetViewButtonLeadingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var remainingTime: UITextField!
    
    @IBOutlet weak var remainingDistance: UITextField!
    
    @IBOutlet weak var remainingDistanceUnit: UITextField!
    
    @IBOutlet weak var arrivalTime: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         makeLayout()
    }
    
    private func makeLayout() {
           let circleButtonBackgroundImg = ImageMaker.getCircle(width: 102, height: 102, colorHexString: "#c2c2c2", alpha: 1.0)
           showOverviewButton.backgroundColor = UIColor(patternImage: circleButtonBackgroundImg)
        
        showStreetViewButton.backgroundColor = UIColor(patternImage: circleButtonBackgroundImg)
        
        let finishNavigationButtonBackgroundImg = ImageMaker.getRoundRectangle(width: 90, height: 70, colorHexString: "#cd1039", cornerRadius: 10.0, alpha: 1.0)
                       finishNavigationButton.backgroundColor = UIColor(patternImage: finishNavigationButtonBackgroundImg)
        
        
        
        let screenWidth = UIScreen.main.bounds.width
               
        let textWidth = (screenWidth - (20 + 44 + 44 + 20 + 90 + 18))/3
                   
        
        arrivalTimeTextWidthConstraint?.constant = textWidth
        remainingTimeTextWidthConstraint?.constant = textWidth
        remainingDistanceTextWidthConstraint?.constant = textWidth
        
        let buttonIntervalWidth = (screenWidth - (102 + 102))/3
        showOverviewButtonLeadingConstraint?.constant = buttonIntervalWidth
        showStreetViewButtonLeadingConstraint?.constant = buttonIntervalWidth
    }
    
    func showRemainingDistance(formattedRemainingDistance: String, distanceUnit: String, contentDescription: String) {
        remainingDistance.text = formattedRemainingDistance
            remainingDistanceUnit.text = distanceUnit
        
        remainingDistance.accessibilityLabel = contentDescription
    }
    
    func showRemainingTime(remainingTimeString: String,  contentDescription: String) {
        remainingTime.text = remainingTimeString
         
        remainingTime.accessibilityLabel = contentDescription
    }
    
    func showArrivalTime(arrivalTimeString: String,  contentDescription: String) {
        arrivalTime.text = arrivalTimeString
         
        arrivalTime.accessibilityLabel = contentDescription
    }
}

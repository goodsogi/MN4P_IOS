//
//  MainPanelViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 06/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class MainPanelViewController: UIViewController {

    @IBOutlet var mainPanelView: UIView!
    
    @IBOutlet weak var searchBar: UIView!
    
    
    @IBOutlet weak var homeButton: UIView!
    
    @IBOutlet weak var workButton: UIView!
    
    
    @IBOutlet weak var myFavoritesButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeLayout()
    }
    
    private func makeLayout() {
        
        let screenWidth = UIScreen.main.bounds.width
        let searchBarBackgroundImg = ImageMaker.getRoundRectangle(width: screenWidth - 36, height: 45, colorHexString: "#424447", cornerRadius: 6.0, alpha: 1.0)
        
        searchBar.backgroundColor = UIColor(patternImage: searchBarBackgroundImg)
        
        let homeButtonBackgroundImg = ImageMaker.getCircle(width: 76, height: 76, colorHexString: "#4e5051", alpha: 1.0)
        homeButton.backgroundColor = UIColor(patternImage: homeButtonBackgroundImg)
        
        
        let workButtonBackgroundImg = ImageMaker.getCircle(width: 76, height: 76, colorHexString: "#4e5051", alpha: 1.0)
        workButton.backgroundColor = UIColor(patternImage: workButtonBackgroundImg)
        
        
        let myFavoritesButtonBackgroundImg = ImageMaker.getCircle(width: 76, height: 76, colorHexString: "#4e5051", alpha: 1.0)
        myFavoritesButton.backgroundColor = UIColor(patternImage: myFavoritesButtonBackgroundImg)
        
    }


}

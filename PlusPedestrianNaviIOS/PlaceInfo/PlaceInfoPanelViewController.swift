//
//  PlaceInfoPanelViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 10/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class PlaceInfoPanelViewController: UIViewController {

    @IBOutlet var closeButton: UIView!
     @IBOutlet var addToFavoritesButton: UIView!
     @IBOutlet var callButton: UIView!
     @IBOutlet var shareButton: UIView!
    @IBOutlet var findRouteButton: UIView!
    
    @IBOutlet weak var addToFavoriteButtonWidthConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var callButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shareButtonWidthConstaint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         makeLayout()
    }
    
    private func makeLayout() {
           let closeButtonBackgroundImg = ImageMaker.getCircle(width: 37, height: 37, colorHexString: "#444447", alpha: 1.0)
           closeButton.backgroundColor = UIColor(patternImage: closeButtonBackgroundImg)
        
        let screenWidth = UIScreen.main.bounds.width
        
                 let findRouteButtonBackgroundImg = ImageMaker.getRoundRectangle(width: screenWidth - 38, height: 66, colorHexString: "#0078ff", cornerRadius: 10.0, alpha: 1.0)
                 findRouteButton.backgroundColor = UIColor(patternImage: findRouteButtonBackgroundImg)
        
        //TODO 수정하세요
        let buttonWidth = (screenWidth - (19*4))/3
                   let buttonBackgroundImg = ImageMaker.getRoundRectangle(width: buttonWidth, height: 66, colorHexString: "#4b4d4f", cornerRadius: 10.0, alpha: 1.0) 
        
        addToFavoriteButtonWidthConstaint?.constant = buttonWidth
        callButtonWidthConstraint?.constant = buttonWidth
        shareButtonWidthConstaint?.constant = buttonWidth
        
         addToFavoritesButton.backgroundColor = UIColor(patternImage: buttonBackgroundImg)
         callButton.backgroundColor = UIColor(patternImage: buttonBackgroundImg)
         shareButton.backgroundColor = UIColor(patternImage: buttonBackgroundImg)
        
        //TODO  AddToFavorite icon 구현하세요
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

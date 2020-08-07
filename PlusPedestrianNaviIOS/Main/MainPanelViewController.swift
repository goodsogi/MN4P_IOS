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
    
    
    @IBOutlet var restaurantButton: UIView!
    @IBOutlet var cafeButton: UIView!
    @IBOutlet var convenienceStoreButton: UIView!
    @IBOutlet var bankButton: UIView!
    @IBOutlet var pharmacyButton: UIView!
    @IBOutlet var hotelButton: UIView!
    @IBOutlet var subwayButton: UIView!
    @IBOutlet var busStopButton: UIView!
    @IBOutlet var martButton: UIView!
    
    @IBOutlet var restaurantIconContainer: UIView!
    @IBOutlet var cafeIconContainer: UIView!
    @IBOutlet var convenienceStoreIconContainer: UIView!
    @IBOutlet var bankIconContainer: UIView!
    @IBOutlet var pharmacyIconContainer: UIView!
    @IBOutlet var hotelIconContainer: UIView!
    @IBOutlet var subwayIconContainer: UIView!
    @IBOutlet var busStopIconContainer: UIView!
    @IBOutlet var martIconContainer: UIView!
    
    
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
        
        let restaurantIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#4285f4", alpha: 1.0)
               restaurantIconContainer.backgroundColor = UIColor(patternImage: restaurantIconContainerBackgroundImg)
        
     
        let cafeIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#ea4335", alpha: 1.0)
        cafeIconContainer.backgroundColor = UIColor(patternImage: cafeIconContainerBackgroundImg)
        
        let convenienceStoreIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#fbbc04", alpha: 1.0)
        convenienceStoreIconContainer.backgroundColor = UIColor(patternImage: convenienceStoreIconContainerBackgroundImg)
        
        let bankIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#34a853", alpha: 1.0)
        bankIconContainer.backgroundColor = UIColor(patternImage: bankIconContainerBackgroundImg)
        
        let pharmacyIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#f538a0", alpha: 1.0)
        pharmacyIconContainer.backgroundColor = UIColor(patternImage: pharmacyIconContainerBackgroundImg)
        
        let hotelIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#fa7b17", alpha: 1.0)
        hotelIconContainer.backgroundColor = UIColor(patternImage: hotelIconContainerBackgroundImg)
        
        let subwayIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#fa7b17", alpha: 1.0)
        subwayIconContainer.backgroundColor = UIColor(patternImage: subwayIconContainerBackgroundImg)
        
        let busStopIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#34a853", alpha: 1.0)
        busStopIconContainer.backgroundColor = UIColor(patternImage: busStopIconContainerBackgroundImg)
        
        let martIconContainerBackgroundImg = ImageMaker.getCircle(width: 48, height: 48, colorHexString: "#ea4335", alpha: 1.0)
        martIconContainer.backgroundColor = UIColor(patternImage: martIconContainerBackgroundImg)
        
        
    }


}

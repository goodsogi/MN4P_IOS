//
//  MainPanelViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 06/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class MainPanelViewController: UIViewController {
    var selectScreenDelegate:SelectScreenDelegate?
    @IBOutlet var mainPanelView: UIView!
    
    @IBOutlet weak var searchBar: UIView!
    
    
    @IBOutlet weak var homeButton: UIView!
    
    @IBOutlet weak var workButton: UIView!
    
    @IBOutlet weak var homeIcon: UIImageView!
    
    @IBOutlet weak var workIcon: UIImageView!
    
    @IBOutlet weak var myFavoritesButton: UIView!
    
    @IBOutlet weak var myFavoriteIcon: UIImageView!
    
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
    
    weak var selectPlaceDelegate: SelectPlaceDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        makeLayout()
        addTapListenerToButtons()
    }
    
    private func makeLayout() {
        
        let screenWidth = UIScreen.main.bounds.width
        let searchBarBackgroundImg = ImageMaker.getRoundRectangle(width: screenWidth - 36, height: 45, colorHexString: "#424447", cornerRadius: 6.0, alpha: 1.0)
        
        searchBar.backgroundColor = UIColor(patternImage: searchBarBackgroundImg)
        
        let homeButtonBackgroundImg = ImageMaker.getCircle(width: 76, height: 76, colorHexString: "#4e5051", alpha: 1.0)
        homeButton.backgroundColor = UIColor(patternImage: homeButtonBackgroundImg)
        
        let isHomeSet: Bool = UserDefaultManager.isHomeSet()
        
        if (isHomeSet) {
            homeIcon.image = UIImage(named:"home_set")
        } else {
            homeIcon.image = UIImage(named:"home_not_set")
        }             
        
        
        let workButtonBackgroundImg = ImageMaker.getCircle(width: 76, height: 76, colorHexString: "#4e5051", alpha: 1.0)
        workButton.backgroundColor = UIColor(patternImage: workButtonBackgroundImg)
        
        let isWorkSet: Bool = UserDefaultManager.isWorkSet()
        
        if (isWorkSet) {
            workIcon.image = UIImage(named:"work_set")
        } else {
            workIcon.image = UIImage(named:"work_not_set")
        }
        
        let myFavoritesButtonBackgroundImg = ImageMaker.getCircle(width: 76, height: 76, colorHexString: "#4e5051", alpha: 1.0)
        myFavoritesButton.backgroundColor = UIColor(patternImage: myFavoritesButtonBackgroundImg)
        
        let hasFavorites: Bool = RealmManager.sharedInstance.hasFavorites()
        
        if (hasFavorites) {
            myFavoriteIcon.image = UIImage(named:"favorites")
        } else {
            myFavoriteIcon.image = UIImage(named:"no_favorites")
        }
        
        
        
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
    
    private func addTapListenerToButtons() {
        let searchBarTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onSearchBarTapped(_:)))
        searchBarTapGesture.numberOfTapsRequired = 1
        searchBarTapGesture.numberOfTouchesRequired = 1
        searchBar.addGestureRecognizer(searchBarTapGesture)
        searchBar.isUserInteractionEnabled = true
        
        
        let homeButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onHomeButtonTapped(_:)))
        homeButtonTapGesture.numberOfTapsRequired = 1
        homeButtonTapGesture.numberOfTouchesRequired = 1
        homeButton.addGestureRecognizer(homeButtonTapGesture)
        homeButton.isUserInteractionEnabled = true
        
        
        let workButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onWorkButtonTapped(_:)))
        workButtonTapGesture.numberOfTapsRequired = 1
        workButtonTapGesture.numberOfTouchesRequired = 1
        workButton.addGestureRecognizer(workButtonTapGesture)
        workButton.isUserInteractionEnabled = true
        
        
        let myFavoritesButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onMyFavoritesButtonTapped(_:)))
        myFavoritesButtonTapGesture.numberOfTapsRequired = 1
        myFavoritesButtonTapGesture.numberOfTouchesRequired = 1
        myFavoritesButton.addGestureRecognizer(myFavoritesButtonTapGesture)
        myFavoritesButton.isUserInteractionEnabled = true
    }
    @objc func onSearchBarTapped(_ sender: UITapGestureRecognizer) {
        Mn4pSharedDataStore.searchType = SearchPlaceViewController.PLACE
        showScreenOnOtherStoryboard(storyboardName: "SearchPlace", viewControllerStoryboardId: "search_place")
    }
    
    @objc func onHomeButtonTapped(_ sender: UITapGestureRecognizer) {
        let isHomeSet: Bool = UserDefaultManager.isHomeSet()
        
        if (isHomeSet) {
            let placeModel: PlaceModel = UserDefaultManager.getHomeModel()
            Mn4pSharedDataStore.placeModel = placeModel
            selectScreenDelegate?.showRouteInfoScreen()
        } else {
            UserDefaultManager.saveIsFromSettingFragment(value: false)
            Mn4pSharedDataStore.searchType = SearchPlaceViewController.HOME
            showScreenOnOtherStoryboard(storyboardName: "SearchPlace", viewControllerStoryboardId: "search_place")
        }
    }
    
    @objc func onWorkButtonTapped(_ sender: UITapGestureRecognizer) {
        let isWorkSet: Bool = UserDefaultManager.isWorkSet()
        
        if (isWorkSet) {
            let placeModel: PlaceModel = UserDefaultManager.getWorkModel()
            Mn4pSharedDataStore.placeModel = placeModel
            selectScreenDelegate?.showRouteInfoScreen()
        } else {
            UserDefaultManager.saveIsFromSettingFragment(value: false)
            Mn4pSharedDataStore.searchType = SearchPlaceViewController.WORK
            showScreenOnOtherStoryboard(storyboardName: "SearchPlace", viewControllerStoryboardId: "search_place")
        }
    }
    
    @objc func onMyFavoritesButtonTapped(_ sender: UITapGestureRecognizer) {
        let hasFavorites: Bool = RealmManager.sharedInstance.hasFavorites()
        
        if (hasFavorites) {
            showScreenOnOtherStoryboard(storyboardName: "Favorites", viewControllerStoryboardId: "favorites")
        }
    }
    
    private func showScreenOnOtherStoryboard(storyboardName:String, viewControllerStoryboardId:String) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId)
        
        if(viewControllerStoryboardId == "search_place") {
            (viewController as! SearchPlaceViewController).selectPlaceDelegate  = selectPlaceDelegate
             }
        
        self.present(viewController, animated: true, completion: nil)
        
    }
}

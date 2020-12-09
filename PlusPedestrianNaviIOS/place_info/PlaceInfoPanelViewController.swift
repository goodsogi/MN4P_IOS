//
//  PlaceInfoPanelViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 10/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class PlaceInfoPanelViewController: UIViewController {
    
    var selectScreenDelegate:SelectScreenDelegate?
    var selectedPlaceModel:PlaceModel?
    @IBOutlet var closeButton: UIView!
     @IBOutlet var addToFavoritesButton: UIView!
     @IBOutlet var callButton: UIView!
     @IBOutlet var shareButton: UIView!
    @IBOutlet var findRouteButton: UIView!
    
    @IBOutlet weak var addToFavoriteButtonWidthConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var callButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shareButtonWidthConstaint: NSLayoutConstraint!
    
    
    @IBOutlet weak var placeName: UITextField!
    
    @IBOutlet weak var placeDetail: UITextField!
    
    @IBOutlet weak var address: UITextField!
    
    @IBOutlet weak var phone: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeLayout()
        fillOutContent()
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
    
    private func fillOutContent() {
        placeName.text = selectedPlaceModel?.getName()
     
        let placeDetailString : String = getPlaceDetailString()
        placeDetail.text = placeDetailString
        address.text = selectedPlaceModel?.getAddress()
        phone.text = selectedPlaceModel?.getTelNo()
        
        
    }
    
    private func getPlaceDetailString() -> String{
        let bizName: String = selectedPlaceModel?.getBizName() ?? ""
        var distanceString: String = DistanceStringFormatter.getFormattedDistanceWithUnit(distance: selectedPlaceModel?.getDistance() ?? 0)
        
        if (distanceString == "0m") {
            distanceString = ""
        }
        
        var placeDetailString : String = bizName
        
        if (bizName == "" || distanceString == "") {
            
        } else {
            placeDetailString.append(" • ")
        }
        placeDetailString.append(distanceString)
        return placeDetailString
        
    }
    
    private func addTapListenerToButtons() {
        let closeButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onCloseButtonTapped(_:)))
        closeButtonTapGesture.numberOfTapsRequired = 1
        closeButtonTapGesture.numberOfTouchesRequired = 1
        closeButton.addGestureRecognizer(closeButtonTapGesture)
        closeButton.isUserInteractionEnabled = true
    }
    
    @IBAction func onCloseButtonTapped(_ sender: Any) {
        print("plusapps onCloseButtonTapped")
        selectScreenDelegate?.showMainScreen()
    }
   
    @IBAction func onFindRouteButtonClicked(_ sender: Any) {
        selectScreenDelegate?.showRouteInfoScreen()
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

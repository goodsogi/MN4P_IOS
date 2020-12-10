//
//  PlaceInfoPanelViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 10/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit
import Firebase
//import Firebase/DynamicLinks

class PlaceInfoPanelViewController: UIViewController {
    var toastDelegate:ToastDelegate?
    var selectScreenDelegate:SelectScreenDelegate?
    var selectedPlaceModel:PlaceModel?  
    @IBOutlet var closeButton: UIView!
     @IBOutlet var addToFavoritesButton: UIView!
     @IBOutlet var callButton: UIView!
     @IBOutlet var shareButton: UIView!
    @IBOutlet var findRouteButton: UIView!
    
    @IBOutlet weak var addToFavoritesIcon: UIImageView!
    
    @IBOutlet weak var addToFavoriteButtonWidthConstaint : NSLayoutConstraint!
    
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
        addTapListenerToButtons()
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
        
        let isAddedToFavorites: Bool = RealmManager.sharedInstance.isPlaceAddedToFavorites(placeModel: selectedPlaceModel!)
        
        addToFavoritesIcon.image = isAddedToFavorites ? UIImage(named: "added_to_favorites"): UIImage(named: "not_added_to_favorites")
        
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
        closeButtonTapGesture.cancelsTouchesInView = false
        closeButton.addGestureRecognizer(closeButtonTapGesture)
        closeButton.isUserInteractionEnabled = true
        
        
        let addToFavoritesButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onAddToFavoritesButtonTapped(_:)))
        addToFavoritesButtonTapGesture.numberOfTapsRequired = 1
        addToFavoritesButtonTapGesture.numberOfTouchesRequired = 1
        addToFavoritesButtonTapGesture.cancelsTouchesInView = false
        addToFavoritesButton.addGestureRecognizer(addToFavoritesButtonTapGesture)
        addToFavoritesButton.isUserInteractionEnabled = true
        
        
        let callButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onCallButtonTapped(_:)))
        callButtonTapGesture.numberOfTapsRequired = 1
        callButtonTapGesture.numberOfTouchesRequired = 1
        callButtonTapGesture.cancelsTouchesInView = false
        callButton.addGestureRecognizer(callButtonTapGesture)
        callButton.isUserInteractionEnabled = true
        
        
        
        let shareButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onShareButtonTapped(_:)))
        shareButtonTapGesture.numberOfTapsRequired = 1
        shareButtonTapGesture.numberOfTouchesRequired = 1
        shareButtonTapGesture.cancelsTouchesInView = false
        shareButton.addGestureRecognizer(shareButtonTapGesture)
        shareButton.isUserInteractionEnabled = true
        
    }
    
    @IBAction func onCloseButtonTapped(_ sender: Any) {
        print("plusapps onCloseButtonTapped")
        selectScreenDelegate?.showMainScreen()
    }
    
    @IBAction func onAddToFavoritesButtonTapped(_ sender: Any) {
        print("plusapps onAddToFavoritesButtonTapped")
        let isAddedToFavorites: Bool = RealmManager.sharedInstance.isPlaceAddedToFavorites(placeModel: selectedPlaceModel!)
        
        if (isAddedToFavorites) {
            RealmManager.sharedInstance.deletePlaceOnFavorites(placeModel: selectedPlaceModel!)
            addToFavoritesIcon.image =  UIImage(named: "not_added_to_favorites")
            toastDelegate?.showToast(message: "Deleted from favorites.")
            //Toast.show(message: "Deleted from favorites.", controller: self)
            
        } else {
            RealmManager.sharedInstance.savePlaceToFavorites(placeModel: selectedPlaceModel!)
            addToFavoritesIcon.image =  UIImage(named: "added_to_favorites")
            toastDelegate?.showToast(message: "Added to favorites.")
            //Toast.show(message: "Added to favorites.", controller: self)
        }
        
    }
    
    @IBAction func onCallButtonTapped(_ sender: Any) {
        guard let number = selectedPlaceModel?.getTelNo(), let url = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func onShareButtonTapped(_ sender: Any) {
        print("plusapps onCloseButtonTapped")
        
            let link = URL(string: "https://plusapps.com/?category=food&productId=10") // 모바일이 아니라 PC에서 클릭시 콜백 url 
            let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://pluspedestriannaviios.page.link")
                
            // iOS 설정
            referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.plusapps.PlusPedestrianNaviIOS")
            referralLink?.iOSParameters?.minimumAppVersion = "1.0.0"
            referralLink?.iOSParameters?.appStoreID = "1111111111"
            //referralLink?.iOSParameters?.customScheme = "커스텀 스키마가 설정되어 있을 경우 추가"
                
            // Android 설정
           referralLink?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.plusapps.pluspedestriannavi")
           referralLink?.androidParameters?.minimumVersion = 811
                
            // 단축 URL 생성
            referralLink?.shorten { (shortURL, warnings, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                    
                print(shortURL)
                //self.sendSMS(dynamicLink: shortURL)
            }
        
        
        //공유 팝업 띄움
//        var objectsToShare = [String]()
//        if let text = selectedPlaceModel?.getName() {
//                   objectsToShare.append(text)
//            objectsToShare.append(selectedPlaceModel?.getAddress() ?? "")
//            objectsToShare.append(selectedPlaceModel?.getBizName() ?? "")
//
//                   print("[INFO] textField's Text : ", text)
//               }
//
//               let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//               activityVC.popoverPresentationController?.sourceView = self.view
//
//               // 공유하기 기능 중 제외할 기능이 있을 때 사용
//       //        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
//               self.present(activityVC, animated: true, completion: nil)
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

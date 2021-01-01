//
//  SettingsViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 9..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import MessageUI

protocol ChooseMapPopupDelegate {
    func onMapChosen()
}

protocol ChooseVoicePopupDelegate {
    func onVoiceChosen()
}

class SettingsViewController: UIViewController , MFMailComposeViewControllerDelegate, ChooseMapPopupDelegate, ChooseVoicePopupDelegate {
   
   
    
    
    
    @IBOutlet weak var mapLabelContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chooseMapMenuHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var chooseMapMenu: UIView!
    
    @IBOutlet weak var mapName: UITextField!
    
    @IBOutlet weak var mapLabel: UIView!
   
    @IBOutlet weak var chooseVoiceMenu: UIView!
    
    @IBOutlet weak var chooseVoiceMenuHeightConstraint: NSLayoutConstraint!
  
    
    @IBOutlet weak var chooseTalkingSpeedMenu: UIView!
    
    
    @IBOutlet weak var voiceOption: UITextField!
    
    
    @IBOutlet weak var suggestionMenu: UIView!
    
    @IBOutlet weak var openSourceInfoMenu: UIView!
    
    @IBOutlet weak var appVersionMenu: UIView!
    
    @IBOutlet weak var appVersion: UITextField!
    
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true)    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToMenus()
        //showAppVersion()
        
        initChooseMapMenu()
        
        initChooseVoiceButton()
        
        initChooseTalkingSpeedButton()
    }
    
    
    private func initChooseVoiceButton() {
         
        
        chooseVoiceMenuHeightConstraint.constant = 57
        chooseVoiceMenu.isHidden = false
        showCurrentVoiceOption()
        addListenerToChooseVoiceButton()
        
        
//        
//        if (UserInfoManager.isLanguageKorean() != true) {
//            chooseVoiceMenuHeightConstraint.constant = 57
//            chooseVoiceMenu.isHidden = false
//            showCurrentVoiceOption()
//            addListenerToChooseVoiceButton()
//        }
   
        
    }
    
    private func initChooseTalkingSpeedButton() {
        showCurrentTalkingSpeedOption()
        addListenerToChooseTalkingSpeedButton()
       
    }
    
    private func showCurrentVoiceOption() {
        voiceOption.text = getCurrentVoiceOption()
    }
    
    private func getCurrentVoiceOption() -> String {
        let option: Int = UserDefaultManager.getCurrentVoiceOption()

               switch(option) {
               case Mn4pConstants.KAREN:
                    return "Karen"
               case Mn4pConstants.DANIEL:
                    return "Daniel"
               case Mn4pConstants.MOIRA:
                    return "Moira"
               case Mn4pConstants.SAMANTHA:
                    return "Samantha"
               default :
                return "Karen"
                 
               }
    }
    
    private func addListenerToChooseVoiceButton() {
        let chooseVoiceMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onChooseVoiceMenuTapped(_:)))
        chooseVoiceMenuTapGesture.numberOfTapsRequired = 1
        chooseVoiceMenuTapGesture.numberOfTouchesRequired = 1
        chooseVoiceMenu.addGestureRecognizer(chooseVoiceMenuTapGesture)
        chooseVoiceMenu.isUserInteractionEnabled = true
    }
    
    @objc func onChooseVoiceMenuTapped(_ sender: UITapGestureRecognizer) {
        showChooseVoicePopup()
    }
    
    func onVoiceChosen() {
       //TODO 구현하세요 
    }
    
    
    private func showChooseVoicePopup() {
        
        let storyboard = UIStoryboard(name: "AlertPopup", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "ChooseVoicePopup")
         
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        (modalViewController as! ChooseVoicePopupController).chooseVoicePopupDelegate  = self
         
        self.present(modalViewController, animated: true, completion: nil)
    }
    
    private func showCurrentTalkingSpeedOption() {
    }
    
    private func addListenerToChooseTalkingSpeedButton() {
    }
    
    private func initChooseMapMenu() {
        mapLabelContainerHeightConstraint.constant = 57
        chooseMapMenuHeightConstraint.constant = 57
        chooseMapMenu.isHidden = false
        mapLabel.isHidden = false
        showCurrentMapName()
        addListenerToChooseMapButton()
//        if (UserInfoManager.isUserInKorea() != true) {
//            mapLabelContainerHeightConstraint.constant = 57
//            chooseMapMenuHeightConstraint.constant = 57
//            chooseMapMenu.isHidden = false
//            mapLabel.isHidden = false
//            showCurrentMapName()
//            addListenerToChooseMapButton()
//        }
    //TODO 필요없으면 아래 코드 삭제하세요
//        else {
//            mapLabelContainerHeightConstraint.constant = 0
//            chooseMapMenuHeightConstraint.constant = 0
//        }
        
    }
    
    private func showCurrentMapName() {
        mapName.text = getCurrentMapName()
    }
    
    private func getCurrentMapName() -> String {
        let mapOption: Int = UserDefaultManager.getCurrentMapOption()

               switch(mapOption) {
                   case MapManager.GOOGLE_MAP:
                    return LanguageManager.getString(key: "google_map")
                   case MapManager.NAVER_MAP:
                    return LanguageManager.getString(key: "naver_map")
               default :
                   return LanguageManager.getString(key: "google_map")
                 
               }
    }
    
    private func addListenerToChooseMapButton() {
        let chooseMapMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onChooseMapMenuTapped(_:)))
        chooseMapMenuTapGesture.numberOfTapsRequired = 1
        chooseMapMenuTapGesture.numberOfTouchesRequired = 1
        chooseMapMenu.addGestureRecognizer(chooseMapMenuTapGesture)
        chooseMapMenu.isUserInteractionEnabled = true
    }
    
        @objc func onChooseMapMenuTapped(_ sender: UITapGestureRecognizer) {
            showChooseMapPopup()
        }
    
    private func showChooseMapPopup() {
        
        let storyboard = UIStoryboard(name: "AlertPopup", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "ChooseMapPopup")
         
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        (modalViewController as! ChooseMapPopupController).chooseMapPopupDelegate  = self
         
        self.present(modalViewController, animated: true, completion: nil)
    }
    
    func onMapChosen() {
        MapManager.sharedInstance.initMapClientAndRenderer()
        showCurrentMapName()
    }
        
    private func showAppVersion() {
        
        let appVersionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        appVersion.text = appVersionString
        
        
    }
    
    private func addTapGestureToMenus() {
        let suggestionMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.suggestionMenuTapped(_:)))
        suggestionMenuTapGesture.numberOfTapsRequired = 1
        suggestionMenuTapGesture.numberOfTouchesRequired = 1
        suggestionMenu.addGestureRecognizer(suggestionMenuTapGesture)
        suggestionMenu.isUserInteractionEnabled = true
        
        
        //        let openSourceInfoMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openSourceInfoMenuTapped(_:)))
        //        openSourceInfoMenuTapGesture.numberOfTapsRequired = 1
        //        openSourceInfoMenuTapGesture.numberOfTouchesRequired = 1
        //        openSourceInfoMenu.addGestureRecognizer(openSourceInfoMenuTapGesture)
        //        openSourceInfoMenu.isUserInteractionEnabled = true
        
        
        
    }
    
    
    
    //    @objc func openSourceInfoMenuTapped(_ sender: UITapGestureRecognizer) {
    //
    //        print("openSourceInfoMenuTapped")
    //
    //    }
    
    //********************************************************************************************************
    //
    // Gmail
    //
    //********************************************************************************************************
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc func suggestionMenuTapped(_ sender: UITapGestureRecognizer) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            Toast.show(message: "이 폰에서는 제안/문의를 사용할 수 없습니다.", controller: self)
            return
        }
        
        print("suggestionMenuTapped")
        //simulator에서는 작동하지 않고 실제 폰에서 작동한다고 함
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["goodsogi@gmail.com"])
        composeVC.setSubject("보행자용 지도, 네비게이션 제안/문의사항")
        composeVC.setMessageBody("제안이나 문의사항을 입력하세요.", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
}

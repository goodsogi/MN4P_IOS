//
//  SettingsViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 9..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController , MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var suggestionMenu: UIView!
    
    @IBOutlet weak var openSourceInfoMenu: UIView!
    
    @IBOutlet weak var appVersionMenu: UIView!
    
    @IBOutlet weak var appVersion: UITextField!
    
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true)    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToMenus()
        showAppVersion()
        
       
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

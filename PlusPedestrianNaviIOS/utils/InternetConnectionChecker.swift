//
//  InternetConnectionChecker.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 27/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import Reachability

class InternetConnectionChecker {
    //swift에서 singleton 사용하는 방법
    static let sharedInstance = InternetConnectionChecker()
    //Swift는 변수명과 메소드명이 같으면 오류 발생
    public var isOfflineBool: Bool = false
    var reachability: Reachability?
    
    private init() {      }
    
    
    deinit {
        stopNotifier()
    }
    
    public func run() {
        stopNotifier()
        setupReachability()
        startNotifier()
    }
    
    func setupReachability() {
        let reachability: Reachability?
        reachability = try? Reachability(hostname: "google.com")
        self.reachability = reachability
        
        reachability?.whenReachable = { reachability in
            self.isOfflineBool = false
        }
        reachability?.whenUnreachable = { reachability in
            self.isOfflineBool = true
        }
    }
        
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start\nnotifier")
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        reachability = nil
    }
    
    
    public func isOffline() -> Bool{
        return isOfflineBool
    }
    
    public func showOfflineAlertPopup(parentViewControler : UIViewController) {
        
        let storyboard = UIStoryboard(name: "AlertPopup", bundle: nil)
        let modalViewController = storyboard.instantiateViewController(withIdentifier: "offline_alert_popup")
        modalViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        parentViewControler.present(modalViewController, animated: true, completion: nil)
    }
    
}

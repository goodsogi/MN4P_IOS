//
//  SceneDelegate.swift
//  FirebaseDynamicLinkTest2
//
//  Created by Jeonggyu Park on 2020/12/15.
//

import UIKit
import Firebase
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //앱이 종료된 경우(폰에서 해당 앱을 swipe up) 동적 링크를 클릭시 콜백 함수가 호출되지 않는 이슈 수정
        for userActivity in connectionOptions.userActivities {
            if let incomingURL = userActivity.webpageURL{
                print("Incoming URL is \(incomingURL)")
                let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                    guard error == nil else{
                        print("Found an error \(error!.localizedDescription)")
                        return
                    }
                    if dynamicLink == dynamicLink{
                        self.handelIncomingDynamicLink(_dynamicLink: dynamicLink!)
                    }
                }
                print(linkHandled)
                break
            }
                }
        
       
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func handelIncomingDynamicLink(_dynamicLink: DynamicLink) {
        guard let url = _dynamicLink.url else {
            print("That is weird. my dynamic link object has no url")
            return
        }
        print("SceneDelegate your incoming link perameter is \(url.absoluteString)")
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {
            return
        }
        
        let placeModel : PlaceModel = PlaceModel()
       
        
        for queryItem in queryItems {
            print("Parameter:- \(queryItem.name) has a value:-  \(queryItem.value ?? "") ")
            if (queryItem.name == "name") {
                placeModel.setName(name: queryItem.value?.replacingOccurrences(of: "+", with: " ") ?? "")
            }
            if (queryItem.name == "latitude") {
                placeModel.setLatitude(latitude: Double(queryItem.value ?? "00") ?? 0)
            }
            if (queryItem.name == "longitude") {
                placeModel.setLongitude(longitude: Double(queryItem.value ?? "00") ?? 0)
            }
            if (queryItem.name == "address") {
                placeModel.setAddress(address: queryItem.value?.replacingOccurrences(of: "+", with: " ") ?? "")
            }
            if (queryItem.name == "bizName") {
                placeModel.setBizname(bizName: queryItem.value?.replacingOccurrences(of: "+", with: " ") ?? "")
            }
            if (queryItem.name == "telNo") {
                placeModel.setTelNo(telNo: queryItem.value?.replacingOccurrences(of: "+", with: " ") ?? "")
            }
        }
        
        
        _dynamicLink.matchType
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "clickFirebaseDynamicLink"), object: placeModel)
        
    }
    
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL{
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else{
                    print("Found an error \(error!.localizedDescription)")
                    return
                }
                if dynamicLink == dynamicLink{
                    self.handelIncomingDynamicLink(_dynamicLink: dynamicLink!)
                }
            }
            print(linkHandled)
        }
        
        
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url{
            print("url:-   \(url)")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
                 self.handelIncomingDynamicLink(_dynamicLink: dynamicLink)
                 //return true
            } else{
             // maybe handel Google and firebase
             print("False")
            }

        }
    }
}


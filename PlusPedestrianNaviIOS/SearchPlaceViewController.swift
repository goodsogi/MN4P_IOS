//
//  SearchPlaceViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 8. 31..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchPlaceViewController: UIViewController, UITextFieldDelegate {
    
    let TMAP_APP_KEY:String = "483c875f-2e12-4ecd-9bf5-f31508d5e5c9"; // 티맵 앱 key
    
    @IBOutlet weak var searchKeywordInput: UITextField!
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchKeywordInput.delegate = self
        searchKeywordInput.becomeFirstResponder()
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //여기에 키보드의 엔터키를 눌렀을 때 처리할 작업 명시
        
        //검색어가 nil일 경우 처리
        if let searchKeyword = searchKeywordInput.text {
            searchPlace(searchKeyword: searchKeyword)
        }
        return true
    }
    
    
    func searchPlace(searchKeyword:String) {
        // TODO: 로딩바 표시
        
        
        let url:String = "https://api2.sktelecom.com/tmap/pois"
        let param = ["version": "1", "appKey": TMAP_APP_KEY, "reqCoordType": "WGS84GEO","resCoordType": "WGS84GEO", "searchKeyword": searchKeyword]
        Alamofire.request(url,
                          method: .get,
                          parameters: param,
                          encoding: URLEncoding.default,
                          headers: ["Content-Type":"application/json", "Accept":"application/json"]
            )
            .validate(statusCode: 200..<300)
            .responseJSON {
                response in
               
                // TODO: 수정하세요
                let swiftyJsonVar = JSON(response.result.value!)
                for subJson in swiftyJsonVar["searchPoiInfo"]["pois"]["poi"].arrayValue {
                    
                    let name = subJson["name"].stringValue
                    print(name)
                }
                
        }
    }
    
    func parseJson(_ jsonData:NSDictionary) {
        
        
    }
    
    
}

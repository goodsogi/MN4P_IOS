//
//  SearchPlaceViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 8. 31..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import Alamofire

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
                //이미 deserialize되었으므로 JSONDecoder를 사용할 수 없음. 만약 사용하려면 Alamofire가 raw 데이터를 반환하게 설정을 변경해야 함
                if let JSON = response.result.value as? NSDictionary{
                    self.parseJson(JSON)
                }
        }
    }
    
    func parseJson(_ JSON:NSDictionary) {
        
        
//        var searchPlaceModel = [SearchPlaceModel]()
//        searchPlaceModel.append(SearchPlaceModel())
        
        guard let searchPoiInfo = JSON.object(forKey: "searchPoiInfo") as? NSDictionary else {
            return
        }
        
        guard let pois = searchPoiInfo.object(forKey: "pois") as? NSDictionary else {
            return
        }
        
        guard let poi = pois.object(forKey: "poi") as? NSDictionary else {
            return
        }
        
        
        do {
            
            try poi.forEach({ (<#(key: Any, value: Any)#>) in
                <#code#>
            })
        
        
    } catch {
        
        
    print("error when encoding or decoding=\(error)")
    }
        
        
        var searchPlaceModel:SearchPlaceModel = SearchPlaceModel()
        searchPlaceModel.setLat(
        
    }
    
    
}

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

class SearchPlaceViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let TMAP_APP_KEY:String = "c605ee67-a552-478c-af19-9675d1fc8ba3"; // 티맵 앱 key
    
    @IBOutlet weak var searchPlaceTable: UITableView!
    var searchPlaceModels = [SearchPlaceModel]()
    
    @IBOutlet weak var searchKeywordInput: UITextField!
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchPlaceTable.dequeueReusableCell(withIdentifier: "custom") as! SearchPlaceTableCell
        cell.name = searchPlaceModels[indexPath.row].getName()
    
    //스크롤을 해야 데이터가 전부 표시되는 이슈 발생
        cell.layoutSubviews()
    
    print("return cell position: " + String(indexPath.row)) 
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(searchPlaceModels.count)
        return searchPlaceModels.count
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchKeywordInput.delegate = self
        searchKeywordInput.becomeFirstResponder()
        
       
        searchPlaceTable.register(SearchPlaceTableCell.self, forCellReuseIdentifier: "custom")
        searchPlaceTable.delegate = self
        searchPlaceTable.dataSource = self
       
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
                if let responseData = response.result.value {
                    let swiftyJsonVar = JSON(responseData)
                    
//                    var searchPlaceModels = [SearchPlaceModel]()
                    
                    var searchPlaceModel:SearchPlaceModel
                    
                    for subJson in swiftyJsonVar["searchPoiInfo"]["pois"]["poi"].arrayValue {
                        searchPlaceModel = SearchPlaceModel()
                        
                        let name = subJson["name"].stringValue
                        let telNo = subJson["telNo"].stringValue
                        let upperAddrName = subJson["upperAddrName"].stringValue
                        let middleAddrName = subJson["middleAddrName"].stringValue
                        let roadName = subJson["roadName"].stringValue
                        let firstBuildNo = subJson["firstBuildNo"].stringValue
                        let secondBuildNo = subJson["secondBuildNo"].stringValue
                        let bizName = subJson["lowerBizName"].stringValue
                        let lat = subJson["noorLat"].doubleValue
                        let lng = subJson["noorLon"].doubleValue
                       
                        var address = upperAddrName + " " + middleAddrName + " " + roadName + " " + firstBuildNo
                        if secondBuildNo != "" {
                            address = address + "-" + secondBuildNo
                        }
                        
                        
                        searchPlaceModel.setName(name: name)
                        searchPlaceModel.setAddress(address: address)
                        searchPlaceModel.setLat(lat: lat)
                        searchPlaceModel.setLng(lng: lng)
                        searchPlaceModel.setBizname(bizName: bizName)
                        searchPlaceModel.setTelNo(telNo: telNo)
                       
                        self.searchPlaceModels.append(searchPlaceModel)
                        
                       
                    }
//                    self.searchPlaceTable.delegate = self
                    self.searchPlaceTable.reloadData()
                    
                   print(self.searchPlaceModels[0].getName())
                } else {
                    //TODO: 오류가 발생한 경우 처리하세요
                    
                }
                
        }
    }
    
    
    
}

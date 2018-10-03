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
    
    var delegate: MainViewControllerDelegate? 
    
    let TMAP_APP_KEY:String = "c605ee67-a552-478c-af19-9675d1fc8ba3"; // 티맵 앱 key
    
    @IBOutlet weak var searchPlaceTable: UITableView!
    var searchPlaceModels = [SearchPlaceModel]()
    
    @IBOutlet weak var searchKeywordInput: UITextField!
    
       
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchPlaceTable.dequeueReusableCell(withIdentifier: "custom") as! SearchPlaceTableCell
        cell.placeName = searchPlaceModels[indexPath.row].getName()
        cell.address = searchPlaceModels[indexPath.row].getAddress()
        cell.placeMarker = UIImage(named: "place_pin_gray.png")
        
        //스크롤을 해야 데이터가 전부 표시되는 이슈 발생
        cell.layoutSubviews()
        
        print("return cell position: " + String(indexPath.row))
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(searchPlaceModels.count)
        return searchPlaceModels.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let delegate = self.delegate {
            delegate.onPlaceSelected(placeModel: searchPlaceModels[indexPath.row])
        }
        self.dismiss(animated: true)
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchKeywordInput.delegate = self
        searchKeywordInput.becomeFirstResponder()
        
        
        searchPlaceTable.register(SearchPlaceTableCell.self, forCellReuseIdentifier: "custom")
        searchPlaceTable.delegate = self
        searchPlaceTable.dataSource = self
        searchPlaceTable.rowHeight = 60
        //estimatedRowHeight는 영향을 안 미침 
        //        searchPlaceTable.estimatedRowHeight = 60
        
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
        
        SpinnerView.show(onView: self.view)
        
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
                    
                    SpinnerView.remove()
                    
                    let swiftyJsonVar = JSON(responseData)
                    
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
                    
                    self.searchPlaceTable.reloadData()
                    
                    //이상한 검색어로 호출하면 아래에서 오류 발생(index out of range)
                    print(self.searchPlaceModels[0].getName() as Any)
                } else {
                    //TODO: 오류가 발생한 경우 처리하세요
                    SpinnerView.remove()
                }
                
        }
    }
    
    
    
}

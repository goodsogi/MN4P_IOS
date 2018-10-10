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
    
    //********************************************************************************************************
    //
    // 장소검색(Alamofire)
    //
    //********************************************************************************************************
    
    
    private func searchPlace(searchKeyword:String) {
        
        
        SpinnerView.show(onView: self.view)
        
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
                
                switch response.result {
                case .success:
                    if let responseData = response.result.value {
                        
                        SpinnerView.remove()
                        
                        self.extractSearchPlaceModels(responseData : responseData)
                        
                        self.searchPlaceTable.reloadData()
                        
                    } else {
                        
                        SpinnerView.remove()
                        
                        //TODO: 오류가 발생한 경우 처리하세요
                        
                    }
                    print("Validation Successful")
                case .failure(let error):
                    SpinnerView.remove()
                    
                    //TODO 나중에 제대로 작동하는지 확인하세요
                    if(error.localizedDescription.contains("forbidden")) {
                        self.showOverApiAlert()
                    }
                    
                    print(error)
                }
                
                
        }
    }
    
    private func extractSearchPlaceModels(responseData : Any) {
        
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
        
    }
    
    
    private func showOverApiAlert() {
        
        let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "OverApiAlertPopup")
        modalViewController!.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalViewController!.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        present(modalViewController!, animated: true, completion: nil)
        
    }
    
    
    //********************************************************************************************************
    //
    // TableView(안드로이드의 ListView)
    //
    //********************************************************************************************************
    
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
}





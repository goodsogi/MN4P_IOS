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
    
    @IBOutlet weak var searchPlaceTable: UITableView!
    var searchPlaceModels = [SearchPlaceModel]()
    @IBOutlet weak var searchKeywordInput: UITextField!
    
    //Alamofire
    var alamofireManager : AlamofireManager!
    
    
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
        initAlamofireManager()
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
    
    private func initAlamofireManager() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SearchPlaceViewController.receiveAlamofireSearchPlaceNotification(_:)),
                                               name: NSNotification.Name(rawValue: PPNConstants.NOTIFICATION_ALAMOFIRE_SEARCH_PLACE),
                                               object: nil)
        
        alamofireManager = AlamofireManager()
    }
    
    @objc func receiveAlamofireSearchPlaceNotification(_ notification: NSNotification) {
        if notification.name.rawValue == PPNConstants.NOTIFICATION_ALAMOFIRE_SEARCH_PLACE {
            
            SpinnerView.remove()
            
            
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:Any] else { return }
                
                let result : String = userInfo["result"] as! String
                
                switch result {
                case "success" :
                    
                   self.searchPlaceModels = userInfo["searchPlaceModels"] as! [SearchPlaceModel]
                 
                   self.searchPlaceTable.reloadData()
                    
                    break;
                case "overApi" :
                    
                    self.showOverApiAlert()
                    
                    break;
                    
                case "fail" :
                    //TODO: 필요시 구현하세요
                    
                    break;
                default:
                    
                    break;
                }
                
            }
        }
    }
    
    
    private func searchPlace(searchKeyword:String) {
        
        
        SpinnerView.show(onView: self.view)
        
        alamofireManager.searchPlace(searchKeyword : searchKeyword)
  
    }
   
    
    private func showOverApiAlert() {
        
        OverApiManager.showOverApiAlertPopup(parentViewControler: self)
        
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





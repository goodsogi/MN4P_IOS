//
//  PlaceTableManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 28/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import UIKit
import RealmSwift

class SearchPlaceHistoryTableManager:NSObject, UITableViewDelegate, UITableViewDataSource {
    
    weak var searchPlaceHistoryTable: UITableView!
     //Realm
       private var searchPlaceHistoryDatas: Results<PlaceModelForRealm>?
    weak var selectPlaceDelegate: SelectPlaceDelegate?
    var parentViewController: UIViewController!
    var searchType: Int!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return searchPlaceHistoryDatas?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchPlaceHistoryTable.dequeueReusableCell(withIdentifier: "searchPlaceHistoryTableCell") as! SearchPlaceHistoryTableCell
                   cell.placeName = searchPlaceHistoryDatas?[indexPath.row].name
                   cell.address = searchPlaceHistoryDatas?[indexPath.row].address
                   cell.clockIcon = UIImage(named: "clock.png")
                   //스크롤을 해야 데이터가 전부 표시되는 이슈 발생
                   cell.layoutSubviews()

                   //print("return cell position: " + String(indexPath.row))
                   return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO 수정하세요
//          if let delegate = self.selectPlaceDelegate {
//                    delegate.onPlaceSelected(placeModel: searchPlaceHistoryDatas?[indexPath.row], searchType: searchType ?? SearchPlaceViewController.PLACE)
//                }
//                parentViewController.dismiss(animated: true)
        
    }
    
    public func initialize(tableView:UITableView, parentViewController:UIViewController, searchType:Int?, selectPlaceDelegate:SelectPlaceDelegate?) {
        self.searchPlaceHistoryTable = tableView
        self.parentViewController = parentViewController
        self.searchType = searchType
        self.selectPlaceDelegate = selectPlaceDelegate
        
        
        searchPlaceHistoryTable.register(SearchPlaceHistoryTableCell.self, forCellReuseIdentifier: "searchPlaceHistoryTableCell")
        searchPlaceHistoryTable.delegate = self
        searchPlaceHistoryTable.dataSource = self
        searchPlaceHistoryTable.rowHeight = 60
        
        //hidden으로 지정하지 않았는데 TableView가 안보여서 isHidden을 false로 지정하니 보임
        //Swift 버그인가?
        searchPlaceHistoryTable.isHidden = false
        //estimatedRowHeight는 영향을 안 미침
        //        placeTable.estimatedRowHeight = 60
    }
    
    public func refreshTable(searchPlaceHistoryDatas: Results<PlaceModelForRealm>?) {
           self.searchPlaceHistoryDatas = searchPlaceHistoryDatas
            self.searchPlaceHistoryTable.reloadData()
       }
}

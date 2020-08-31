//
//  PlaceTableManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 28/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import UIKit

class PlaceTableManager:NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var placeTable: UITableView!
    var placeModels = [PlaceModel]()
    weak var selectPlaceDelegate: SelectPlaceDelegate?
    var parentViewController: UIViewController!
    var searchType: Int!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableView 데이터갯수 \(placeModels.count)")
        return placeModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("tableView cellForRowAt")
        let cell = placeTable.dequeueReusableCell(withIdentifier: "placeTableCell") as! PlaceTableCell
        cell.placeName = placeModels[indexPath.row].getName()
        cell.address = placeModels[indexPath.row].getAddress()
        cell.placeMarker = UIImage(named: "place_pin_gray.png")
        //Int?를 String으로 변환
        //String(... ?? 0)
        
        var formattedString: String = "";
        let distance:Int = placeModels[indexPath.row].getDistance() ?? 0
        if (distance != 0) {
            formattedString = DistanceStringFormatter.getFormattedDistanceWithUnit(distance: distance)
        }
        
        cell.distance = formattedString
        //스크롤을 해야 데이터가 전부 표시되는 이슈 발생
        cell.layoutSubviews()
        
        //print("return cell position: " + String(indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = self.selectPlaceDelegate {
            delegate.onPlaceSelected(placeModel: placeModels[indexPath.row], searchType: searchType ?? SearchPlaceViewController.PLACE)
        }
        parentViewController.dismiss(animated: true)
        
    }
    
    public func initialize(tableView:UITableView, parentViewController:UIViewController, searchType:Int?, selectPlaceDelegate:SelectPlaceDelegate?) {
        print("tableView PlaceTableManager initialize")
        self.placeTable = tableView
        self.parentViewController = parentViewController
        self.searchType = searchType
        self.selectPlaceDelegate = selectPlaceDelegate
        
        
        placeTable.register(PlaceTableCell.self, forCellReuseIdentifier: "placeTableCell")
        placeTable.delegate = self
        placeTable.dataSource = self
        placeTable.rowHeight = 60
        
        //hidden으로 지정하지 않았는데 TableView가 안보여서 isHidden을 false로 지정하니 보임
        //Swift 버그인가?
        placeTable.isHidden = false
        //estimatedRowHeight는 영향을 안 미침
        //        placeTable.estimatedRowHeight = 60
    }
    
    public func clearTable() {
        placeModels.removeAll()
               placeTable.reloadData()
    }
    
    public func sortTableByDistance() {
        self.placeModels.sort { $0.getDistance() ?? 0 < $1.getDistance() ?? 0 }
               self.placeTable.reloadData()
    }
    
    public func refreshTable(placeModels: [PlaceModel]) {
        print("tableView refreshTable")
        self.placeModels = placeModels
         self.placeTable.reloadData()
    }
}

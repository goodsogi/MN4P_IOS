//
//  PlaceTableViewDataSource.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 31/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit
import RealmSwift

class SearchPlaceTableViewDataSource: NSObject, UITableViewDataSource {
    //var data = Results<PlaceModelForRealm>()로 선언하면
    //Cannot invoke initializer for type 'Results' with no arguments
    //오류 발생
    //아래처럼 선언해야 함
    var searchPlaceHistoryData:Results<PlaceVO>? = nil
    var placeData = [PlaceModel]()
    weak var placeTable: UITableView?
       weak var searchPlaceHistoryTable: UITableView?
     
    
    init(placeTable:UITableView, searchPlaceHistoryTable:UITableView, placeData: [PlaceModel], searchPlaceHistoryData: Results<PlaceVO>?) {
        print("plusapps tableview data: ", searchPlaceHistoryData)
        self.placeTable = placeTable
              self.searchPlaceHistoryTable = searchPlaceHistoryTable
        self.searchPlaceHistoryData = searchPlaceHistoryData
        self.placeData = placeData
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if (tableView === placeTable) {
            print("plusapps tableview PlaceTableViewDataSource count: ", self.placeData.count)
                   return self.placeData.count
         } else {
        
        print("plusapps tableview SearchPlaceHistoryTableViewDataSource count: ", self.searchPlaceHistoryData?.count)
        return self.searchPlaceHistoryData?.count ?? 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if (tableView === placeTable) {
            print("tableview cellForRowAt: ", indexPath)
                 let cell = tableView.dequeueReusableCell(withIdentifier: "placeTableCell") as! PlaceTableCell
                  cell.placeName = placeData[indexPath.row].getName()
                  cell.address = placeData[indexPath.row].getAddress()
                  cell.placeMarker = UIImage(named: "place_pin_gray.png")
                  //Int?를 String으로 변환
                  //String(... ?? 0)
                  
                  var formattedString: String = "";
                  let distance:Int = placeData[indexPath.row].getDistance() ?? 0
                  if (distance != 0) {
                      formattedString = DistanceStringFormatter.getFormattedDistanceWithUnit(distance: distance)
                  }
                  
                  cell.distance = formattedString
                  //스크롤을 해야 데이터가 전부 표시되는 이슈 발생
                  cell.layoutSubviews()
                  
                  //print("return cell position: " + String(indexPath.row))
                  return cell
            
          } else {
         print("tableview cellForRowAt: ", indexPath)
       let cell = tableView.dequeueReusableCell(withIdentifier: "searchPlaceHistoryTableCell") as! SearchPlaceHistoryTableCell
                        
            let reversedIndex = (searchPlaceHistoryData?.count ?? 0) - 1 - indexPath.row
            cell.placeName = searchPlaceHistoryData?[reversedIndex].name
            cell.address = searchPlaceHistoryData?[reversedIndex].address
            
                        cell.clockIcon = UIImage(named: "clock.png")
                         //스크롤을 해야 데이터가 전부 표시되는 이슈 발생
                         cell.layoutSubviews()

                         //print("return cell position: " + String(indexPath.row))
                         return cell
        }
        
        return UITableViewCell()
    }
}

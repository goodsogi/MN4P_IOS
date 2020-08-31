//
//  SearchPlaceTableDelegate.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 31/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit

class SearchPlaceTableViewDelegate: NSObject, UITableViewDelegate {
     // #1
       weak var tapSearchPlaceHistoryTableViewDelegate: TapSearchPlaceHistoryTableViewDelegate?
       weak var tapPlaceTableViewDelegate: TapPlaceTableViewDelegate?
    weak var placeTable: UITableView?
    weak var searchPlaceHistoryTable: UITableView?
       // #2
    init(placeTable:UITableView, searchPlaceHistoryTable:UITableView, tapPlaceTableViewDelegate: TapPlaceTableViewDelegate ,tapSearchPlaceHistoryTableViewDelegate: TapSearchPlaceHistoryTableViewDelegate) {
           self.placeTable = placeTable
        self.searchPlaceHistoryTable = searchPlaceHistoryTable
        self.tapPlaceTableViewDelegate = tapPlaceTableViewDelegate
        self.tapSearchPlaceHistoryTableViewDelegate = tapSearchPlaceHistoryTableViewDelegate
       }
       
       // #3
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView === placeTable) {               self.tapPlaceTableViewDelegate?.onPlaceTableViewTapped(row: indexPath.row)
        } else {           self.tapSearchPlaceHistoryTableViewDelegate?.onSearchPlaceHistoryTableViewTapped(row: indexPath.row)
        }
       }
}


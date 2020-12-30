//
//  SetPointViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 12/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit
import RealmSwift

class SetPointViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    var directionHistoryData: Results<DirectionVO>? = nil
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.directionHistoryData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "directionHistoryTableCell") as! DirectionHistoryTableCell
                         
        let startPointName: String = directionHistoryData?[indexPath.row].startPointName ?? ""
        let destinationName: String = directionHistoryData?[indexPath.row].destinationName ?? ""
        let startPointAndDestinationName: String = startPointName + " --> " + destinationName
    
             cell.startPointAndDestinationName = startPointAndDestinationName
          
                  
                          cell.layoutSubviews()
                          return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Mn4pSharedDataStore.startPointModel = RealmManager.sharedInstance.getStartPointModelFromDirectionVO(directionVO: directionHistoryData![indexPath.row])
        Mn4pSharedDataStore.destinationModel = RealmManager.sharedInstance.getDestinationModelFromDirectionVO(directionVO: directionHistoryData![indexPath.row])
     
                   showPointNameAndIcon()
    }
    

    var setPointDelegate:SetPointDelegate?
    @IBOutlet weak var cancelButton: UITextField!
    
    @IBOutlet weak var findRouteButton: UITextField!
    
    @IBOutlet weak var swapButton: UIView!
    
    
    @IBOutlet weak var startPointMarker: UIImageView!
        
    @IBOutlet weak var startPointName: UITextField!
    
    @IBOutlet weak var destinationMarker: UIImageView!
    
    
    @IBOutlet weak var destinationName: UITextField!
    
    
    @IBOutlet weak var directionHistoryTable: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeLayout()
        addTapListenerToButtons()
        initDirectionHistoryTable()
        showPointNameAndIcon()
        makeDirectionHistoryList()
    }
    
    private func initDirectionHistoryTable() {
        //TableView의 dataSource는 2개 지정할 수 없는 듯
        //두 번째 지정하는 것이 첫 번째 지정한 것을 무효화하는 듯
        
        directionHistoryTable.register(DirectionHistoryTableCell.self, forCellReuseIdentifier: "directionHistoryTableCell")
        directionHistoryTable.delegate = self
        directionHistoryTable.dataSource = self
        directionHistoryTable.rowHeight = 60
        
        
        directionHistoryData = RealmManager.sharedInstance.getDirectionHistory()
        
        if (directionHistoryData?.count == 0) {
            return
        }
         
        directionHistoryTable.reloadData()
        
        
    }
    
    private func makeLayout() {
        
    }
    
    private func makeDirectionHistoryList() {
        
    }
    
    private func addTapListenerToButtons() {
        let cancelButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onCancelButtonTapped(_:)))
        cancelButtonTapGesture.numberOfTapsRequired = 1
        cancelButtonTapGesture.numberOfTouchesRequired = 1
        cancelButton.addGestureRecognizer(cancelButtonTapGesture)
        cancelButton.isUserInteractionEnabled = true
        
        let findRouteButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onFindRouteButtonTapped(_:)))
        findRouteButtonTapGesture.numberOfTapsRequired = 1
        findRouteButtonTapGesture.numberOfTouchesRequired = 1
        findRouteButton.addGestureRecognizer(findRouteButtonTapGesture)
        findRouteButton.isUserInteractionEnabled = true
        
        let swapButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onSwapButtonTapped(_:)))
        swapButtonTapGesture.numberOfTapsRequired = 1
        swapButtonTapGesture.numberOfTouchesRequired = 1
        swapButton.addGestureRecognizer(swapButtonTapGesture)
        swapButton.isUserInteractionEnabled = true
    }
    
    
    @objc func onCancelButtonTapped(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @objc func onFindRouteButtonTapped(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
        setPointDelegate?.onRoutePointSet()
    }
    
    @objc func onSwapButtonTapped(_ sender: UITapGestureRecognizer) {
        swapPlaceModels()
               showPointNameAndIcon()
    }
    
    
    private func swapPlaceModels() {
        let tempPlaceModel: PlaceModel = Mn4pSharedDataStore.startPointModel!
               Mn4pSharedDataStore.startPointModel = Mn4pSharedDataStore.destinationModel!
               Mn4pSharedDataStore.destinationModel = tempPlaceModel
    }
    
    private func showPointNameAndIcon() {
        startPointMarker.image = getPointMarkerBackground(placeModel: Mn4pSharedDataStore.startPointModel!)
        startPointName.text = Mn4pSharedDataStore.startPointModel!.getName()
        
        destinationMarker.image = getPointMarkerBackground(placeModel: Mn4pSharedDataStore.destinationModel!)
        destinationName.text = Mn4pSharedDataStore.destinationModel!.getName()
    }
    
    private func getPointMarkerBackground(placeModel: PlaceModel) -> UIImage? {
          
        
        if (placeModel.getName()!.contains(LanguageManager.getString(key: "your_location"))) {
                return UIImage(named: "your_location_blue")
            } else {
        return UIImage(named: "place_pin_red")
             
            }
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

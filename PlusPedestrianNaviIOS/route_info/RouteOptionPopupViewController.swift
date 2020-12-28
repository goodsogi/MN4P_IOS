//
//  RouteOptionPopupViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/18.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit


class RouteOptionPopupViewController: UIViewController {
    
    
    var routeOptionPopupDelegate:RouteOptionPopupDelegate?
    
    public let ROUTE_OPTION_RECOMMENDED: String = "0"
    public let ROUTE_OPTION_MAIN_STREET: String = "4"
    public let ROUTE_OPTION_MIN_DISTANCE: String = "10"
    public let ROUTE_OPTION_NO_STAIRS: String = "30"
    
    private var selectedOption : String?
    
    @IBOutlet weak var recommendedOption: UIView!
    
    @IBOutlet weak var mainStreetOption: UIView!
    
    @IBOutlet weak var minDistanceOption: UIView!
    
    @IBOutlet weak var noStairsOption: UIView!
    
    
    @IBOutlet weak var recommendedText: UILabel!
    
    @IBOutlet weak var recommendedCheck: UIImageView!
    
    @IBOutlet weak var mainStreetText: UILabel!
    
    @IBOutlet weak var mainStreetCheck: UIImageView!
    
    
    @IBOutlet weak var minDistanceText: UILabel!
    
    
    @IBOutlet weak var minDistancCheck: UIImageView!
    
    
    @IBOutlet weak var noStairsText: UILabel!
    
    
    @IBOutlet weak var noStairsCheck: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initOptions()
    }
    
    
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func onOkButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        saveSelectedRouteOption()
        routeOptionPopupDelegate?.onRouteOptionSelected()
        
        
    }
    
    private func saveSelectedRouteOption() {
        UserDefaultManager.saveRouteOption(routeOption: selectedOption!)
    }
    
    
    
    private func initOptions() {
        
        
        let recommendedOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onRecommendedOptionTapped(_:)))
        recommendedOptionTapGesture.numberOfTapsRequired = 1
        recommendedOptionTapGesture.numberOfTouchesRequired = 1
        recommendedOption.addGestureRecognizer(recommendedOptionTapGesture)
        recommendedOption.isUserInteractionEnabled = true
        
        
        
        
        let mainStreetOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onMainStreetOptionTapped(_:)))
        mainStreetOptionTapGesture.numberOfTapsRequired = 1
        mainStreetOptionTapGesture.numberOfTouchesRequired = 1
        mainStreetOption.addGestureRecognizer(mainStreetOptionTapGesture)
        mainStreetOption.isUserInteractionEnabled = true
        
        
        let minDistanceOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onMinDistanceOptionTapped(_:)))
        minDistanceOptionTapGesture.numberOfTapsRequired = 1
        minDistanceOptionTapGesture.numberOfTouchesRequired = 1
        minDistanceOption.addGestureRecognizer(minDistanceOptionTapGesture)
        minDistanceOption.isUserInteractionEnabled = true
        
        
        
        let noStairsOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onNoChairsOptionTapped(_:)))
        noStairsOptionTapGesture.numberOfTapsRequired = 1
        noStairsOptionTapGesture.numberOfTouchesRequired = 1
        noStairsOption.addGestureRecognizer(noStairsOptionTapGesture)
        noStairsOption.isUserInteractionEnabled = true
        
        
        
        let routeOption : String = UserDefaultManager.getRouteOption()
        
        selectOption(routeOption: routeOption)
        selectedOption = routeOption
        
    }
    
    private func isOptionAlreadySelected(routeOption: String) -> Bool {
        return routeOption == selectedOption
    }
    
    private func unselectPreviousSelectOption() {
        
        switch (selectedOption) {
        case ROUTE_OPTION_RECOMMENDED:
            toggleRecommendedOption(isSelected: false)
            break;
        case ROUTE_OPTION_MAIN_STREET:
            toggleMainstreetOption(isSelected: false)
            break;
        case ROUTE_OPTION_MIN_DISTANCE:
            toggleMinDistanceOption(isSelected: false)
            break;
        case ROUTE_OPTION_NO_STAIRS:
            toggleNoStairsOption(isSelected: false)
            break;
        default:
            toggleRecommendedOption(isSelected: false)
            break
        }
    }
    
    @IBAction func onRecommendedOptionTapped(_ sender: Any) {
        // != 만 사용가능 한듯
        if (isOptionAlreadySelected(routeOption: ROUTE_OPTION_RECOMMENDED) != true) {
            unselectPreviousSelectOption()
            toggleRecommendedOption(isSelected :true)
            selectedOption = ROUTE_OPTION_RECOMMENDED
        }
        
    }
    
    @IBAction func onMainStreetOptionTapped(_ sender: Any) {
        if (isOptionAlreadySelected(routeOption: ROUTE_OPTION_MAIN_STREET) != true) {
            unselectPreviousSelectOption()
            toggleMainstreetOption(isSelected :true)
            selectedOption = ROUTE_OPTION_MAIN_STREET
        }
        
    }
    
    @IBAction func onMinDistanceOptionTapped(_ sender: Any) {
        if (isOptionAlreadySelected(routeOption: ROUTE_OPTION_MIN_DISTANCE) != true) {
            unselectPreviousSelectOption()
            toggleMinDistanceOption(isSelected :true)
            selectedOption = ROUTE_OPTION_MIN_DISTANCE
        }
        
    }
    
    @IBAction func onNoChairsOptionTapped(_ sender: Any) {
        if (isOptionAlreadySelected(routeOption: ROUTE_OPTION_NO_STAIRS) != true) {
            unselectPreviousSelectOption()
            toggleNoStairsOption(isSelected :true)
            selectedOption = ROUTE_OPTION_NO_STAIRS
        }
        
    }
    
    
    
    
    
    
    private func selectOption(routeOption : String) {
        
        
        switch routeOption {
        case ROUTE_OPTION_RECOMMENDED:
            toggleRecommendedOption(isSelected: true)
            break
        case ROUTE_OPTION_MAIN_STREET:
            toggleMainstreetOption(isSelected: true)
            break
        case ROUTE_OPTION_MIN_DISTANCE:
            toggleMinDistanceOption(isSelected: true)
            break
        case ROUTE_OPTION_NO_STAIRS:
            toggleNoStairsOption(isSelected: true)
            break
        default:
            toggleRecommendedOption(isSelected: true)
            break
        }
        
        
    }
    
    
    private func toggleRecommendedOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        recommendedOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        recommendedText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        recommendedCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
    private func toggleMainstreetOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        mainStreetOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        mainStreetText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        mainStreetCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
    private func toggleMinDistanceOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        minDistanceOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        minDistanceText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        minDistancCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
    private func toggleNoStairsOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        noStairsOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        noStairsText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        noStairsCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
}


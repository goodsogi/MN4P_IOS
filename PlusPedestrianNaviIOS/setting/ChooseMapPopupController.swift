//
//  RouteOptionPopupViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/18.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit


class ChooseMapPopupController: UIViewController {
    
    
    var chooseMapPopupDelegate: ChooseMapPopupDelegate?
    
    private var selectedOption : Int?
    
    @IBOutlet weak var naverMapOption: UIView!
    
    @IBOutlet weak var googleMapOption: UIView!
    
  
    
    
    @IBOutlet weak var naverMapText: UILabel!
    
    @IBOutlet weak var naverMapCheck: UIImageView!
    
  
    
    
    @IBOutlet weak var googleMapText: UILabel!
    
    
    @IBOutlet weak var googleMapCheck: UIImageView!
    
    
    
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
        chooseMapPopupDelegate?.onMapChosen()
        
    }
    
    private func saveSelectedRouteOption() {
        UserDefaultManager.saveCurrentMapOption(mapOption: selectedOption!)
    }
    
    
    
    private func initOptions() {
        
        
        let naverMapOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onNaverMapOptionTapped(_:)))
        naverMapOptionTapGesture.numberOfTapsRequired = 1
        naverMapOptionTapGesture.numberOfTouchesRequired = 1
        naverMapOption.addGestureRecognizer(naverMapOptionTapGesture)
        naverMapOption.isUserInteractionEnabled = true
        
        
        
        
        let googleMapOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onGoogleMapOptionTapped(_:)))
        googleMapOptionTapGesture.numberOfTapsRequired = 1
        googleMapOptionTapGesture.numberOfTouchesRequired = 1
        googleMapOption.addGestureRecognizer(googleMapOptionTapGesture)
        googleMapOption.isUserInteractionEnabled = true
        
               
        
        
        let mapOption  = UserDefaultManager.getCurrentMapOption()
        
        selectOption(option: mapOption)
        selectedOption = mapOption
        
    }
    
    private func isOptionAlreadySelected(option: Int) -> Bool {
        return option == selectedOption
    }
    
    private func unselectPreviousSelectOption() {
        
        switch (selectedOption) {
        case MapManager.NAVER_MAP:
            toggleNaverMapOption(isSelected: false)
            break;
        case MapManager.GOOGLE_MAP:
            toggleGoogleMapOption(isSelected: false)
            break;
        default:
            toggleGoogleMapOption(isSelected: false)
            break
        }
    }
    
    @IBAction func onNaverMapOptionTapped(_ sender: Any) {
        // != 만 사용가능 한듯
        if (isOptionAlreadySelected(option: MapManager.NAVER_MAP) != true) {
            unselectPreviousSelectOption()
            toggleNaverMapOption(isSelected: true)
            selectedOption = MapManager.NAVER_MAP
        }
        
    }
    
    @IBAction func onGoogleMapOptionTapped(_ sender: Any) {
        if (isOptionAlreadySelected(option: MapManager.GOOGLE_MAP) != true) {
            unselectPreviousSelectOption()
            toggleGoogleMapOption(isSelected: true)
            selectedOption = MapManager.GOOGLE_MAP
        }
        
    }
    
    
    
    private func selectOption(option : Int) {
        
        
        switch option {
        case MapManager.NAVER_MAP:
            toggleNaverMapOption(isSelected: true)
            break
        case MapManager.GOOGLE_MAP:
            toggleGoogleMapOption(isSelected: true)
            break
        default:
            toggleGoogleMapOption(isSelected: true)
            break
        }
        
        
    }
    
    
    private func toggleNaverMapOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        naverMapOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        naverMapText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        naverMapCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
    private func toggleGoogleMapOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        googleMapOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        googleMapText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        googleMapCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
   
}


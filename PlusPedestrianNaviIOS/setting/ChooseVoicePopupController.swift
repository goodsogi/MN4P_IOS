//
//  RouteOptionPopupViewController.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/18.
//  Copyright © 2020 박정규. All rights reserved.
//

import UIKit


class ChooseVoicePopupController: UIViewController {
    
    
    var chooseVoicePopupDelegate: ChooseVoicePopupDelegate?
    
    private var selectedOption : Int?
    
      
  
    @IBOutlet weak var karenOption: UIView!
    
    @IBOutlet weak var karenText: UILabel!
    
    @IBOutlet weak var karenCheck: UIImageView!
    
      
    
    @IBOutlet weak var danielOption: UIView!
    
    @IBOutlet weak var danielText: UILabel!
    
    @IBOutlet weak var danielCheck: UIImageView!
    
    
    @IBOutlet weak var moiraOption: UIView!
    
    @IBOutlet weak var moiraText: UILabel!
    
    @IBOutlet weak var moiraCheck: UIImageView!
    
    
    @IBOutlet weak var samanthaOption: UIView!
    
    @IBOutlet weak var samanthaText: UILabel!
    
    @IBOutlet weak var samanthaCheck: UIImageView!
    
    
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
        saveSelectedVoiceOption()
        chooseVoicePopupDelegate?.onVoiceChosen()
        
    }
    
    private func saveSelectedVoiceOption() {
        UserDefaultManager.saveCurrentVoiceOption(option: selectedOption!)
    }
    
    
    
    private func initOptions() {
        
        
        let karenOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onKarenOptionTapped(_:)))
        karenOptionTapGesture.numberOfTapsRequired = 1
        karenOptionTapGesture.numberOfTouchesRequired = 1
        karenOption.addGestureRecognizer(karenOptionTapGesture)
        karenOption.isUserInteractionEnabled = true
        
        
        
        
        let danielOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onDanielOptionTapped(_:)))
        danielOptionTapGesture.numberOfTapsRequired = 1
        danielOptionTapGesture.numberOfTouchesRequired = 1
        danielOption.addGestureRecognizer(danielOptionTapGesture)
        danielOption.isUserInteractionEnabled = true
        
        
        let moiraOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onMoiraOptionTapped(_:)))
        moiraOptionTapGesture.numberOfTapsRequired = 1
        moiraOptionTapGesture.numberOfTouchesRequired = 1
        moiraOption.addGestureRecognizer(moiraOptionTapGesture)
        moiraOption.isUserInteractionEnabled = true
        
        
        let samanthaOptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onSamanthaOptionTapped(_:)))
        samanthaOptionTapGesture.numberOfTapsRequired = 1
        samanthaOptionTapGesture.numberOfTouchesRequired = 1
        samanthaOption.addGestureRecognizer(samanthaOptionTapGesture)
        samanthaOption.isUserInteractionEnabled = true
               
        
        
        let option  = UserDefaultManager.getCurrentVoiceOption()
        
        selectOption(option: option)
        selectedOption = option
        
    }
    
    private func isOptionAlreadySelected(option: Int) -> Bool {
        return option == selectedOption
    }
    
    private func unselectPreviousSelectOption() {
        
        switch (selectedOption) {
        case Mn4pConstants.KAREN:
            toggleKarenOption(isSelected: false)
            break;
        case Mn4pConstants.DANIEL:
            toggleDanielOption(isSelected: false)
            break;
        case Mn4pConstants.MOIRA:
            toggleMoiraOption(isSelected: false)
            break;
        case Mn4pConstants.SAMANTHA:
            toggleSamanthaOption(isSelected: false)
            break;
        default:
            toggleKarenOption(isSelected: false)
            break
        }
    }
    
    @IBAction func onKarenOptionTapped(_ sender: Any) {
        // != 만 사용가능 한듯
        if (isOptionAlreadySelected(option: Mn4pConstants.KAREN) != true) {
            unselectPreviousSelectOption()
            toggleKarenOption(isSelected: true)
            selectedOption = Mn4pConstants.KAREN
        }
        
    }
    
    @IBAction func onDanielOptionTapped(_ sender: Any) {
        // != 만 사용가능 한듯
        if (isOptionAlreadySelected(option: Mn4pConstants.DANIEL) != true) {
            unselectPreviousSelectOption()
            toggleDanielOption(isSelected: true)
            selectedOption = Mn4pConstants.DANIEL
        }
        
    }
    
    @IBAction func onMoiraOptionTapped(_ sender: Any) {
        // != 만 사용가능 한듯
        if (isOptionAlreadySelected(option: Mn4pConstants.MOIRA) != true) {
            unselectPreviousSelectOption()
            toggleMoiraOption(isSelected: true)
            selectedOption = Mn4pConstants.MOIRA
        }
        
    }
    
    @IBAction func onSamanthaOptionTapped(_ sender: Any) {
        // != 만 사용가능 한듯
        if (isOptionAlreadySelected(option: Mn4pConstants.SAMANTHA) != true) {
            unselectPreviousSelectOption()
            toggleSamanthaOption(isSelected: true)
            selectedOption = Mn4pConstants.SAMANTHA
        }
        
    }
    
    
    
    private func selectOption(option : Int) {
        
        
        switch option {
        case Mn4pConstants.KAREN:
            toggleKarenOption(isSelected: true)
            break
        case Mn4pConstants.DANIEL:
            toggleDanielOption(isSelected: true)
            break
        case Mn4pConstants.MOIRA:
            toggleMoiraOption(isSelected: true)
            break
        case Mn4pConstants.SAMANTHA:
            toggleSamanthaOption(isSelected: true)
            break
        default:
            toggleKarenOption(isSelected: true)
            break
        }
        
        
    }
    
    
    private func toggleKarenOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        karenOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        karenText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        karenCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
    private func toggleDanielOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        danielOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        danielText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        danielCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
    private func toggleMoiraOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        moiraOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        moiraText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        moiraCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
    private func toggleSamanthaOption(isSelected : Bool) {
        //Swift에서 삼항연산자를 사용가능한테 띄워쓰기를 잘해야 하는 듯
        samanthaOption.backgroundColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#0078FF" : "#FFFFFF", alpha: 1)
        
        samanthaText.textColor = HexColorManager.colorWithHexString(hexString: isSelected ? "#FFFFFF" : "#000000", alpha: 1)
        
        samanthaCheck.image = isSelected ? UIImage(named: "checked"): UIImage(named: "unchecked")
    }
    
   
}


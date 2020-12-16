//
//  SearchPlaceTableCell.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 4..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import UIKit

class SearchPlaceHistoryTableCell: UITableViewCell {
    var placeName: String?
    var clockIcon: UIImage?
    var address: String?
    
    var placeNameView : UITextField = {
        var textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = HexColorManager.colorWithHexString(hexString: "#212121", alpha: 1)
        textView.font = UIFont(name: "NotoSansKR-Regular", size: 16)
        
        return textView
    }()
    
    var clockIconView : UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()
    
    var addressView : UITextField = {
        var textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = HexColorManager.colorWithHexString(hexString: "#757575", alpha: 1)
        textView.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        
        return textView
    }()
   
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = HexColorManager.colorWithHexString(hexString: "#ffffff", alpha: 1)
        self.addSubview(clockIconView)
        self.addSubview(placeNameView)
        self.addSubview(addressView)
        //여기에 constraint를 잘못 지정하면 cell이 하나만 표시되는 등 이상하게 표시되니 주의
        //nameView.centerYAnchor.constraint(equalTo: self.centerYAnchor) 이것이 원인이었을 듯
        
        
        clockIconView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 19).isActive = true
        
        clockIconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        
        clockIconView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        clockIconView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        
        placeNameView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 60 ).isActive = true
        
        placeNameView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -20 ).isActive = true
        placeNameView.topAnchor.constraint(equalTo: self.topAnchor,constant: 7).isActive = true
        
        placeNameView.heightAnchor.constraint(equalToConstant: 20).isActive = true
      //UITextView를 tap하면 아무 반응이 없음. 아래 코드를 넣으면 TableView의 tap 이벤트가 발생
        placeNameView.isUserInteractionEnabled = false
       
        
        addressView.leftAnchor.constraint(equalTo: placeNameView.leftAnchor).isActive = true
        
        addressView.rightAnchor.constraint(equalTo: placeNameView.rightAnchor).isActive = true
        addressView.topAnchor.constraint(equalTo: placeNameView.bottomAnchor, constant: 2).isActive = true
        
        addressView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        addressView.isUserInteractionEnabled = false
        
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if let clockIcon = clockIcon {
            clockIconView.image = clockIcon
        }
        
        if let name = placeName {
            placeNameView.text = name
        }
        
        if let address = address {
            addressView.text = address
        }
        
    }
    
    
}

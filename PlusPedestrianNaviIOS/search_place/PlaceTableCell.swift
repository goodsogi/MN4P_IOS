//
//  SearchPlaceTableCell.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 4..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import UIKit

class PlaceTableCell: UITableViewCell {
    var placeName: String?
    var placeMarker: UIImage?
    var distance: String?
    var address: String?
    
    var placeNameView : UITextField = {
        var textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = HexColorManager.colorWithHexString(hexString: "#212121", alpha: 1)
        textView.font = UIFont(name: "NotoSansKR-Regular", size: 16)
        
        return textView
    }()
    
    var placeMarkerView : UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    } ()
    
    var distanceView : UITextField = {
        var textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = HexColorManager.colorWithHexString(hexString: "#757575", alpha: 1)
        textView.font = UIFont(name: "NotoSansKR-Medium", size: 12)
       
        return textView
    }()
    
    var addressView : UITextField = {
        var textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = HexColorManager.colorWithHexString(hexString: "#757575", alpha: 1)
        textView.font = UIFont(name: "NotoSansKR-Medium", size: 14)
        
        return textView
    }()
    
    var divider : UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = HexColorManager.colorWithHexString(hexString: "#efefef", alpha: 1)
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(placeMarkerView)
        self.addSubview(placeNameView)
        self.addSubview(distanceView)
        self.addSubview(addressView)
        self.addSubview(divider)
        //여기에 constraint를 잘못 지정하면 cell이 하나만 표시되는 등 이상하게 표시되니 주의
        //nameView.centerYAnchor.constraint(equalTo: self.centerYAnchor) 이것이 원인이었을 듯
        
        
        placeMarkerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 19).isActive = true
        
        placeMarkerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        
        placeMarkerView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        placeMarkerView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        
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
        
        distanceView.centerXAnchor.constraint(equalTo: placeMarkerView.centerXAnchor).isActive = true
        
        distanceView.topAnchor.constraint(equalTo: placeMarkerView.bottomAnchor).isActive = true
                
        distanceView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        distanceView.isUserInteractionEnabled = false
        
        divider.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 72).isActive = true
        divider.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        divider.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if let placeMarker = placeMarker {
            placeMarkerView.image = placeMarker
        }
        
        if let name = placeName {
            placeNameView.text = name
        }
        
        if let address = address {
            addressView.text = address
        }
        
        if let distance = distance {
            distanceView.text = distance
        }
        
    }
    
    
}

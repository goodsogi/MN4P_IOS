//
//  SearchPlaceTableCell.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 4..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import UIKit

class DirectionHistoryTableCell: UITableViewCell {
    var startPointAndDestinationName: String?

    
    var startPointAndDestinationNameView : UITextField = {
        var textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = HexColorManager.colorWithHexString(hexString: "#212121", alpha: 1)
        textView.font = UIFont(name: "NotoSansKR-Regular", size: 16)
        
        return textView
    }()
    
      
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = HexColorManager.colorWithHexString(hexString: "#ffffff", alpha: 1)
        self.addSubview(startPointAndDestinationNameView)
    
        //여기에 constraint를 잘못 지정하면 cell이 하나만 표시되는 등 이상하게 표시되니 주의
        //nameView.centerYAnchor.constraint(equalTo: self.centerYAnchor) 이것이 원인이었을 듯
      
        
        startPointAndDestinationNameView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 20 ).isActive = true
        
        startPointAndDestinationNameView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -20 ).isActive = true
        startPointAndDestinationNameView.topAnchor.constraint(equalTo: self.topAnchor,constant: 20).isActive = true
        
        startPointAndDestinationNameView.heightAnchor.constraint(equalToConstant: 20).isActive = true
      //UITextView를 tap하면 아무 반응이 없음. 아래 코드를 넣으면 TableView의 tap 이벤트가 발생
        startPointAndDestinationNameView.isUserInteractionEnabled = false
       
    
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if let name = startPointAndDestinationName {
            startPointAndDestinationNameView.text = name
        }
    
    }
    
    
}

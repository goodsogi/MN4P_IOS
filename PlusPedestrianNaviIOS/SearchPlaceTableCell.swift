//
//  SearchPlaceTableCell.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 4..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import UIKit


class SearchPlaceTableCell: UITableViewCell {
    var name: String?
    
    var nameView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(nameView)
        
        //여기에 constraint를 잘못 지정하면 cell이 하나만 표시되는 등 이상하게 표시되니 주의
        
        nameView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        nameView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        nameView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        nameView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        nameView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameView.isEditable = false
        
//        nameView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
//        //nameView.center.y = self.center.y
//        nameView.heightAnchor.constraint(equalToConstant: 100).isActive = true
//        nameView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true;
////        nameView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
//        nameView.isEditable = false
//
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let name = name {
            nameView.text = name
        }
    }
    
    
    
}

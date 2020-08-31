//
//  ImageMaker.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 21..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import UIKit

//둥근사각형, 원 등 이미지 생성 
class ImageMaker {
    
    static func getRoundRectangleWithoutFill(width: CGFloat, height: CGFloat, lineWidth: CGFloat, colorHexString: String, cornerRadius: CGFloat) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let img = renderer.image {
            
            ctx in
            let clipPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: cornerRadius)
            
            let borderColor = HexColorManager.colorWithHexString(hexString: colorHexString, alpha: 1.0)            
            borderColor.setStroke()
            clipPath.lineWidth = lineWidth
            clipPath.stroke()
            
        }
        
        
        return img
        
        
    }
    
    static func getRoundRectangle(width: CGFloat, height: CGFloat, colorHexString: String, cornerRadius: CGFloat, alpha: CGFloat) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let img = renderer.image {
            
            ctx in
            let clipPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: cornerRadius).cgPath
            
            ctx.cgContext.addPath(clipPath)
            ctx.cgContext.setFillColor(HexColorManager.colorWithHexString(hexString: colorHexString, alpha: alpha).cgColor)
            
            ctx.cgContext.closePath()
            ctx.cgContext.fillPath()
            
            
        }
        
        
        return img        
        
        
    }
    
    static func getRoundRectangleByCorners(width: CGFloat, height: CGFloat, colorHexString: String,  byRoundingCorners: UIRectCorner, cornerRadii: CGFloat, alpha: CGFloat) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let img = renderer.image {
            
            ctx in
            let clipPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), byRoundingCorners: byRoundingCorners , cornerRadii: CGSize(width: cornerRadii, height: cornerRadii)).cgPath
            
            ctx.cgContext.addPath(clipPath)
            ctx.cgContext.setFillColor(HexColorManager.colorWithHexString(hexString: colorHexString, alpha: alpha).cgColor)
            
            ctx.cgContext.closePath()
            ctx.cgContext.fillPath()
            
            
        }
        
        
        return img
        
        
    }
    
    
    static func getCircle(width: CGFloat, height: CGFloat, colorHexString: String, alpha: CGFloat) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let img = renderer.image {
            
            ctx in
            
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: width, height: height)).cgPath
            
            ctx.cgContext.addPath(circlePath)
            ctx.cgContext.setFillColor(HexColorManager.colorWithHexString(hexString: colorHexString, alpha: alpha).cgColor)
            
            ctx.cgContext.closePath()
            ctx.cgContext.fillPath()
            
        }
        
        return img
        
        
    }
    
}

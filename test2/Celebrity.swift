//
//  Celebrity.swift
//  test2
//
//  Created by Intern on 2018/11/20.
//  Copyright © 2018年 Intern. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class Celebrity{
    var boundingBox: [String:CGFloat]!
    
    
    var name:String!
    var urls:[String]!
    
    var infoLink:String!
    
    var infoLabel: UILabel!
    
    var infoButton:UIButton!
    
    var scene: UIImageView!
    
    
    func createInfoButton()-> UIButton {
        //Determine position of annotations based on the bounding box of the identified face
        let size = CGSize(width: self.boundingBox["width"]! * scene.layer.bounds.width, height:self.boundingBox["height"]!*scene.layer.bounds.height)
        let origin = CGPoint(x: self.boundingBox["left"]!*scene.layer.bounds.width, y: self.boundingBox["top"]!*scene.layer.bounds.height)
        
        /*
         *** Use this snippet if you want to draw a rectangle around the identified face***
         //Create a rectangle layer
         let rectangleLayer = CAShapeLayer()
         rectangleLayer.borderColor = UIColor.green.cgColor
         rectangleLayer.borderWidth = 2
         rectangleLayer.frame = CGRect(origin: origin, size: size)
         print(rectangleLayer.frame.origin)
         print(rectangleLayer.frame.size)
         ***
         */
        
        //Create and Populate info button
        self.infoButton = UIButton.init(frame: CGRect(origin: CGPoint(x: origin.x, y: origin.y+size.height*0.75), size: CGSize(width: 0.4*scene.layer.bounds.width, height: 0.05*scene.layer.bounds.height)))
        self.infoButton.backgroundColor = UIColor.black
        self.infoButton.clipsToBounds = true
        self.infoButton.layer.cornerRadius = 8
        self.infoButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.infoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.infoButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.infoButton.setTitle(self.name, for: UIControlState.normal)
        scene.isUserInteractionEnabled = true
        scene.addSubview(self.infoButton)
        
        return self.infoButton
        
    }
    
    
}

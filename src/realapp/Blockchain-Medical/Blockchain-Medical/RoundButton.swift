//
//  RoundButton.swift
//  Blockchain-Medical
//
//  Created by Ben Francis on 4/6/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {
    
//    required init?(coder aDecoder: NSCoder) {
//        self.frame.size = getSizeForButton()
//        super.init(coder: aDecoder)
//    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    func getSizeForButton() -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: 30, height: 30)
        } else {
            // iphones
            let bounds = UIScreen.main.bounds
            // iphone SE has 320 width
            if bounds.width > 320 {
                return CGSize(width: 80, height: 80)
            } else {
                return CGSize(width: 50, height: 50) // smaller button size!
            }
        }
    }
    

}

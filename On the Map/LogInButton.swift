//
//  LogInButton.swift
//  On the Map
//
//  Created by James Dellinger on 10/24/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import UIKit


@IBDesignable
class LogInButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }

}

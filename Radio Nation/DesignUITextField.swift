//
//  DesignableUITextField.swift
//  BarApi
//
//  Created by Kegham Karsian on 2/22/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableUITextField: UITextField {
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        textRect.origin.y += leftBottomPadding
        return textRect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x += rightPadding
        textRect.origin.y += rightBottomPadding
        return textRect
    }
    
    
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
    @IBInspectable var rightPadding: CGFloat = 0
    
    @IBInspectable var leftBottomPadding: CGFloat = 0
    
    @IBInspectable var rightBottomPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            imageView.contentMode = .scaleAspectFit
            leftView = imageView
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
        
        if let image2 = rightImage {
            rightViewMode = UITextFieldViewMode.always
            let imageView2 = UIImageView(frame: CGRect(x:0, y:0, width:20, height:20))
            imageView2.image = image2
            imageView2.tintColor = color
            imageView2.contentMode = .scaleAspectFit
            rightView = imageView2
        } else {
            rightViewMode = UITextFieldViewMode.never
            rightView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSForegroundColorAttributeName: color])
    }
}

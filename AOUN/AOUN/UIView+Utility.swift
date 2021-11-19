//
//  UIView+Utility.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 20/11/2021.
//

import UIKit

extension UIView {
    //MARK: Border
    @IBInspectable var borderWidth : CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth =  newValue
        }
    }

    @IBInspectable var borderColor : UIColor {
        get {
            let c = layer.borderColor ?? (self.backgroundColor?.cgColor ?? UIColor.clear.cgColor) //either border color or view background color or clear color
            return UIColor(cgColor: c)
        }
        set {
            layer.borderColor =  newValue.cgColor
        }
    }
    
    //MARK: Corner
    @IBInspectable var cornerRadius : CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            layer.cornerRadius =  newValue
        }
    }
    
    //MARK: Shadow
    @IBInspectable var shadowRadius : CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            layer.shadowRadius =  newValue
        }
    }

    @IBInspectable var shadowOpacity : Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity =  newValue
        }
    }

    
    @IBInspectable var shadowColor : UIColor? {
        get {
            if let c = layer.shadowColor {return UIColor(cgColor: c)}
            return nil
        }
        set {
            if let c = newValue {
                layer.shadowColor = c.cgColor
            }else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable var shadowOffset : CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    //MARK: Functions
    func setCircleShape () {
        let radius : CGFloat = self.bounds.size.width / 2
        self.layer.cornerRadius = radius
    }
    
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setRoundedCorners(_ corners : UIRectCorner, radius : CGFloat) {
        let bp = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = bp.cgPath
        self.layer.masksToBounds = true
        self.layer.mask = mask
    }
}

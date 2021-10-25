//
//  AOUNExtensions.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 25/10/2021.
//

import UIKit

extension UIAlertController {
    func setBackgroundColor(color:UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
}

//
//  CustomAlertMessage.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 28/10/2021.
//

import UIKit

class CustomAlert {
    open class func showAlert (title:String, message:String, inController : UIViewController, with image:UIImage? = nil, cancleTitle:String, cancled:@escaping (()->Void) ) {
        let m = message + "\n"

        let vcAlert = UIAlertController(title:title, message: m, preferredStyle: .alert)
        vcAlert.view.tintColor = .black //OK
        if let i = image {
            let imageView = UIImageView(frame: CGRect(x: 125, y: 77, width: 20, height: 20))
            imageView.image = i
            vcAlert.view.addSubview(imageView)
        }
        let okAction = UIAlertAction(title: "Ok", style: .default) { alertAction in
            cancled()
        }
        vcAlert.addAction(okAction)
        inController.present(vcAlert, animated: true, completion: nil)
    }
}

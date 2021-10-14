//
//  AskQuestion.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 14/10/2021.
//

import UIKit

class AskQuestion: UIViewController {

    @IBOutlet var Description: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Description.layer.borderColor = UIColor .gray.cgColor;
        self.Description.layer.borderWidth = 1.0;
        self.Description.layer.cornerRadius = 8;
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

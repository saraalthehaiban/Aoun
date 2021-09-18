//
//  resPostViewController.swift
//  AOUN
//
//  Created by Reema Turki on 11/02/1443 AH.
//

import UIKit

class resPostViewController: UIViewController {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var smallBackground: UIImageView!
    @IBOutlet weak var topPic: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var rIcon: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var welcome2: UILabel!
    
    @IBOutlet weak var postL: UILabel!
    
    @IBOutlet weak var resourceL: UILabel!
    @IBOutlet weak var autherL: UILabel!
    @IBOutlet weak var publisherL: UILabel!
    @IBOutlet weak var resourceV: UITextField!
    @IBOutlet weak var autherV: UITextField!
    @IBOutlet weak var publisherV: UITextField!
    
    @IBOutlet weak var picker: UIPickerView!
    let data = ["PDF","Link"]
    
    @IBAction func submit(_ sender: UIButton) {
        
        
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcome2.text = "Sara!"
       
        picker.dataSource = self
        picker.delegate = self
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



extension resPostViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
}


extension resPostViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
}


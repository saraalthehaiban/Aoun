//
//  QuestionDetials.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 15/10/2021.
//

import UIKit

class QuestionDetails: UIViewController {


    @IBOutlet var AnsTable: UITableView!
    @IBOutlet var Qtitle: UILabel!
    @IBOutlet var Qbody: UILabel!
    var QV : String = ""
    var BV : String = ""
    var answers: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        AnsTable.delegate = self
        AnsTable.dataSource = self
        AnsTable.register(UINib(nibName: "CommunityAnswer", bundle: nil), forCellReuseIdentifier: "ACell")
        Qtitle.text = QV
        Qbody.text = BV
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
extension QuestionDetails: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AnsTable.dequeueReusableCell(withIdentifier: "ACell", for: indexPath) as! CommunityAnswer
        cell.body.text = answers[indexPath.row]
        //hot fix
        return cell
    }
    
    
}
extension QuestionDetails: UITableViewDelegate{
   // func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    let selectedRow = indexPath.row
    //    if let vc = storyboard?.instantiateViewController(identifier: "QuestionDetails") as? QuestionDetails{
    //        vc.Qtitle.text = questions[selectedRow].title
   //         vc.Qbody.text = questions[selectedRow].body
   //         vc.answers = questions[selectedRow].answer
   //         self.present(vc, animated: true, completion: nil)
   // }
  //  }
}

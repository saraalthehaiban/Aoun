//
//  QuestionDetials.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 15/10/2021.
//

import UIKit
import Firebase
protocol CommunityDelegate{
    func update()
    func ID(index : Int) -> String
}
class QuestionDetail: UIViewController {
    @IBOutlet var empty: UILabel!
    var i : Int = 0
    var delegate: CommunityDelegate?
    var db = Firestore.firestore()
    @IBOutlet var Qbody: UILabel!
    @IBOutlet var AnsTable: UITableView!
    @IBOutlet var Qtitle: UILabel!
    var docID : String = ""
    var comID : String = ""
    var QV : String = ""
    var BV : String = ""
    var answers: [String] = []
    var ans : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        AnsTable.delegate = self
        AnsTable.dataSource = self
        AnsTable.register(UINib(nibName: "CommunityAnswer", bundle: nil), forCellReuseIdentifier: "ACell")
        Qtitle.text = QV
        Qbody.text = BV
        loadAnswers()
        check()
        print("before: ", answers)

        // Do any additional setup after loading the view.
    }
    
    func loadAnswers(){
        //answers = []
            db.collection("Questions").getDocuments{
            querySnapshot, error in
                       if let e = error {
                           print("There was an issue retreving data from fireStore. \(e)")
                       }else {
                           if let snapshotDocuments = querySnapshot?.documents{
                               for doc in snapshotDocuments{
                                let data =  doc.data()
                                if doc.documentID as? String == self.docID{
                                    if data["answers"] != nil{
                                        self.answers = data["answers"] as! [String]}
                                    else{
                                        break
                                    }
                                    
                                   // print(Answers)
                                    //self.answers = Answers
                                }
                               }
                            
                            DispatchQueue.main.async {
                                self.AnsTable.reloadData()
                            }
                            
                           } //hard coded, get from transition var = ID
                        
                       }
                
            }

    }
    func check(){
      //  delegate?.update()
      //  delegate?.ID(index: 0)
        if answers.count == 0{
            empty.text = "Hasn't been answered yet"
        } else {
            print("HERE!")
            empty.text = ""
            empty.isHidden = true
            empty.removeFromSuperview()
        }
        
    }

    @IBAction func answer(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "AnswerQuestion") as? AnswerQuestion {
            vc.bd = BV
            vc.ID = docID
            vc.answers = answers
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
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
extension QuestionDetail: UITableViewDataSource{
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
extension QuestionDetail: UITableViewDelegate{
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
extension QuestionDetail: AnswerQuestionDelegate{
    func update(ans : String){
        loadAnswers()
        answers.append(ans)
        print("after: ", answers)
        check()
       // print(self.answers)
        //AnsTable.reloadData()
    }
}

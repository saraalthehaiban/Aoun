//
//  Community.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 14/10/2021.
//

import UIKit
import Firebase

class Community: UIViewController {
    var db = Firestore.firestore()
    var ID : String = "4mjNGYMa4HN6V74A0bP4"
    @IBOutlet var comName: UILabel!
    @IBOutlet var display: UITableView!
    var questions: [Question] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        display.register(UINib(nibName: "CommunityQuestion", bundle: nil), forCellReuseIdentifier: "QCell")
        display.delegate = self
        display.dataSource = self
        loadQuestions()
        // Do any additional setup after loading the view.
    }
    
    func loadQuestions(){
        questions = []
            db.collection("Questions").getDocuments{
            querySnapshot, error in
                       if let e = error {
                           print("There was an issue retreving data from fireStore. \(e)")
                       }else {
                           if let snapshotDocuments = querySnapshot?.documents{
                               for doc in snapshotDocuments{
                                let data =  doc.data()
                                if data["ID"] as? String == self.ID{
                                    self.comName.text = data["Community"] as? String
                                    let Title = data["Title"] as? String
                                    let Body = data["Body"] as? String
                                    let Answers = data["Answers"] as? [String]
                                    let newQ = Question(title: Title!, body: Body!, answer: Answers!)
                                    self.questions.append(newQ)
                                    //Implement no questions in a community
                                    break
                                }
                               }
                            DispatchQueue.main.async {
                                self.display.reloadData()
                            }
                            
                           } //hard coded, get from transition var = ID
                        
                       }
                
            }
    }
    
    @IBAction func addQ(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "AskQuestion") as? AskQuestion {
            vc.ID = ID
            self.present(vc, animated: true, completion: nil)
        }
    }
}
extension Community: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = display.dequeueReusableCell(withIdentifier: "QCell", for: indexPath) as! CommunityQuestion
        print("loaded")
        cell.QField.text = questions[indexPath.row].title
        //Title
        return cell
    }
    
    
}
extension Community: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        if let vc = storyboard?.instantiateViewController(identifier: "QuestionDetails") as? QuestionDetails{
            vc.QV = questions[selectedRow].title
            vc.BV = questions[selectedRow].body
            vc.answers = questions[selectedRow].answer
            self.present(vc, animated: true, completion: nil) 
    }
    }
}

extension Community: AskQuestionDelegate{
    func add() {
        display.reloadData()
    }
    
    
}


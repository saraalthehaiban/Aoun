//
//  Community.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 14/10/2021.
//

import UIKit
import Firebase

class Community: UIViewController {
    @IBOutlet var empty: UILabel!
    var db = Firestore.firestore()
    var ID : String = ""
    var name : String = ""
    var ids : [String : String] = [:] //
    @IBOutlet var comName: UILabel!
    @IBOutlet var display: UITableView!
    var questions: [Question] = []
    var titleX : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        display.register(UINib(nibName: "CommunityQuestion", bundle: nil), forCellReuseIdentifier: "QCell")
        display.delegate = self
        display.dataSource = self
        comName.text = name
        loadQuestions()
        print("Before:", ids)
        // Do any additional setup after loading the view.
        if questions.count == 0 {
            empty.text = "No questions have been asked yet"
        }
        //        else{
        //            empty.text = ""
        //        }
    }
    
    func loadQuestions(){
        questions = []
        db.collection("Questions").getDocuments{
            querySnapshot, error in
            var hideEmptyLabel = true
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
                hideEmptyLabel = false
            }else {
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data =  doc.data()
                        if data["ID"] as? String == self.ID{
                            self.empty.text = ""
                            //self.comName.text = data["Community"] as? String
                            //self.name = data["Community"] as? String ?? ""
                            let Title = data["Title"] as? String
                            let Body = data["Body"] as? String
                            let Answers = data["answers"] as? [String]
                            let askingUserID = data["User"] as? String
                            let newQ = Question(title: Title ?? "", body: Body ?? "", answer: Answers ?? [""], askingUserID: askingUserID )
                            
                            self.questions.append(newQ)
                            self.ids[Title!] = doc.documentID
                            
                        }
                    }
                    hideEmptyLabel = (self.questions.count != 0)
                    DispatchQueue.main.async {
                        self.display.reloadData()
                    }
                    
                } //hard coded, get from transition var = ID
                
            }
            self.empty.isHidden = hideEmptyLabel
        }
    }
    
    @IBAction func addQ(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "AskQuestion") as? AskQuestion {
            vc.ID = ID
            vc.ComName = self.name
            vc.delegate = self
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
        cell.QField.text = questions[indexPath.row].title
        //Title
        return cell
    }
    
    
}
extension Community: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        if let vc = storyboard?.instantiateViewController(identifier: "QuestionDetails") as? QuestionDetail{
            vc.QV = questions[selectedRow].title
            vc.BV = questions[selectedRow].body
            vc.answers = questions[selectedRow].answer
            let cell = tableView.cellForRow(at: indexPath) as! CommunityQuestion
            titleX = cell.QField.text ?? "NIL"
            vc.docID = ids[titleX] ?? "NIL"
            
            //   vc.docID = ids[selectedRow]
            vc.comID = ID
            //vc.i = indexPath.row
            
            
            vc.delegate = self
            self.present(vc, animated: true, completion: nil) 
        }
    }
}

extension Community: AskQuestionDelegate{
    func add(){
        loadQuestions()
        display.reloadData()
    }
    func after(sendBack : String){
        print("Here is 3: ", sendBack)
        // ids.append(sendBack)
        print("After:", ids)
    }
    
    
}
extension Community: CommunityDelegate{
    func update(){
        loadQuestions()
        display.reloadData()
    }
    func ID(index : Int) -> String{
        return ""
    }
}


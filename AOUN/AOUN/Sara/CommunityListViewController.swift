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
    var titleX : String = ""
    
    @IBOutlet var addQuestion: UIButton!
    //SearchBar
    @IBOutlet weak var searchBarQ: UISearchBar!
    var searchActive : Bool = false
    var questions: [Question] = [] {
        didSet {
            filtered = questions
        }
    }
    var filtered:[Question] = [] {
        didSet {
            self.display.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        display.register(UINib(nibName: "CommunityQuestion", bundle: nil), forCellReuseIdentifier: "QCell")
        display.delegate = self
        display.dataSource = self
        comName.text = name
        
        addQuestion.layer.shadowColor = UIColor.black.cgColor
        addQuestion.layer.shadowOpacity = 0.25
        addQuestion.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        

        
        loadQuestions()
    }
    
    func loadQuestions(){
        questions = []
        self.set(message: "Loading..")
        db.collection("Questions").order(by: "createDate", descending: true).getDocuments {       querySnapshot, error in
            if let e = error {
                print("There was an issue retreving data from fireStore. \(e)")
            }else {
                if let snapshotDocuments = querySnapshot?.documents{
                    var qs : [Question] = []
                    for doc in snapshotDocuments{
                        let data =  doc.data()
                        if data["ID"] as? String == self.ID{
                            let Title = data["Title"] as? String
                            let Body = data["Body"] as? String
                            let Answers = data["answers"] as? [String]
                            let askingUserID = data["User"] as? String
                            let createDate = data["createDate"] as! Timestamp
                            let newQ = Question(title: Title ?? "", body: Body ?? "", answer: Answers ?? [""], askingUserID: askingUserID, createDate: createDate )
                            
                            qs.append(newQ)
                            self.ids[Title!] = doc.documentID
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.questions = qs
                        self.set(message: (self.questions.count == 0) ? "No questions have been asked yet" : nil)
                    }
                }
            }
        }
        //a
    }
    
    
    @IBAction func addQ(_ sender: UIButton) {
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
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = display.dequeueReusableCell(withIdentifier: "QCell", for: indexPath) as! CommunityQuestion
        cell.QField.text = filtered[indexPath.row].title
        cell.descriptionLabel.text = filtered[indexPath.row].body
        return cell
    }
}

extension Community: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        if let vc = storyboard?.instantiateViewController(identifier: "QuestionDetails") as? QuestionDetail{
            vc.QV = filtered[selectedRow].title
            vc.BV = filtered[selectedRow].body
            vc.answers = filtered[selectedRow].answer
            let cell = tableView.cellForRow(at: indexPath) as! CommunityQuestion
            titleX = cell.QField.text ?? "NIL"
            vc.docID = ids[titleX] ?? "NIL"
            vc.comID = ID
            vc.question = filtered[selectedRow]
            vc.delegate = self
            self.present(vc, animated: true, completion: nil) 
        }
    }
}

extension Community: AskQuestionDelegate {
    func add() {
        loadQuestions()
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
    }
    
    func ID(index : Int) -> String{
        return ""
    }
}

extension Community: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filter(searchText: searchText)
        
    }
    
    func filter (searchText:String?) {
        if let st = searchText, st.count > 0 {
            filtered = questions.filter { $0.title.range(of: st, options: .caseInsensitive) != nil || $0.body.range(of: st, options: .caseInsensitive) != nil  }
            
        }else{
            filtered = questions
        }
        
        self.set(message: (filtered.count == 0) ? "No results." : nil)
    }
    
    func set(message:String?) {
        self.empty.text = message
    }
}

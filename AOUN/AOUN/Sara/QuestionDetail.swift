////
////  QuestionDetials.swift
////  AOUN
////
////  Created by Sara AlThehaiban on 15/10/2021.
////
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
    @IBOutlet var Qbody: UITextView!
    var db = Firestore.firestore()
    @IBOutlet var AnsTable: UITableView!
    @IBOutlet var Qtitle: UILabel!
    var docID : String = ""
    var comID : String = ""
    var QV : String = ""
    var BV : String = ""
    var answers: [Answer] = [] {
        didSet {
            self.AnsTable.reloadData()
        }
    }
    var ans : [String] = []
    var question : Question!
    var askingUser : User!

    @IBOutlet weak var btn_userName: UIButton!

    @IBOutlet var addAnswerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        AnsTable.delegate = self
        AnsTable.dataSource = self
        AnsTable.register(UINib(nibName: "CommunityAnswer", bundle: nil), forCellReuseIdentifier: "ACell")
        Qtitle.text = QV
        Qbody.text = BV
        loadAnswers()
        check()

        self.loadUserData { error, fullName in
            self.btn_userName.setTitle(fullName, for: .normal)
        }

        addAnswerButton.layer.shadowColor = UIColor.black.cgColor
        addAnswerButton.layer.shadowOpacity = 0.25

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonUserNameTouched(_ sender: Any) {
        OtherUserProfile.present(with: self.askingUser, on: self)
    }
    
    func loadAnswers(){
        //answers = []
        db.collection("Questions").document(self.question.documentId).collection("answers").order(by: "createDate", descending: true).getDocuments { querySnaphot, error in
            if let e = error {
                print ("Error: ", e)
            } else {
                guard let documents = querySnaphot?.documents else {return}
                var answers : [Answer] = []
                for document in documents {
                    let data = document.data()
                    if let answer = Answer(dictionary: data) {
                        answers.append(answer)
                    }
                }
                DispatchQueue.main.async {
                    self.answers = answers
                    self.check()
                }
            }
        }
    }
    
    func check() {
        delegate?.update()
        delegate?.ID(index: 0)
        if answers.count == 0{
            empty.text = "Hasn't been answered yet"
        } else {
            empty.text = ""
            empty.isHidden = true
            empty.removeFromSuperview()
        }
    }

    
    func loadUserData(_ completion : @escaping(Error?, String?)->Void) {
        
        db.collection("users").whereField("uid", isEqualTo: question.askingUserID!).getDocuments { (querySnapshot, error) in
            if let error = error {
                //Display Error
                print(error)
                completion(error, nil)
            } else {
                guard let ds = querySnapshot, !ds.isEmpty else {
                    //TODO: Add error handeling here
                    //completion(fullName)
                    //completion(Error(), nil)
                    return
                }
                
                if let userData = ds.documents.last {
                    let firstname = userData["FirstName"] as? String ?? ""
                    let lastName = userData["LastName"] as? String ?? ""
                    let fullName = firstname + ((lastName.count > 0) ? " \(lastName)" : "")
                    let user = User(FirstName: firstname, LastName: lastName, uid: self.question.askingUserID!)
                    self.askingUser = user
                    completion(nil , fullName)
                }else{
                    completion(nil, nil)
                }
            }
        }

//        query.getDocuments ( completion:  {(snapShot, errror) in
//            guard let ds = snapShot, !ds.isEmpty else {
//                //TODO: Add error handeling here
//                return
//            }
//
//            if let userData = ds.documents.last {
//                let firstname = userData["FirstName"] as? String ?? ""
//                let lastName = userData["LastName"] as? String ?? ""
//                let fullName = firstname + ((lastName.count > 0) ? " \(lastName)" : "")
//                let user = User(FirstName: firstname, LastName: lastName, uid: thisUserId)
//                self.user = user
//                completion(fullName)
//            }
//        })
    }

    @IBAction func answer(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "AnswerQuestion") as? AnswerQuestion {
            vc.bd = BV
            vc.ID = docID
            //vc.answers = answers
            vc.delegate = self
            vc.question = self.question
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACell", for: indexPath) as! CommunityAnswer
        cell.answer = answers[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension QuestionDetail: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedRow = indexPath.row
//        if let vc = storyboard?.instantiateViewController(identifier: "QuestionDetails") as? QuestionDetails{
//            vc.Qtitle.text = questions[selectedRow].title
//            vc.Qbody.text = questions[selectedRow].body
//            vc.answers = questions[selectedRow].answer
//            self.present(vc, animated: true, completion: nil)
//        }
    }
}

extension QuestionDetail: AnswerQuestionDelegate{
    func answer(_ vc : AnswerQuestion, added:Answer?, successfully:Bool) {
        guard let a = added, successfully == true else {return}
        self.answers.insert(a, at: 0)
    }

    func update(ans : String){
//        //  loadAnswers()
//        print("after: ", answers)
//        answers.append(ans)
//        print("after: ", answers)
//        check()
//        // print(self.answers)
//        AnsTable.reloadData()
    }
}

extension QuestionDetail : CommunityAnswerDelegate {
    func community(_ cell: CommunityAnswer, tappedUserFor answer:Answer) {
        db.collection("users").document(answer.user).getDocument { documentReference, error in
            if let u = documentReference?.data(), var user = User(dictionary: u) {
                user.docID = documentReference?.documentID
                OtherUserProfile.present(with: user, on: self)
            }
        }
    }
}

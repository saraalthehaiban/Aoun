//
//  Community.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 14/10/2021.
//

import UIKit

class Community: UIViewController {
    @IBOutlet var comName: UILabel!
    @IBOutlet var display: UITableView!
    @IBOutlet var AddQ: UIButton!
    var questions: [Question] = [
        Question(title: "What's my name?", body: "How come all of the chimera ants have names and their own king doesn't?", answer: ["Pouf: Your name is the King!", "Pitou: Your name is what you feel like calling yourself", "Youpi: I am in no place to comment, my King"] ),
        Question(title: "What's my name?", body: "How come all of the chimera ants have names and their own king doesn't?", answer: ["Pouf: Your name is the King!", "Pitou: Your name is what you feel like calling yourself", "Youpi: I am in no place to comment, my King"] ),
        Question(title: "What's my name?", body: "How come all of the chimera ants have names and their own king doesn't?", answer: ["Pouf: Your name is the King!", "Pitou: Your name is what you feel like calling yourself", "Youpi: I am in no place to comment, my King"] )
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        display.delegate = self
        display.dataSource = self
        display.register(UINib(nibName: "CommunityQuestion", bundle: nil), forCellReuseIdentifier: "QCell")
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
        if let vc = storyboard?.instantiateViewController(identifier: "QuestionDetails") as? QuestionDetails{
            vc.Qtitle.text = questions[selectedRow].title
            vc.Qbody.text = questions[selectedRow].body
            vc.answers = questions[selectedRow].answer
            self.present(vc, animated: true, completion: nil)
    }
    }
}

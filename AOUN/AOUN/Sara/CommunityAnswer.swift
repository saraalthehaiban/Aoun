//
//  CommunityAnswer.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 16/10/2021.
//

import UIKit

protocol CommunityAnswerDelegate {
    func community(_ cell: CommunityAnswer, tappedUserFor answer:Answer)
}

class CommunityAnswer: UITableViewCell {
    var delegate : CommunityAnswerDelegate?
    @IBOutlet var userButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    var answer : Answer! {
        didSet {
            self.userButton.setTitle(self.answer.username, for: .normal)
            self.body.text = answer.answer
            self.dateLabel.text = answer.createDate.dateValue().displayString()
        }
    }
    
    @IBOutlet var body: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func userButtonTouched(_ sender: Any) {
        delegate?.community(self, tappedUserFor: answer)
    }
}

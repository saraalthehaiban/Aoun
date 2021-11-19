//
//  CommunityQuestion.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 15/10/2021.
//

import UIKit

class CommunityQuestion: UITableViewCell {

    @IBOutlet var IMG: UIImageView!
    @IBOutlet var QBubble: UIView!
    @IBOutlet var QField: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

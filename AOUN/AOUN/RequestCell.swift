//
//  RequestCell.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 20/09/2021.
//

import UIKit

class RequestCell: UITableViewCell {
    @IBOutlet var RequestBubble: UIView!
    @IBOutlet var name: UILabel!

    @IBAction func reqDetails(_ sender: UIButton) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ResTableViewCell.swift
//  AOUN
//
//  Created by shatha on 15/03/1443 AH.
//

import UIKit

class ResTableViewCell: UITableViewCell {

    @IBOutlet weak var resBubble: UIView!
    @IBOutlet weak var resTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  notesTableViewCell.swift
//  AOUN
//
//  Created by shatha on 10/03/1443 AH.
//

import UIKit

class notesTableViewCell: UITableViewCell {

    @IBOutlet weak var bubble: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var notePhoto: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

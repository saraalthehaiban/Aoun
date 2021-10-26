//
//  notesTableViewCell.swift
//  AOUN
//
//  Created by shatha on 10/03/1443 AH.
//

import UIKit

class notesTableViewCell: UITableViewCell {

    @IBOutlet weak var noteBubbble: UIView!
    @IBOutlet weak var noteTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

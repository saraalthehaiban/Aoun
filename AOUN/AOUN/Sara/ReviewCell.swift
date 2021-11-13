//
//  ReviewCell.swift
//  AOUN
//
//  Created by Sara AlThehaiban on 04/11/2021.
//

import UIKit
import Cosmos
class ReviewCell: UITableViewCell {
    @IBOutlet var body: UILabel!
    
    @IBOutlet var stars: CosmosView!
    @IBOutlet var user: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

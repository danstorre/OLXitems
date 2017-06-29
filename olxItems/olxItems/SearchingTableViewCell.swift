//
//  SearchingTableViewCell.swift
//  olxItems
//
//  Created by Daniel Torres on 6/28/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import UIKit

class SearchingTableViewCell: UITableViewCell {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var message: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

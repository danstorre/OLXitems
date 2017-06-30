//
//  PaginationTableViewCell.swift
//  olxItems
//
//  Created by Daniel Torres on 6/29/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import UIKit

class PaginationTableViewCell: UITableViewCell {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

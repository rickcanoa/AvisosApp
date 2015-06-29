//
//  myCustomCell.swift
//  AvisosApp
//
//  Created by Richard Canoa on 22/5/15.
//  Copyright (c) 2015 Richard Canoa. All rights reserved.
//

import UIKit

class myCustomCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

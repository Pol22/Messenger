//
//  MyCustomViewCell.swift
//  Messenger
//
//  Created by Admin on 10.12.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

class MyCustomViewCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

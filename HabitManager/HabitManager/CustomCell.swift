//
//  CustomCell.swift
//  HabitManager
//
//  Created by Percy Hu on 22/04/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet var habitLabel: UILabel!
    @IBOutlet var habitDetailsLabel: UILabel!
    @IBOutlet var notificationsLabel: UILabel!
    @IBOutlet var cellSwitch: UISwitch!
    @IBOutlet var ribbonHead: UIImageView!
    @IBOutlet var ribbonBody: UIImageView!
    @IBOutlet var ribbonTail: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

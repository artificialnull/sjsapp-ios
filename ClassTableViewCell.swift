//
//  ClassTableViewCell.swift
//  sjsapp
//
//  Created by Ishan on 2/20/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    
    @IBOutlet weak var classStartLabel: UILabel!
    @IBOutlet weak var classEndLabel: UILabel!
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var classTeacherLabel: UILabel!
    @IBOutlet weak var classBlockLabel: UILabel!
    @IBOutlet weak var classRoomLabel: UILabel!
    @IBOutlet weak var classStartMinWidth: NSLayoutConstraint!
    @IBOutlet weak var classEndMinWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

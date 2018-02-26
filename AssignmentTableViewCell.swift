//
//  AssignmentTableViewCell.swift
//  sjsapp
//
//  Created by Ishan on 2/24/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit

class AssignmentTableViewCell: UITableViewCell {
    @IBOutlet weak var assignmentAssigned: UILabel!
    @IBOutlet weak var assignmentDue: UILabel!
    @IBOutlet weak var assignmentClass: UILabel!
    @IBOutlet weak var assignmentShort: UILabel!
    @IBOutlet weak var assignmentType: UILabel!
    @IBOutlet weak var assignmentStatus: UILabel!
    @IBOutlet weak var assignmentAssignedMinWidth: NSLayoutConstraint!
    @IBOutlet weak var assignmentDueMinWidth: NSLayoutConstraint!
    
    var assignment: Assignment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

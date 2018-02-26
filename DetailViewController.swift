//
//  DetailViewController.swift
//  sjsapp
//
//  Created by Ishan on 2/25/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var shortLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var assignedLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var statusButton: UISegmentedControl!
    
    var assignment: Assignment?
    let fmt = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fmt.dateFormat = "M/d/yyyy HH:mm"
        self.navigationItem.title = "Details"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shortLabel.text = assignment?.assignmentShort.htmlToString
        longLabel.text = assignment?.assignmentLong?.htmlToString
        classLabel.text = assignment?.assignmentClass
        assignedLabel.text = fmt.string(from: (assignment?.assignmentAssigned)!)
        dueLabel.text = fmt.string(from: (assignment?.assignmentDue)!)
        
        (statusButton.subviews[2] as UIView).tintColor = Assignment.toDoColor
        (statusButton.subviews[1] as UIView).tintColor = Assignment.inProgressColor
        (statusButton.subviews[0] as UIView).tintColor = Assignment.completedColor
        
        statusButton.selectedSegmentIndex = (assignment?.assignmentStatus.statusCode)! + 1
        
        statusButton.addTarget(self, action: #selector(DetailViewController.statusChanged(_:)), for: .valueChanged)
    }
    
    @objc func statusChanged(_ segControl: UISegmentedControl) {
        assignment?.assignmentStatus = Assignment().statusFromInt(status: segControl.selectedSegmentIndex - 1)
        Browser().updateAssignmentStatus(assignment: assignment!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

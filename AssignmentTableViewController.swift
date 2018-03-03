//
//  AssignmentTableViewController.swift
//  sjsapp
//
//  Created by Ishan on 2/24/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.width)
    }
}

class AssignmentTableViewController: UITableViewController {
    var assignments = [Assignment]()
    var activityIndicator: UIActivityIndicatorView!

    let fmt = DateFormatter()
    
    var dateMinWidth: CGFloat = 0.0

    override func viewDidLoad() {

        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(frame:
            CGRect(
                x: 0, y: 0, width: 40, height: 40
            )
        )
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.tableView.backgroundView = activityIndicator
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func rangeChanger() {
        print("zay")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = false
        
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: self, action: nil))
        items.append(UIBarButtonItem(image: #imageLiteral(resourceName: "range"), style: .plain, target: self,
                                     action: #selector(rangeChanger)))
        items.append(UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: self, action: nil))
        items.append(UIBarButtonItem(image: #imageLiteral(resourceName: "sorting"), style: .plain, target: self,
                                     action: #selector(showSortByMenu)))
        items.append(UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: self, action: nil))
        items.append(UIBarButtonItem(image: #imageLiteral(resourceName: "view"), style: .plain, target: self,
                                     action: #selector(rangeChanger)))
        items.append(UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: self, action: nil))
        self.toolbarItems = items
        self.navigationController?.toolbar.tintColor = UIColor.red
        
        fmt.dateFormat = (UserDefaults().bool(forKey: "date8601")) ?
            "yyyy-MM-dd" : "M/d/yyyy"
        dateMinWidth = 0.0
        activityIndicator.startAnimating()

        assignments = [Assignment]()
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch UserDefaults().string(forKey: "assignmentSort") {
        case "Due"?:
            refresh(sorter: sortByDue(as1:as2:))
        case "Assigned"?:
            refresh(sorter: sortByAssigned(as1:as2:))
        case "Class"?:
            refresh(sorter: sortByClass(as1:as2:))
        default:
            print("wut wut in the")
            refresh(sorter: sortByDue(as1:as2:))
        }
        
    }
    
    func refresh(sorter: @escaping (Assignment, Assignment) -> Bool) {
        
        if !Browser().credentialsExist() {
            let noLogInIndicator = UILabel()
            noLogInIndicator.center = self.view.center
            noLogInIndicator.textAlignment = NSTextAlignment.center
            noLogInIndicator.text = "Sign in to load assignments"
            self.tableView.backgroundView = noLogInIndicator
        } else {
            self.tableView.backgroundView = activityIndicator
        }
        
        activityIndicator.startAnimating()
        
        assignments = [Assignment]()
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
        Browser().getAssignmentJSON() { response in
            for assignment in response! {
                let startTimeStr = self.fmt.string(from: assignment.assignmentAssigned)
                let endTimeStr = self.fmt.string(from: assignment.assignmentDue)
                let startTimeWidth = startTimeStr.width(
                    withConstrainedHeight: 99,
                    font: UIFont.systemFont(ofSize: 13.0)
                )
                let endTimeWidth = endTimeStr.width(
                    withConstrainedHeight: 99,
                    font: UIFont.systemFont(ofSize: 13.0)
                )
                if startTimeWidth > self.dateMinWidth {
                    self.dateMinWidth = startTimeWidth
                }
                if endTimeWidth > self.dateMinWidth {
                    self.dateMinWidth = endTimeWidth
                }
            }
            print(self.dateMinWidth)
            self.assignments = response!
            self.assignments.sort { as1, as2 in
                return sorter(as1, as2)
            }
            self.activityIndicator.stopAnimating()
            self.tableView.separatorStyle = .singleLine
            self.tableView.reloadData()
        }
    }
    
    func sortByDue(as1: Assignment, as2: Assignment) -> Bool {
        switch (as1.assignmentDue.compare(as2.assignmentDue)) {
        case .orderedAscending:
            return true
        default:
            return false
        }
    }
    
    func sortByAssigned(as1: Assignment, as2: Assignment) -> Bool {
        switch (as1.assignmentAssigned.compare(as2.assignmentAssigned)) {
        case .orderedAscending:
            return true
        default:
            return false
        }
    }

    func sortByClass(as1: Assignment, as2: Assignment) -> Bool {
        switch (as1.assignmentClass.compare(as2.assignmentClass)) {
        case .orderedAscending:
            return true
        default:
            return false
        }
    }
    
    @objc func showSortByMenu() {
        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Due", style: .default, handler: {_ in
            self.refresh(sorter: self.sortByDue(as1:as2:))
        }))
        alert.addAction(UIAlertAction(title: "Assigned", style: .default, handler: {_ in
            self.refresh(sorter: self.sortByAssigned(as1:as2:))
        }))
        alert.addAction(UIAlertAction(title: "Class", style: .default, handler: {_ in
            self.refresh(sorter: self.sortByClass(as1:as2:))
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.view.tintColor = UIColor.red

        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (assignments.count == 0) ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return assignments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AssignmentTableViewCell"
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath) as? AssignmentTableViewCell

        let assignment = assignments[indexPath.row]
        
        // Configure the cell...
        
        cell?.assignmentClass.text = assignment.assignmentClass
        cell?.assignmentShort.text = assignment.assignmentShort.htmlToString
        cell?.assignmentAssigned.text = fmt.string(from: assignment.assignmentAssigned)
        cell?.assignmentDue.text = fmt.string(from: assignment.assignmentDue)
        cell?.assignmentStatus.text = assignment.assignmentStatus.statusString
        cell?.assignmentStatus.textColor = assignment.assignmentStatus.statusColor
        cell?.assignmentType.text = assignment.assignmentType
        
        cell?.assignmentAssignedMinWidth.constant = dateMinWidth
        cell?.assignmentDueMinWidth.constant = dateMinWidth

        cell?.assignment = assignment
        
        return cell!
    }
    
    func updateAssignmentCell(assignment: Assignment, cell: AssignmentTableViewCell) {
        cell.assignmentStatus.text = assignment.assignmentStatus.statusString
        cell.assignmentStatus.textColor = assignment.assignmentStatus.statusColor
        Browser().updateAssignmentStatus(assignment: assignment)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! AssignmentTableViewCell
        let assignment = self.assignments[indexPath.row]
        
        let toDoAction = UITableViewRowAction(style: .normal, title: "To Do")
        { rowAction, indexPath in
            print("TO DO \(assignment.assignmentIndexID)")
            assignment.assignmentStatus = Assignment.ToDo
            self.updateAssignmentCell(assignment: assignment, cell: cell)
        }
        toDoAction.backgroundColor = Assignment.toDoColor
        let inProgressAction = UITableViewRowAction(style: .normal, title: "In Progress")
        { rowAction, indexPath in
            print("IN PROG \(assignment.assignmentIndexID)")
            assignment.assignmentStatus = Assignment.InProgress
            self.updateAssignmentCell(assignment: assignment, cell: cell)

        }
        inProgressAction.backgroundColor = Assignment.inProgressColor
        let completedAction = UITableViewRowAction(style: .normal, title: "Completed")
        { rowAction, indexPath in
            print("COMP \(assignment.assignmentIndexID)")
            assignment.assignmentStatus = Assignment.Completed
            self.updateAssignmentCell(assignment: assignment, cell: cell)

        }
        completedAction.backgroundColor = Assignment.completedColor
        if assignment.assignmentStatus.statusCode != Assignment.Graded.statusCode {
            return [completedAction, inProgressAction, toDoAction]
        } else {
            return []
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("toasting")
        print(segue.destination)
        if let detailVC = segue.destination as? DetailViewController {
            print("YAMS")
            detailVC.assignment = (sender as! AssignmentTableViewCell).assignment
        }
    }
    

}

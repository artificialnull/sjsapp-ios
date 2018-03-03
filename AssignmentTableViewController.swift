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
    var titleDateFormatter: DateFormatter = DateFormatter()
    var chosenDate = Date()
    
    var viewBy = 2
    var futureOffsetDays = 0
    var sortingBy: ((Assignment, Assignment) -> Bool)?
    var sortingByIndex = 0
    
    var dateMinWidth: CGFloat = 0.0

    override func viewDidLoad() {

        super.viewDidLoad()
        
        titleDateFormatter.dateFormat = "E - MMM d, yyyy"
        
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
    
    @IBAction func nextDay() {
        chosenDate = Calendar.current.date(
            byAdding: .day, value: 1,
            to: chosenDate)!
        refresh()
    }
    
    @IBAction func previousDay() {
        chosenDate = Calendar.current.date(
            byAdding: .day, value: -1,
            to: chosenDate)!
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = false
        
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: self, action: nil))
        items.append(UIBarButtonItem(image: #imageLiteral(resourceName: "range"), style: .plain, target: self,
                                     action: #selector(showRangeMenu)))
        items.append(UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: self, action: nil))
        items.append(UIBarButtonItem(image: #imageLiteral(resourceName: "sorting"), style: .plain, target: self,
                                     action: #selector(showSortByMenu)))
        items.append(UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: self, action: nil))
        items.append(UIBarButtonItem(image: #imageLiteral(resourceName: "view"), style: .plain, target: self,
                                     action: #selector(showViewByMenu)))
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
            sortingBy = sortByDue(as1:as2:)
            sortingByIndex = 0
        case "Assigned"?:
            sortingBy = sortByAssigned(as1:as2:)
            sortingByIndex = 1
        case "Class"?:
            sortingBy = sortByClass(as1:as2:)
            sortingByIndex = 2
        default:
            print("wut wut in the")
            refresh()
        }
        refresh()
        
    }
    
    func refresh() {
        
        if !Browser().credentialsExist() {
            let noLogInIndicator = UILabel()
            noLogInIndicator.center = self.view.center
            noLogInIndicator.textAlignment = NSTextAlignment.center
            noLogInIndicator.text = "Sign in to load assignments"
            self.tableView.backgroundView = noLogInIndicator
        } else {
            self.tableView.backgroundView = activityIndicator
        }
        
        self.navigationItem.title = titleDateFormatter.string(from: chosenDate)

        activityIndicator.startAnimating()
        
        assignments = [Assignment]()
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
        let endDate = Calendar.current.date(byAdding: .day,
                                            value: futureOffsetDays,
                                            to: chosenDate)!
        Browser().getAssignmentJSON(startDate: chosenDate, endDate: endDate, viewBy: viewBy) { response in
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
                return self.sortingBy!(as1, as2)
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
            self.sortingBy = self.sortByDue(as1:as2:)
            self.sortingByIndex = 0
            self.refresh()
        }))
        alert.addAction(UIAlertAction(title: "Assigned", style: .default, handler: {_ in
            self.sortingBy = self.sortByAssigned(as1:as2:)
            self.sortingByIndex = 1
            self.refresh()
        }))
        alert.addAction(UIAlertAction(title: "Class", style: .default, handler: {_ in
            self.sortingBy = self.sortByClass(as1:as2:)
            self.sortingByIndex = 2
            self.refresh()
        }))
        
        alert.actions[sortingByIndex].setValue(true, forKey: "checked")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.view.tintColor = UIColor.red

        present(alert, animated: true, completion: nil)
    }
    
    @objc func showRangeMenu() {
        let alert = UIAlertController(title: "Show assignments for the next", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Day", style: .default, handler: {_ in
            self.futureOffsetDays = 0
            self.refresh()
        }))
        alert.addAction(UIAlertAction(title: "7 Days", style: .default, handler: {_ in
            self.futureOffsetDays = 7
            self.refresh()
        }))
        alert.addAction(UIAlertAction(title: "30 Days", style: .default, handler: {_ in
            self.futureOffsetDays = 30
            self.refresh()
        }))
        
        var checkedIndex = 0
        switch futureOffsetDays {
        case 0:
            checkedIndex = 0
        case 7:
            checkedIndex = 1
        case 30:
            checkedIndex = 2
        default:
            checkedIndex = 0
        }
        
        alert.actions[checkedIndex].setValue(true, forKey: "checked")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.view.tintColor = UIColor.red
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showViewByMenu() {
        let alert = UIAlertController(title: "View by", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Due", style: .default, handler: {_ in
            self.viewBy = 1
            self.refresh()
        }))
        alert.addAction(UIAlertAction(title: "Active", style: .default, handler: {_ in
            self.viewBy = 2
            self.refresh()
        }))
        alert.addAction(UIAlertAction(title: "Assigned", style: .default, handler: {_ in
            self.viewBy = 0
            self.refresh()
        }))
        
        print((viewBy + 2) % 3)
        alert.actions[(viewBy + 2) % 3].setValue(true, forKey: "checked")
        
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
        let overdueAction = UITableViewRowAction(style: .normal, title: "Overdue")
        { rowAction, indexPath in
            print("OVDU \(assignment.assignmentIndexID)")
            assignment.assignmentStatus = Assignment.Overdue
            self.updateAssignmentCell(assignment: assignment, cell: cell)
        }
        overdueAction.backgroundColor = Assignment.overdueColor
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
            return [completedAction, inProgressAction,
                    (assignment.assignmentDue.compare(Date()) == .orderedDescending)
                ? toDoAction : overdueAction
            ]
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
        self.navigationItem.title = "Assignments"
        print(segue.destination)
        if let detailVC = segue.destination as? DetailViewController {
            print("YAMS")
            detailVC.assignment = (sender as! AssignmentTableViewCell).assignment
        }
    }
    

}

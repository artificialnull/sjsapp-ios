//
//  DetailViewController.swift
//  sjsapp
//
//  Created by Ishan on 2/25/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var shortLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var assignedLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var statusButton: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    
    var assignment: Assignment?
    let fmt = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.navigationItem.title = "Details"
        if assignment?.assignmentStatus.statusCode == Assignment.Graded.statusCode {
            statusButton.removeAllSegments()
            statusButton.insertSegment(withTitle: "Graded", at: 0, animated: true)
            statusButton.subviews[0].tintColor = Assignment.Graded.statusColor
            statusButton.selectedSegmentIndex = 0
        } else if assignment?.assignmentStatus.statusCode == Assignment.Paused.statusCode {
            statusButton.removeAllSegments()
            statusButton.insertSegment(withTitle: "Paused", at: 0, animated: true)
            statusButton.subviews[0].tintColor = Assignment.Paused.statusColor
            statusButton.selectedSegmentIndex = 0
        } else {
            if assignment?.assignmentDue.compare(Date()) == .orderedDescending {
                (statusButton.subviews[2]).tintColor = Assignment.ToDo.statusColor
            } else {
                statusButton.removeSegment(at: 0, animated: true)
                statusButton.insertSegment(withTitle: "Overdue", at: 0, animated: true)
                statusButton.subviews[2].tintColor = Assignment.Overdue.statusColor
            }
            (statusButton.subviews[1]).tintColor = Assignment.InProgress.statusColor
            (statusButton.subviews[0]).tintColor = Assignment.Completed.statusColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
        
        fmt.dateFormat =
            ((UserDefaults().bool(forKey: "date8601")) ? "yyyy-MM-dd" : "M/d/yyyy") +
            ((UserDefaults().bool(forKey: "time24hr")) ? " HH:mm" : " h:mm aa")
        
        self.shortLabel.text = assignment?.assignmentShort.htmlToString
        self.classLabel.text = assignment?.assignmentClass
        self.assignedLabel.text = self.fmt.string(from: (assignment!.assignmentAssigned))
        self.dueLabel.text = self.fmt.string(from: (assignment!.assignmentDue))
        
        self.statusButton.selectedSegmentIndex = ((assignment?.assignmentStatus.statusCode)! + 1) % 3
        
        self.statusButton.addTarget(self, action: #selector(DetailViewController.statusChanged(_:)), for: .valueChanged)
        Browser().getFullAssignment(assignment: assignment!) { response in
            self.assignment = response
            self.tableView.reloadData()
        }
        
    }
    
    @objc func statusChanged(_ segControl: UISegmentedControl) {
        assignment?.assignmentStatus = Assignment().statusFromInt(status: segControl.selectedSegmentIndex - 1)
        Browser().updateAssignmentStatus(assignment: assignment!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DetailExtraCell"
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath) as? ExtraTableViewCell
        cell?.textLabel?.font = cell?.textLabel?.font.withSize(13.0)
        
        switch indexPath.section {
        case 2:
            cell?.extraLink = assignment?.assignmentLinks[indexPath.row].extraUrl
            cell?.textLabel?.text = assignment?.assignmentLinks[indexPath.row].extraTitle
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 1:
            cell?.extraLink = assignment?.assignmentDownloads[indexPath.row].extraUrl
            cell?.textLabel?.text = assignment?.assignmentDownloads[indexPath.row].extraTitle
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 0:
            cell?.textLabel?.text = assignment?.assignmentLong?.htmlToString
            cell?.textLabel?.numberOfLines = 0
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
        default:
            return cell!
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Info"
        case 1:
            return "Downloads"
        case 2:
            return "Links"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return (assignment?.assignmentLinks.count)!
        case 1:
            return (assignment?.assignmentDownloads.count)!
        case 0:
            if assignment?.assignmentLong?.count != 0 && !(assignment?.assignmentLong ?? "").isEmpty {
                return 1
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let cell = tableView.cellForRow(at: indexPath) as? ExtraTableViewCell
            cell?.accessoryType = UITableViewCellAccessoryType.none
            
            let indicator = UIActivityIndicatorView()
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            indicator.startAnimating()
            cell?.accessoryView = indicator
            
            Browser().downloadFile(
            download: (assignment?.assignmentDownloads[indexPath.row])!) {
                response in
                cell?.accessoryView = nil
                cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                if response != nil {
                    let evc = self.storyboard!
                        .instantiateViewController(withIdentifier: "ExtraVC") as! ExtraViewController
                    evc.file = (response?.destinationURL)
                    evc.name = (self.assignment?.assignmentDownloads[indexPath.row])?.extraTitle
                    self.navigationController?.pushViewController(evc, animated: true)
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)

        case 2:
            let evc = self.storyboard!
                .instantiateViewController(withIdentifier: "ExtraVC") as! ExtraViewController
            evc.url = URL(string: (assignment?.assignmentLinks[indexPath.row].extraUrl)!)
            evc.name = assignment?.assignmentLinks[indexPath.row].extraTitle
            self.navigationController?.pushViewController(evc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)

        default:
            return
        }
    }
    
}

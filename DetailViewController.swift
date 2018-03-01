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
        fmt.dateFormat = "M/d/yyyy HH:mm"
        self.navigationItem.title = "Details"
        if assignment?.assignmentStatus.statusCode != Assignment.Graded.statusCode {
            (statusButton.subviews[2]).tintColor = Assignment.toDoColor
            (statusButton.subviews[1]).tintColor = Assignment.inProgressColor
            (statusButton.subviews[0]).tintColor = Assignment.completedColor
        } else {
            statusButton.removeAllSegments()
            statusButton.insertSegment(withTitle: "Graded", at: 0, animated: true)
            statusButton.subviews[0].tintColor = Assignment.gradedColor
            statusButton.selectedSegmentIndex = 0
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.shortLabel.text = assignment?.assignmentShort.htmlToString
        self.classLabel.text = assignment?.assignmentClass
        self.assignedLabel.text = self.fmt.string(from: (assignment!.assignmentAssigned))
        self.dueLabel.text = self.fmt.string(from: (assignment!.assignmentDue))
        
        self.statusButton.selectedSegmentIndex = (assignment?.assignmentStatus.statusCode)! + 1
        
        self.statusButton.addTarget(self, action: #selector(DetailViewController.statusChanged(_:)), for: .valueChanged)
        Browser().getFullAssignment(assignment: assignment!) { response in
            print(response?.assignmentDownloads.count as Any)
            print(response?.assignmentLinks.count as Any)
            self.assignment = response
            print(self.tableView.bounds.height)
            self.tableView.reloadData()
        }
        
    }
    
    @objc func statusChanged(_ segControl: UISegmentedControl) {
        assignment?.assignmentStatus = Assignment().statusFromInt(status: segControl.selectedSegmentIndex - 1)
        Browser().updateAssignmentStatus(assignment: assignment!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("YAZAAZ")
        let cellIdentifier = "DetailExtraCell"
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath) as? ExtraTableViewCell
        cell?.textLabel?.font = cell?.textLabel?.font.withSize(13.0)
        
        switch indexPath.section {
        case 2:
            //todo
            print("LANKS")
            cell?.extraLink = assignment?.assignmentLinks[indexPath.row].extraUrl
            cell?.textLabel?.text = assignment?.assignmentLinks[indexPath.row].extraTitle
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 1:
            print("donjons")
            cell?.extraLink = assignment?.assignmentDownloads[indexPath.row].extraUrl
            cell?.textLabel?.text = assignment?.assignmentDownloads[indexPath.row].extraTitle
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            //todo
        case 0:
            print("informing")
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
            print("we're in")
            return "Downloads"
        case 2:
            return "Links"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("bois")
        switch section {
        case 2:
            print("meems")
            print(assignment?.assignmentLinks.count)
            return (assignment?.assignmentLinks.count)!
        case 1:
            print("not meeming")
            print((assignment?.assignmentDownloads.count)!)
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
        print("le")
        return 3
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            Browser().downloadFile(
            download: (assignment?.assignmentDownloads[indexPath.row])!) {
                response in
                let evc = self.storyboard!
                    .instantiateViewController(withIdentifier: "ExtraVC") as! ExtraViewController
                evc.file = (response?.destinationURL)
                print(evc.file)
                evc.name = (self.assignment?.assignmentDownloads[indexPath.row])?.extraTitle
                self.navigationController?.pushViewController(evc, animated: true)
            }
        case 2:
            let evc = self.storyboard!
                .instantiateViewController(withIdentifier: "ExtraVC") as! ExtraViewController
            evc.url = URL(string: (assignment?.assignmentLinks[indexPath.row].extraUrl)!)
            evc.name = assignment?.assignmentLinks[indexPath.row].extraTitle
            self.navigationController?.pushViewController(evc, animated: true)
        default:
            return
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let extraVC = segue.destination as? ExtraViewController {
            extraVC.urlStr = (sender as? ExtraTableViewCell)?.extraLink
        }
    }
 
     */
    

}

//
//  ScheduleTableViewController.swift
//  sjsapp
//
//  Created by Ishan on 2/20/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController {

    var scheduledClasses = [ScheduledClass]()
    var activityIndicator: UIActivityIndicatorView!
    
    var chosenDate: Date = Date()
    var titleDateFormatter: DateFormatter = DateFormatter()
    
    var timeMinWidth: CGFloat = 0.0
    
    let fmt = DateFormatter()
    
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var titleForwardButton: UIBarButtonItem!
    @IBOutlet weak var titleBackwardButton: UIBarButtonItem!
    
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
        
        
        /*
        self.refreshControl = UIRefreshControl()
         if let refreshControl = self.refreshControl {
            refreshControl.addTarget(self,
                                     action: #selector(
                                        ScheduleTableViewController.refreshSchedule),
                                     for: UIControlEvents.valueChanged)
        }*/
        //Browser().setCredentials(username: "ikamat", password: "2080tPXK")
    }
    
    func yaz() {
        print("YaZ")
    }
    
    func refresh() {
        
        if !Browser().credentialsExist() {
            let noLogInIndicator = UILabel()
            noLogInIndicator.center = self.view.center
            noLogInIndicator.textAlignment = NSTextAlignment.center
            noLogInIndicator.text = "Sign in to load schedule"
            self.tableView.backgroundView = noLogInIndicator
        } else {
            self.tableView.backgroundView = activityIndicator
        }
        
        scheduledClasses = [ScheduledClass]()
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
        activityIndicator.startAnimating()
        
        titleBar.title = titleDateFormatter.string(from: chosenDate)
        
        Browser().getScheduleJSON(date: chosenDate) { response in
            self.scheduledClasses = response!
            for scheduledClass in self.scheduledClasses {
                let startTimeStr = self.fmt.string(from: scheduledClass.classStart)
                let endTimeStr = self.fmt.string(from: scheduledClass.classEnd)
                let startTimeWidth = startTimeStr.width(
                    withConstrainedHeight: 99,
                    font: UIFont.systemFont(ofSize: 13.0)
                )
                let endTimeWidth = endTimeStr.width(
                    withConstrainedHeight: 99,
                    font: UIFont.systemFont(ofSize: 13.0)
                )
                if startTimeWidth > self.timeMinWidth {
                    self.timeMinWidth = startTimeWidth
                }
                if endTimeWidth > self.timeMinWidth {
                    self.timeMinWidth = endTimeWidth
                }
            }
            print(self.timeMinWidth)
            if self.scheduledClasses.count > 0 {
                self.activityIndicator.stopAnimating()
                self.tableView.separatorStyle = .singleLine
            } else {
                let noClassesIndicator = UILabel()
                noClassesIndicator.center = self.view.center
                noClassesIndicator.textAlignment = NSTextAlignment.center
                noClassesIndicator.text = "Nothing scheduled on this day"
                self.tableView.backgroundView = noClassesIndicator
            }
            self.tableView.reloadData()
        }
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
        fmt.dateFormat = (UserDefaults().bool(forKey: "time24hr"))
            ? "HH:mm" : "h:mm aa"
        timeMinWidth = 0.0
        super.viewWillAppear(animated)
        scheduledClasses = [ScheduledClass]()
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refresh()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    /*
    @objc func refreshSchedule() {
        Browser().getScheduleJSON(date: Date()) { response in
            self.scheduledClasses = response!
            for scheduledClass in self.scheduledClasses {
                print(scheduledClass.className)
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (scheduledClasses.count == 0) ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scheduledClasses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ClassTableViewCell"
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath) as? ClassTableViewCell
        
        let scheduledClass = scheduledClasses[indexPath.row]
        
        cell?.classStartLabel.text   = fmt.string(from: scheduledClass.classStart)
        cell?.classEndLabel.text     = fmt.string(from: scheduledClass.classEnd)
        cell?.classNameLabel.text    = scheduledClass.className
        cell?.classTeacherLabel.text = scheduledClass.classTeacher
        cell?.classBlockLabel.text   = scheduledClass.classBlock
        cell?.classRoomLabel.text    = scheduledClass.classRoom
        
        cell?.classStartMinWidth.constant = timeMinWidth
        cell?.classEndMinWidth.constant   = timeMinWidth
        
        // Configure the cell...
        
        return cell!
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

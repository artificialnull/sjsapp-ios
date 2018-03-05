//
//  SettingsTableViewController.swift
//  sjsapp
//
//  Created by Ishan on 3/2/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit
import KeychainSwift

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var timeFormatSwitch: UISwitch!
    @IBOutlet weak var dateFormatSwitch: UISwitch!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    let prefs = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeFormatSwitch.isOn = prefs.bool(forKey: "time24hr")
        dateFormatSwitch.isOn = prefs.bool(forKey: "date8601")
        sortLabel.text = prefs.string(forKey: "assignmentSort")
        viewLabel.text = viewByIntToStr(code: prefs.integer(forKey: "assignmentView"))
        dayLabel.text = "\(prefs.integer(forKey: "assignmentRange")) Days"
        if dayLabel.text == "0 Days" {
            dayLabel.text = "1 Day"
        }
        refresh()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func viewByIntToStr(code: Int) -> String {
        switch code {
        case 0:
            return "Assigned"
        case 1:
            return "Due"
        case 2:
            return "Active"
        default:
            return "(none)"
        }
    }
    
    @IBAction func timeSwitchChanged() {
        print("wahoo")
        prefs.set(timeFormatSwitch.isOn, forKey: "time24hr")
    }
    
    @IBAction func dateSwitchChanged() {
        prefs.set(dateFormatSwitch.isOn, forKey: "date8601")
    }
    
    func refresh() {
        if usernameLabel != nil {
            usernameLabel.text = KeychainSwift().get("username") ?? "(none)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 1:
            return 4
        case 2:
            return 2
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1:
                let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Due", style: .default, handler: {_ in
                    self.prefs.set("Due", forKey: "assignmentSort")
                    self.sortLabel.text = self.prefs.string(forKey: "assignmentSort")
                }))
                alert.addAction(UIAlertAction(title: "Assigned", style: .default, handler: {_ in
                    self.prefs.set("Assigned", forKey: "assignmentSort")
                    self.sortLabel.text = self.prefs.string(forKey: "assignmentSort")
                }))
                alert.addAction(UIAlertAction(title: "Class", style: .default, handler: {_ in
                    self.prefs.set("Class", forKey: "assignmentSort")
                    self.sortLabel.text = self.prefs.string(forKey: "assignmentSort")
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.view.tintColor = UIColor.red
                
                present(alert, animated: true, completion: nil)
            case 0:
                let alert = UIAlertController(title: "View by", message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Due", style: .default, handler: {_ in
                    self.prefs.set(1, forKey: "assignmentView")
                    self.viewLabel.text = self.viewByIntToStr(code: self.prefs.integer(forKey: "assignmentView"))
                }))
                alert.addAction(UIAlertAction(title: "Active", style: .default, handler: {_ in
                    self.prefs.set(2, forKey: "assignmentView")
                    self.viewLabel.text = self.viewByIntToStr(code: self.prefs.integer(forKey: "assignmentView"))
                }))
                alert.addAction(UIAlertAction(title: "Assigned", style: .default, handler: {_ in
                    self.prefs.set(0, forKey: "assignmentView")
                    self.viewLabel.text = self.viewByIntToStr(code: self.prefs.integer(forKey: "assignmentView"))
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.view.tintColor = UIColor.red
                
                present(alert, animated: true, completion: nil)
            case 2:
                let alert = UIAlertController(title: "Show assignments for the next", message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Day", style: .default, handler: {_ in
                    self.prefs.set(0, forKey: "assignmentRange")
                    self.dayLabel.text = "1 Day"
                }))
                alert.addAction(UIAlertAction(title: "7 Days", style: .default, handler: {_ in
                    self.prefs.set(7, forKey: "assignmentRange")
                    self.dayLabel.text = "\(self.prefs.integer(forKey: "assignmentRange")) Days"
                }))
                alert.addAction(UIAlertAction(title: "30 Days", style: .default, handler: {_ in
                    self.prefs.set(30, forKey: "assignmentRange")
                    self.dayLabel.text = "\(self.prefs.integer(forKey: "assignmentRange")) Days"
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.view.tintColor = UIColor.red
                present(alert, animated: true, completion: nil)
            default:
                break
            }
            
        } else if indexPath.section == 2 && indexPath.row == 1 {
            print("no meems")
            let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {_ in
                let keychain = KeychainSwift()
                keychain.delete("username")
                keychain.delete("password")
                Browser().clearCredentials()
                self.refresh()
                (self.tabBarController as! MainViewController).askForCredentials()
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.view.tintColor = UIColor.red

            present(alert, animated: true, completion: nil)

        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

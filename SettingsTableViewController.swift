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
    
    let prefs = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeFormatSwitch.isOn = prefs.bool(forKey: "time24hr")
        dateFormatSwitch.isOn = prefs.bool(forKey: "date6601")
        sortLabel.text = prefs.string(forKey: "assignmentSort")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func timeSwitchChanged() {
        print("wahoo")
        prefs.set(timeFormatSwitch.isOn, forKey: "time24hr")
    }
    
    @IBAction func dateSwitchChanged() {
        prefs.set(dateFormatSwitch.isOn, forKey: "date8601")
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
            return 2
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Due", style: .default,
                                          handler: {_ in
                self.prefs.set("Due", forKey: "assignmentSort")
                self.sortLabel.text = self.prefs.string(forKey: "assignmentSort")
            }))
            alert.addAction(UIAlertAction(title: "Assigned", style: .default,
                                          handler: {_ in
                self.prefs.set("Assigned", forKey: "assignmentSort")
                self.sortLabel.text = self.prefs.string(forKey: "assignmentSort")
            }))
            alert.addAction(UIAlertAction(title: "Class", style: .default,
                                          handler: {_ in
                self.prefs.set("Class", forKey: "assignmentSort")
                self.sortLabel.text = self.prefs.string(forKey: "assignmentSort")
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.view.tintColor = UIColor.red
            
            present(alert, animated: true, completion: nil)
            
        } else if indexPath.section == 2 && indexPath.row == 0 {
            print("no meems")
            let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {_ in
                let keychain = KeychainSwift()
                keychain.delete("username")
                keychain.delete("password")
                Browser().clearCredentials()
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

//
//  MainViewController.swift
//  sjsapp
//
//  Created by Ishan on 2/21/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit
import KeychainSwift

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let prefs = UserDefaults()
        
        if !prefs.bool(forKey: "hasLaunchedBefore") {
            prefs.set(true, forKey: "hasLaunchedBefore")
            prefs.set(false, forKey: "time24hr")
            prefs.set(false, forKey: "date8601")
            prefs.set("Due", forKey: "assignmentSort")
            prefs.set(1, forKey: "assignmentView")
            prefs.set(0, forKey: "assignmentRange")
        }


        // Do any additional setup after loading the view.
    }
    
    func askForCredentials() {
        let alertController = UIAlertController(
            title: "Sign In",
            message: nil,
            preferredStyle: .alert
        )
        alertController.view.tintColor = UIColor.red
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                
                let un = (alertController.textFields![0] as UITextField).text
                let pw = (alertController.textFields![1] as UITextField).text
                
                if (un?.isEmpty)! || (pw?.isEmpty)! {
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                print(un)
                print(pw)
                
                Browser().clearCredentials()
                
                Browser().setCredentials(username: un!, password: pw!)

                Browser().checkLogIn() { response in
                    print("did this work?:")
                    print(response)
                    if response {
                        print("worked")
                        let keychain = KeychainSwift()

                        keychain.set(un!, forKey: "username")
                        keychain.set(pw!, forKey: "password")
                        
                        self.refreshSchedule()
                        self.refreshSettings()
                    } else {
                        print("naz work")
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
        }
            )
        )
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Username"
        }
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let keychain = KeychainSwift()
        let username = keychain.get("username")
        let password = keychain.get("password")
        
        print("USERNAME:")
        print(username as Any)
        
        if username == nil || password == nil {
            askForCredentials()
        } else {
            Browser().setCredentials(username: username!, password: password!)
            refreshSchedule()
        }
        
    }
    
    func refreshSchedule() {
        for child in self.childViewControllers {
            if let nav = child as? UINavigationController {
                for kid in nav.childViewControllers {
                    if let sched = kid as? ScheduleTableViewController {
                        sched.refresh()
                    }
                }
            }
        }
    }
    
    func refreshSettings() {
        for child in self.childViewControllers {
            if let nav = child as? UINavigationController {
                for kid in nav.childViewControllers {
                    if let sett = kid as? SettingsTableViewController {
                        sett.refresh()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

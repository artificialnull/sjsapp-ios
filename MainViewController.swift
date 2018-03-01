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
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let keychain = KeychainSwift()
        let username = keychain.get("username")
        let password = keychain.get("password")
        
        print("USERNAME:")
        print(username as Any)
        
        if username == nil || password == nil {
            let alertController = UIAlertController(
                title: "Sign in",
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
                    Browser().setCredentials(username: un!, password: pw!)
                    Browser().checkLogIn() { response in
                        if response {
                            keychain.set(un!, forKey: "username")
                            keychain.set(pw!, forKey: "password")
                            
                            self.refreshSchedule()
                        } else {
                            print("NAAZ")
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
                        print("YAZZ")
                        
                        
                        
                        sched.refresh()
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

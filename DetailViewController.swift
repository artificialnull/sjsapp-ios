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
    
    var assignment: Assignment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

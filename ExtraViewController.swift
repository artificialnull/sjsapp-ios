//
//  ExtraViewController.swift
//  sjsapp
//
//  Created by Ishan on 2/28/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit
import WebKit

class ExtraViewController: UIViewController, WKUIDelegate {
    @IBOutlet var webView: WKWebView!
    
    var url: URL?
    var file: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if file != nil {
            webView.loadFileURL(file!, allowingReadAccessTo: file!)
        } else if url != nil {
            webView.load(URLRequest(url: url!))
        }
        // Do any additional setup after loading the view.
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

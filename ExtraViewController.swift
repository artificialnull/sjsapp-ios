//
//  ExtraViewController.swift
//  sjsapp
//
//  Created by Ishan on 2/28/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class ExtraViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    
    var url: URL?
    var file: URL?
    
    var name: String?
    
    @objc func openExternally() {
        print("boi")
        let toOpen = file ?? url ?? URL(string: "")
        let svc = SFSafariViewController(url: toOpen!)
        present(svc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = name
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action,
                            target: self,
                            action: #selector(ExtraViewController.openExternally))
        let toOpen = file ?? url ?? URL(string: "")
        self.navigationItem.rightBarButtonItem?.isEnabled =
            (toOpen?.scheme == "http" || toOpen?.scheme == "https")
        
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

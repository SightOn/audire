//
//  HelpViewController.swift
//  SightOnMock
//
//  Created by inatani soichiro on 2017/10/26.
//  Copyright © 2017年 inai17ibar. All rights reserved.
//

import UIKit

class HelpViewController: ViewController, UIWebViewDelegate {

    @IBOutlet weak var helpWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.helpWebView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        let favoriteURL = NSURL(string: "https://sighton.github.io/manual/")

        let urlRequest = NSURLRequest(url: favoriteURL! as URL)
        self.helpWebView.loadRequest(urlRequest as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  ViewController.swift
//  LottieRefresh
//
//  Created by vvveiii on 2019/3/30.
//  Copyright © 2019 lvv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tableView: LOTTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "WebView", style: .plain, target: self, action: #selector(testWebView(sender:)))

        tableView = LOTTableView(frame: self.view.bounds, style: .plain)
        tableView.addRefresh { (completion) -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                completion()
            })
        }
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: tableView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView!, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
            ])
    }

    @objc func testWebView(sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(WKWebViewController(), animated: true)
    }
}


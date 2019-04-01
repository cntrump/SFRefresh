//
//  WKWebViewController.swift
//  LottieRefresh
//
//  Created by vvveiii on 2019/3/31.
//  Copyright © 2019 lvv. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: self.view.bounds)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: webView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
            ])

        webView.scrollView.SFaddRefresh { () -> SFRefreshView? in
            let refreshView = LOTRefreshView(name: "4497-pull-to-refresh")
            refreshView.refreshHandler = { [weak self] _ in
                self?.reloadPage()
            }
            return refreshView
        }

        webView.load(URLRequest(url: URL(string: "https://www.apple.com")!))
    }

    func reloadPage() {
        webView.reload()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.SFrefreshView?.stopRefresh()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.scrollView.SFrefreshView?.stopRefresh()
    }
}

//
//  WebviewCheckout.swift
//  TamaraSDK
//
//  Created by Admin on 10/24/20.
//  Copyright © 2020 Tamara. All rights reserved.
//

import Foundation
import WebKit
import UIKit
import SwiftUI

public protocol TamaraCheckoutDelegate {

    /// Called if the response is successful
    func onSuccessfull()

    /// Called if the response is unsuccesful
    func onFailured()
    
    /// Called if the response is cancel
    func onCancel()
}

public class TamaraSDKCheckout: UIViewController, WKUIDelegate {
    private var webView: WKWebView!
    private var url: String!
    public var delegate: TamaraCheckoutDelegate!
    
    private var successUrl: String!
    private var failedUrl: String!
    private var cancelUrl: String!
    
    public init(url: String,merchantURL: TamaraMerchantURL) {
        self.url =  url
        self.successUrl = merchantURL.success
        self.failedUrl = merchantURL.failure
        self.cancelUrl = merchantURL.cancel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    /// Returns an object initialized from data in a given unarchiver.
    required public init?(coder aDecoder: NSCoder) {
        successUrl = ""
        failedUrl = ""
        cancelUrl = ""
        super.init(coder: aDecoder)
    }
    
    /// Creates the view that the controller manages.
    public override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }

    /// Called after the controller's view is loaded into memory.
    public override func viewDidLoad() {
        super.viewDidLoad()

        guard let authUrl = url else { return }
        let myURL = URL(string: authUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(myRequest)
    }
    
    private func shouldDismiss(absoluteUrl: URL) {
        if absoluteUrl.absoluteString.contains(self.successUrl) {
            // success url, dismissing the page with the payment token
            self.dismiss(animated: true) {
                self.delegate?.onSuccessfull()
            }
        } else {
            // fail url, dismissing the page
            self.dismiss(animated: true) {
                self.delegate?.onFailured()
            }
        }
    }
}

extension TamaraSDKCheckout: WKNavigationDelegate {
    // Called when an error occurs during navigation
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let alertVC = UIAlertController(title: nil, message: "Something went wrong", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alertVC.addAction(okAction)
        
        self.present(alertVC, animated: true)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return
        }
        
        if url.absoluteString.contains(self.successUrl) {
            self.delegate?.onSuccessfull()
        }
        
        if url.absoluteString.contains(self.failedUrl) {
            self.delegate?.onFailured()
        }
        
        if url.absoluteString.contains(self.cancelUrl) {
            self.delegate?.onCancel()
        }

        decisionHandler(.allow)
    }
}


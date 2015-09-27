//
//  TravelerOAuthViewController.swift
//  Traveler
//
//  Created by Renzo Crisostomo on 26/09/15.
//  Copyright © 2015 Ruenzuo.io. All rights reserved.
//

import UIKit

public protocol TravelerOAuthViewControllerDelegate {

    func viewControllerDidFinishAuthorization(viewController: TravelerOAuthViewController)
    func viewController(viewController: TravelerOAuthViewController, didFinishAuthorizationWithError error:NSError)

}

public class TravelerOAuthViewController: UIViewController, UIWebViewDelegate {

    let webView: UIWebView;
    let PSNAuthorize = "https://auth.api.sonyentertainmentnetwork.com/2.0/oauth/authorize?response_type=code&client_id=78420c74-1fdf-4575-b43f-eb94c7d770bf&redirect_uri=https%3a%2f%2fwww.bungie.net%2fen%2fUser%2fSignIn%2fPsnid&scope=psn:s2s&request_locale=en"
    let PSNLogin = "https://auth.api.sonyentertainmentnetwork.com/login.jsp"

    public var delegate: TravelerOAuthViewControllerDelegate?

    // MARK: - Override

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        webView = UIWebView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    public override func loadView() {
        self.title = "Login"
        let backgroundView = UIView()
        backgroundView.backgroundColor = .whiteColor()
        webView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(webView)
        let topConstraint = NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: backgroundView, attribute: .Top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: webView, attribute: .Left, relatedBy: .Equal, toItem: backgroundView, attribute: .Left, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: backgroundView, attribute: .Bottom, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: webView, attribute: .Right, relatedBy: .Equal, toItem: backgroundView, attribute: .Right, multiplier: 1, constant: 0)
        backgroundView.addConstraints([topConstraint, leftConstraint, bottomConstraint, rightConstraint])

        self.view = backgroundView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        retrieveCookies()
    }

    // MARK: - Private

    func retrieveCookies() {
        guard let authorizeURL = NSURL(string: PSNAuthorize) else {
            notifyWrongURL()
            return
        }
        let authorizeRequest = NSURLRequest(URL: authorizeURL)
        let session = NSURLSession.sharedSession()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let task = session.dataTaskWithRequest(authorizeRequest) { (data, response, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let _ = error {
                self.notifyRequestFailed()
            } else {
                self.login()
            }
        }
        task.resume()
    }

    func login() {
        guard let loginURL = NSURL(string: PSNLogin) else {
            notifyWrongURL()
            return
        }
        let loginRequest = NSURLRequest(URL: loginURL)
        webView.loadRequest(loginRequest)
    }

    func notifyWrongURL() {
        let error = Traveler.wrongURLErrorWithDomain(TravelerConstants.ErrorDomain.Authorization)
        self.delegate?.viewController(self, didFinishAuthorizationWithError: error)
    }

    func notifyCookiesNotFound() {
        let error = Traveler.cookiesNotFoundErrorWithDomain(TravelerConstants.ErrorDomain.Authorization)
        self.delegate?.viewController(self, didFinishAuthorizationWithError: error)
    }

    func notifyRequestFailed() {
        let error = Traveler.requestFailedErrorWithDomain(TravelerConstants.ErrorDomain.Authorization)
        self.delegate?.viewController(self, didFinishAuthorizationWithError: error)
    }

    func validateCookies() {
        guard let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies else {
            notifyCookiesNotFound()
            return
        }
        var bungledFound = false
        var bundleatkFound = false
        for cookie in cookies {
            switch cookie.name {
            case "bungled": bungledFound = true
            case "bungleatk": bundleatkFound = true
            default: continue
            }
        }
        if (bungledFound && bundleatkFound) {
            self.delegate?.viewControllerDidFinishAuthorization(self)
        } else {
            notifyCookiesNotFound()
        }
    }

    // MARK: - UIWebViewDelegate

    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL?.host == "auth.api.sonyentertainmentnetwork.com" &&
            request.URL?.path == "/login.do" &&
            navigationType == .FormSubmitted {
                webView.hidden = true
        }
        return true
    }

    public func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if webView.request?.URL?.host == "www.bungie.net" {
            validateCookies()
        }
        if webView.request?.URL?.query == "authentication_error=true" {
            webView.hidden = false
        }
    }

    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if error?.code == NSURLErrorCancelled {
            return
        }
        notifyRequestFailed()
    }

}
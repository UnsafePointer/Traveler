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
    let PSNLogin = "https://auth.api.sonyentertainmentnetwork.com/login.do"

    public var delegate: TravelerOAuthViewControllerDelegate?

    // MARK: - Override

    public required init?(coder aDecoder: NSCoder) {
        webView = UIWebView()
        super.init(coder: aDecoder)
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
        self.view = webView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        retrieveCookies()
    }

    // MARK - Private

    func retrieveCookies() {
        guard let authorizeURL = NSURL(string: PSNAuthorize) else {
            notifyWrongURL()
            return
        }
        let authorizeRequest = NSURLRequest(URL: authorizeURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(authorizeRequest) { (data, response, error) in
            self.login()
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
        let error = NSError(domain: TravelerConstants.ErrorDomain.Authorization,
            code: TravelerConstants.ErrorCode.WrongURL,
            userInfo: ["NSLocalizedDescriptionKey" : "URL couldn't be initialised"])
        self.delegate?.viewController(self, didFinishAuthorizationWithError: error)
    }

    func notifyCookiesNotFound() {
        let error = NSError(domain: TravelerConstants.ErrorDomain.Authorization,
            code: TravelerConstants.ErrorCode.CookiesNotFound,
            userInfo: ["NSLocalizedDescriptionKey" : "Couldn't find cookies in shared store"])
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

    public func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    public func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        validateCookies()
    }

}
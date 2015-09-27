//
//  ViewController.swift
//  TravelerExample
//
//  Created by Renzo Crisostomo on 26/09/15.
//  Copyright © 2015 Ruenzuo.io. All rights reserved.
//

import UIKit
import Traveler

class ViewController: UIViewController, TravelerOAuthViewControllerDelegate {

    @IBOutlet var messageLabel: UILabel?

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private

    @IBAction func login() {
        let authViewController = TravelerOAuthViewController()
        authViewController.delegate = self
        self.navigationController?.pushViewController(authViewController, animated: true)
    }

    // MARK: - TravelerOAuthViewControllerDelegate

    func viewControllerDidFinishAuthorization(viewController: TravelerOAuthViewController) {
        self.navigationController?.popToRootViewControllerAnimated(true)
        Traveler.currentUserWithCompletion { (maybeCurrentUser, error) in
            guard let currentUser = maybeCurrentUser else {
                return
            }
            guard let response: NSDictionary = currentUser["Response"] as? NSDictionary else {
                return
            }
            guard let user: NSDictionary = response["user"] as? NSDictionary else {
                return
            }
            guard let displayName: String = user["displayName"] as? String else {
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.messageLabel?.text = "Welcome \(displayName)"
            }
        }
    }

    func viewController(viewController: TravelerOAuthViewController, didFinishAuthorizationWithError error:NSError) {
        let localizedDescription = error.userInfo["NSLocalizedDescriptionKey"]
        print("\(localizedDescription)")
    }

}


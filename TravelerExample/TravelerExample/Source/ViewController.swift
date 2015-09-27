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
        do {
            try Traveler.currentUserWithCompletion { (user) in
                print("\(user)")
            }
        } catch {
            print("Whoops")
        }
    }

    func viewController(viewController: TravelerOAuthViewController, didFinishAuthorizationWithError error:NSError) {
        let localizedDescription = error.userInfo["NSLocalizedDescriptionKey"]
        print("\(localizedDescription)")
    }

}


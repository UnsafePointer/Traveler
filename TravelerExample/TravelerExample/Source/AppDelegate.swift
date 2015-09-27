//
//  AppDelegate.swift
//  TravelerExample
//
//  Created by Renzo Crisostomo on 26/09/15.
//  Copyright © 2015 Ruenzuo.io. All rights reserved.
//

import UIKit
import Traveler

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Traveler.APIKey = ""
        return true
    }

}


//
//  AppDelegate.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 29.06.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    Fabric.with([Crashlytics.self])
    return true
  }


}


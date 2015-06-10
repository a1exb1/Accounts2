//
//  AppDelegate.swift
//  Accounts
//
//  Created by Alex Bechmann on 05/06/2015.
//  Copyright (c) 2015 Alex Bechmann. All rights reserved.
//

import UIKit
import ABToolKit
import SwiftyUserDefaults

var kActiveUser = User()

let kViewBackgroundColor = UIColor(hex: "333333")
let kTableViewSeperatorColor = UIColor(hex: "222222")

let kTableViewCellBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
let kTableViewCellTextColor = UIColor.whiteColor()
let kTableViewCellDetailTextColor = UIColor.lightGrayColor()

let kNavigationBarBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.85)

let kNavigationBarPositiveActionColor = UIColor.yellowColor()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Session.sharedSession().domain = "http://alex.bechmann.co.uk/iou"
        WebApiDefaults.sharedInstance().baseUrl = "\(Session.sharedSession().domain)/api"
        JSONMappingDefaults.sharedInstance().webApiSendDateFormat = DateFormat.DateTime.rawValue
        
        setupAppearances()
        
        if let user = User.userSavedOnDevice() {
            
            kActiveUser = user
        }
        else {
            
            setWindowToLogin()
        }
        
        return true
    }
    
    func setupAppearances() {
        
        UITableView.appearance().backgroundColor = kViewBackgroundColor
        UITableView.appearance().separatorColor = kTableViewSeperatorColor
        
        UITableViewCell.appearance().backgroundColor = kTableViewCellBackgroundColor
        UITableViewCell.appearance().textLabel?.textColor = kTableViewCellTextColor
        
        UINavigationBar.appearance().tintColor = UIColor.redColor()
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(kNavigationBarBackgroundColor, size: CGSize(width: 10, height: 10)), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        
        FormViewTextFieldCell.appearance().textLabel?.textColor = UIColor.whiteColor()
    }
    
    private func setWindowToLogin() {
        
        let bounds: CGRect = UIScreen.mainScreen().bounds
        window = UIWindow(frame: bounds)
        window?.rootViewController = UIStoryboard.initialViewControllerFromStoryboardNamed("Login")
        window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


//
//  AppDelegate.swift
//  olxItems
//
//  Created by Daniel Torres on 6/24/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import UIKit
import Cache

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var customCache : HybridCache?
    
    
    func prepareCache(){
        let config = Config(
            // Expiry date that will be applied by default for every added object
            // if it's not overridden in the add(key: object: expiry: completion:) method
            expiry: .date(Date().addingTimeInterval(100000)),
            /// The maximum number of objects in memory the cache should hold
            memoryCountLimit: 0,
            /// The maximum total cost that the cache can hold before it starts evicting objects
            memoryTotalCostLimit: 0,
            /// Maximum size of the disk cache storage (in bytes)
            maxDiskSize: 10000,
            // Where to store the disk cache. If nil, it is placed in an automatically generated directory in Caches
            cacheDirectory: NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask,
                                                                true).first! + "/cache-in-documents"
        )
        
        customCache = HybridCache(name: "ImageItems", config: config)
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        prepareCache()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


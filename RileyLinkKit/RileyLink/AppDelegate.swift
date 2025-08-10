import CoreData
import LoopKitUI
import RileyLinkKit
import SwiftUI
import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    private(set) lazy var deviceDataManager = DeviceDataManager()

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let navController = window?.rootViewController as? UINavigationController {
            let mainViewController = MainViewController(
                deviceDataManager: deviceDataManager,
                insulinTintColor: .orange,
                guidanceColors: GuidanceColors(acceptable: .primary, warning: .yellow, critical: .red)
            )
            navController.pushViewController(mainViewController, animated: false)
        }

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        NSLog(#function)
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSLog(#function)
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NSLog(#function)
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog(#function)
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSLog(#function)
    }

    // MARK: - 3D Touch

    func application(
        _: UIApplication,
        performActionFor _: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(false)
    }
}

private func applicationDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

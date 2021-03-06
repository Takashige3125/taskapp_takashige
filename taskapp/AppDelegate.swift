//
//  AppDelegate.swift
//  taskapp
//
//  Created by 秋山剛成 on 2021/03/15.
//

import UIKit
import UserNotifications
import RealmSwift
import Realm

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // ユーザに通知の許可を求める --- ここから ---
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    // Enable or disable features based on authorization
        } // --- ここまで追加 ---
        center.delegate = self
        
        var config = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion == 4) {}
        })
                
        Realm.Configuration.defaultConfiguration = config
        config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        return true
    }
    
    // アプリがフォアグラウンドの時に通知を受け取ると呼ばれるメソッド --- ここから ---
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .list, .sound])
    } // --- ここまで追加 ---

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


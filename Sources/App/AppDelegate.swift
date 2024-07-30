//
//  AppDelegate.swift
//  Pomodoro
//
//  Created by 전여훈 on 2023/11/02.
//  Copyright © 2023 io.hgu. All rights reserved.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let unNotificationCenter = UNUserNotificationCenter.current()
    let pomodoroTimeManager = PomodoroTimeManager.shared

    // MARK: Notification 함수

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
            } else if let error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }

        if let defaultFont = UIFont(name: "BMHANNA11yrsoldOTF", size: 17) {
            let attributes = [NSAttributedString.Key.font: defaultFont]
            UINavigationBar.appearance().titleTextAttributes = attributes
        }

        let resentRealmData = try? RealmService.read(Pomodoro.self).last
        if resentRealmData != nil {
            pomodoroTimeManager.restoreTimerInfo()
        }

        if UserDefaults.standard.object(forKey: "isFirstVisit") == nil {
            UserDefaults.standard.set(true, forKey: "isFirstVisit")
            Log.info(UserDefaults.standard.bool(forKey: "isFirstVisit"))
        } else {
            Log.info("Setting isFirstVisit")
            Log.info(UserDefaults.standard.bool(forKey: "isFirstVisit"))
        }

        return true
    }

    // MARK: 앱이 종료될 때 함수

    func applicationWillTerminate(_: UIApplication) {
        pomodoroTimeManager.saveTimerInfo()
    }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _: UIApplication,
        didDiscardSceneSessions _: Set<UISceneSession>
    ) {}
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.badge, .banner, .list])
    }
}

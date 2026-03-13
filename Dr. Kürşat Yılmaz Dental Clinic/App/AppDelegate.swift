//
//  DrKursatYilmazDentalClinicAppDelegate.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/4/26.
//

import UIKit
import Foundation
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupDependencyContainer()
        
        return true
    }
}

extension AppDelegate{
    
    func setupDependencyContainer() {
        FirebaseDIConfiguration.shared.configure()
        AppDIConfiguration.configure()
    }
    
}

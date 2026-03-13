//
//  DrKursatYilmazDentalClinicApp.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/4/26.
//

import SwiftUI

@main
struct DrKursatYilmazDentalClinicApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationVm: NotificationViewModel = NotificationViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .alertContainer()
                .toastContainer()
                .environmentObject(notificationVm)
        }
    }
}

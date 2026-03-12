//
//  DrKursatYilmazDentalClinicApp.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/4/26.
//

import SwiftUI

@main
struct DrKursatYilmazDentalClinicApp: App {
    
    @StateObject private var seeder = MockDataSeeder()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegateü
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
//                    try? await seeder.uploadPatients()
                }
        }
        
    }
}

//
//  DoctorsNavigationState 2.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/10/26.
//

import Combine
import SwiftUI
import Foundation

@MainActor
class ServiceNavigationState: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to destination: ServicesDestination) {
        path.append(destination)
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func goToRoot() {
        path.removeLast(path.count)
    }
}

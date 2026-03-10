//
//  AppointmentNavigationState.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/10/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class AppointmentNavigationState: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to destination: AppointmentsDestination) {
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

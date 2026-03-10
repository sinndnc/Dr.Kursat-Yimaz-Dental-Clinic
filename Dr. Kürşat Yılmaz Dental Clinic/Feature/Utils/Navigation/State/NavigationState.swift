//
//  NavigationState.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Combine
import SwiftUI

class AppNavigationState: ObservableObject {
    
    @Published var selectedTab: AppTab = .home
    
    @Published var homeNavPath = NavigationPath()
    @Published var doctorsNavPath = NavigationPath()
    @Published var profileNavPath = NavigationPath()
    @Published var servicesNavPath = NavigationPath()
    @Published var appointmentsNavPath = NavigationPath()
    
    func navigateToTab(_ tab: AppTab) {
        selectedTab = tab
    }
    
    func navigateToService(service: Service) {
        selectedTab = .services
        servicesNavPath = NavigationPath()
        servicesNavPath.append(ServicesDestination.serviceDetail(service: service))
    }
    
    func navigateToDoctor(id: String) {
        selectedTab = .doctors
        doctorsNavPath = NavigationPath()
        doctorsNavPath.append(DoctorsDestination.doctorDetail(id: id))
    }
    
    func navigateToSectionFromProfile(destination: ProfileDestination){
        profileNavPath = NavigationPath()
        profileNavPath.append(destination)
    }
    
    func clearAllPath(){
        homeNavPath = NavigationPath()
        doctorsNavPath = NavigationPath()
        profileNavPath = NavigationPath()
        servicesNavPath = NavigationPath()
        appointmentsNavPath = NavigationPath()
    }
}

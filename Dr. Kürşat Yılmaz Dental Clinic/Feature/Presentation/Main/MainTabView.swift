import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject private var navState: AppNavigationState
    
    @StateObject private var homeNavState: HomeNavigationState = HomeNavigationState()
    @StateObject private var profileNavState: ProfileNavigationState = ProfileNavigationState()
    @StateObject private var doctorsNavState: DoctorsNavigationState = DoctorsNavigationState()
    @StateObject private var servicesNavState: ServiceNavigationState = ServiceNavigationState()
    @StateObject private var appointmentNavState: AppointmentNavigationState = AppointmentNavigationState()
    
    @StateObject private var appointmentViewModel: AppointmentViewModel = AppointmentViewModel()
    
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $navState.selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: navState.selectedTab == .home ? "house.fill" : "house")
                        Text("Ana Sayfa")
                    }
                    .tag(AppTab.home)
                
                AppointmentsView()
                    .tabItem {
                        Image(systemName: navState.selectedTab == .appointments ? "calendar.circle.fill" : "calendar.circle")
                        Text("Randevular")
                    }
                    .tag(AppTab.appointments)
                
                ServicesView()
                    .tabItem {
                        Image(systemName: navState.selectedTab == .services ? "cross.circle.fill" : "cross.circle")
                        Text("Hizmetler")
                    }
                    .tag(AppTab.services)
                
                DoctorsView()
                    .tabItem {
                        Image(systemName: navState.selectedTab == .doctors ? "person.2.fill" : "person.2")
                        Text("Doktorlar")
                    }
                    .tag(AppTab.doctors)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: navState.selectedTab == .profile ? "person.fill" : "person")
                        Text("Profil")
                    }
                    .tag(AppTab.profile)
            }
            .environmentObject(homeNavState)
            .environmentObject(doctorsNavState)
            .environmentObject(profileNavState)
            .environmentObject(servicesNavState)
            .environmentObject(appointmentNavState)
            .environmentObject(appointmentViewModel)
        }
    }
    
}

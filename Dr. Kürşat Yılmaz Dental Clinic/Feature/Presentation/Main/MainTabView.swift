import SwiftUI

struct MainTabView: View {
    
    @State private var navState = AppNavigationState()
    
    @StateObject private var homeNavState: HomeNavigationState = HomeNavigationState()
    @StateObject private var profileNavState: ProfileNavigationState = ProfileNavigationState()
    @StateObject private var doctorsNavState: DoctorsNavigationState = DoctorsNavigationState()
    @StateObject private var servicesNavState: ServiceNavigationState = ServiceNavigationState()
    @StateObject private var appointmentNavState: AppointmentNavigationState = AppointmentNavigationState()
    
    @StateObject private var docVm = DoctorsViewModel()
    @StateObject private var serVm = ServicesViewModel()
    @StateObject private var profVm = ProfileViewModel()
    @StateObject private var aptVm = AppointmentViewModel()

    var body: some View {
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
        .environment(navState)
        .environmentObject(aptVm)
        .environmentObject(serVm)
        .environmentObject(docVm)
        .environmentObject(profVm)
        .environmentObject(homeNavState)
        .environmentObject(doctorsNavState)
        .environmentObject(profileNavState)
        .environmentObject(servicesNavState)
        .environmentObject(appointmentNavState)
        .fullScreenCover(item: $navState.authSheet) { sheet in
            AuthFlowView(initialSheet: sheet)
                .environment(navState)
        }
    }
    
}

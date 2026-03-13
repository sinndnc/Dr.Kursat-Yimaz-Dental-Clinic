import SwiftUI

struct MainTabView: View {
    
    @StateObject private var homeNavState: HomeNavigationState = HomeNavigationState()
    @StateObject private var profileNavState: ProfileNavigationState = ProfileNavigationState()
    @StateObject private var doctorsNavState: DoctorsNavigationState = DoctorsNavigationState()
    @StateObject private var servicesNavState: ServiceNavigationState = ServiceNavigationState()
    @StateObject private var appointmentNavState: AppointmentNavigationState = AppointmentNavigationState()
    
    
    @StateObject private var docVm = DoctorsViewModel()
    @StateObject private var serVm = ServicesViewModel()
    @StateObject private var profVm = ProfileViewModel()
    @StateObject private var aptVm = AppointmentViewModel()
    
    @Environment(AppNavigationState.self) private var appNav
    
    var body: some View {
        @Bindable var appNav = appNav
        TabView(selection: $appNav.selectedTab) {
            Tab("Ana Sayfa",systemImage: "house.fill",value: AppTab.home) {
                HomeView()
                    .environmentObject(homeNavState)
            }
            Tab("Randevular",systemImage: "calendar.circle.fill",value: AppTab.home) {
                AppointmentsView()
                    .environmentObject(appointmentNavState)
            }
            Tab("Hizmetler",systemImage: "cross.circle.fill",value: AppTab.home) {
                ServicesView()
                    .environmentObject(servicesNavState)
            }
            Tab("Doktorlar",systemImage: "person.2.fill",value: AppTab.home) {
                DoctorsView()
                    .environmentObject(doctorsNavState)
            }
            Tab("Profil",systemImage: "person.fill",value: AppTab.home) {
                ProfileView()
                    .environmentObject(profileNavState)
            }
        }
        .environmentObject(aptVm)
        .environmentObject(serVm)
        .environmentObject(docVm)
        .environmentObject(profVm)
        .fullScreenCover(item: $appNav.authSheet) { sheet in
            AuthFlowView(initialSheet: sheet)
                .environment(appNav)
        }
    }
    
}

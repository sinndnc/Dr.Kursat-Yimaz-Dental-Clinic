import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab = 0
    @EnvironmentObject var appState: AppState
    
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Ana Sayfa")
                    }
                    .tag(0)
                
                AppointmentsView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "calendar.circle.fill" : "calendar.circle")
                        Text("Randevular")
                    }
                    .tag(1)
                
                ServicesView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "cross.circle.fill" : "cross.circle")
                        Text("Hizmetler")
                    }
                    .tag(2)
                
                DoctorsView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "person.2.fill" : "person.2")
                        Text("Doktorlar")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                        Text("Profil")
                    }
                    .tag(4)
            }
        }
        .task {
            if let uid = appState.authService.uid {
                await appState.loadUserData(uid: uid)
                appState.startListeners(uid: uid)
            }
        }
    }
}

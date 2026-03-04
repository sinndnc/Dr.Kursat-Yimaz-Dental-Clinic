import SwiftUI

struct AuthView: View {
    @State private var showLogin = true
    
    var body: some View {
        Group {
            if showLogin {
                LoginView(showLogin: $showLogin)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            } else {
                RegisterView(showLogin: $showLogin)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showLogin)
    }
}

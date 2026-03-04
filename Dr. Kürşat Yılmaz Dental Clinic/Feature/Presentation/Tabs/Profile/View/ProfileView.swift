import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEditProfile = false
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    profileHeader
                    statsRow
                    menuSection(title: "Tıbbi Bilgiler", items: [
                        MenuItem(icon: "heart.text.square.fill", label: "Sağlık Kaydım",    color: .red),
                        MenuItem(icon: "cross.case.fill",        label: "Alerjiler",         color: .orange),
                        MenuItem(icon: "pill.fill",              label: "İlaçlar",           color: .purple),
                        MenuItem(icon: "doc.plaintext.fill",     label: "Tedavi Geçmişi",    color: .blue)
                    ])
                    menuSection(title: "Uygulama", items: [
                        MenuItem(icon: "bell.fill",              label: "Bildirimler",        color: .yellow),
                        MenuItem(icon: "lock.fill",              label: "Gizlilik",          color: .gray),
                        MenuItem(icon: "moon.fill",              label: "Koyu Mod",          color: .indigo),
                        MenuItem(icon: "globe",                  label: "Dil",               color: .green)
                    ])
                    menuSection(title: "Destek", items: [
                        MenuItem(icon: "questionmark.circle.fill", label: "S.S.S.",          color: .teal),
                        MenuItem(icon: "phone.fill",             label: "Bize Ulaşın",       color: .mint),
                        MenuItem(icon: "star.fill",              label: "Değerlendir",       color: .yellow),
                        MenuItem(icon: "square.and.arrow.up.fill", label: "Arkadaşına Öner", color: .blue)
                    ])
                    
                    // Logout
                    Button(action: { appState.logout() }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill").foregroundColor(.red)
                            Text("Çıkış Yap").font(.system(size: 16, weight: .semibold)).foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.red.opacity(0.08)).cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    
                    Text("DentCare v1.0.0 • Firebase").font(.system(size: 13)).foregroundColor(.secondary.opacity(0.6))
                        .padding(.bottom, 80)
                }
                .padding(.top, 20)
            }
            .sheet(isPresented: $showEditProfile) { EditProfileView() }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Profil").navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showEditProfile = true }) {
                        Text("Düzenle").font(.system(size: 15, weight: .semibold)).foregroundColor(primaryBlue)
                    }
                }
            }
        }
    }
    
    var profileHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [primaryBlue, Color(red: 0.05, green: 0.25, blue: 0.75)],
                                      startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().fill(Color.white.opacity(0.07)).frame(width: 150).offset(x: 120, y: -40)
            
            HStack(spacing: 18) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 80)
                    Image(systemName: "person.fill").font(.system(size: 36)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(appState.currentUser.name.isEmpty ? "—" : appState.currentUser.name)
                        .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                    Text(appState.currentUser.email.isEmpty ? "—" : appState.currentUser.email)
                        .font(.system(size: 14)).foregroundColor(.white.opacity(0.8))
                    Text(appState.currentUser.phone.isEmpty ? "—" : appState.currentUser.phone)
                        .font(.system(size: 14)).foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(24)
        }
        .padding(.horizontal, 20)
    }
    
    var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(appState.currentUser.totalVisits)", label: "Toplam\nZiyaret",  icon: "calendar.circle.fill", color: primaryBlue)
            statCard(value: "\(appState.currentUser.loyaltyPoints)", label: "Sadakat\nPuanı", icon: "star.circle.fill",    color: .orange)
            statCard(value: "\(appState.upcomingAppointments.count)", label: "Yaklaşan\nRandevu", icon: "clock.circle.fill", color: .purple)
        }
        .padding(.horizontal, 20)
    }
    
    func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(Color.white).shadow(color: .black.opacity(0.06), radius: 10, y: 3)
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 24)).foregroundColor(color)
                Text(value).font(.system(size: 22, weight: .bold, design: .rounded))
                Text(label).font(.system(size: 11)).foregroundColor(.secondary).multilineTextAlignment(.center)
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
    }
    
    func menuSection(title: String, items: [MenuItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.secondary).padding(.horizontal, 26)
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                    Button(action: {}) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 9).fill(item.color.opacity(0.12)).frame(width: 36, height: 36)
                                Image(systemName: item.icon).font(.system(size: 15)).foregroundColor(item.color)
                            }
                            Text(item.label).font(.system(size: 15)).foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(.secondary.opacity(0.5))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                    }
                    .buttonStyle(PlainButtonStyle())
                    if idx < items.count - 1 { Divider().padding(.leading, 66) }
                }
            }
            .background(Color.white).cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 10, y: 3).padding(.horizontal, 20)
        }
    }
}



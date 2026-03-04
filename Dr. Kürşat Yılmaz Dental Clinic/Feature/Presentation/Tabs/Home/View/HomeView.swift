import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showNewAppointment = false
    
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    private let tips = DentalTip.sampleData
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if appState.isLoadingData {
                        ProgressView("Yükleniyor...")
                    } else {
                        VStack(spacing: 24) {
                            nextAppointmentCard
                            quickActionsSection
                            healthScoreCard
                            dentalTipsSection
                            recentDoctorsSection
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("İyi Akşamlar 🌙")
            .navigationBarTitleDisplayMode(.inline)
            .navigationSubtitle(appState.currentUser.name.isEmpty ? "Hoşgeldiniz" : appState.currentUser.name)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NotificationsView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                            if appState.unreadNotificationCount > 0 {
                                ZStack {
                                    Circle().fill(Color.red).frame(width: 18, height: 18)
                                    Text("\(min(appState.unreadNotificationCount, 9))")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 6, y: -6)
                            }
                        }
                    }
                }
            }
            .refreshable {
                if let uid = appState.authService.uid {
                    await appState.loadUserData(uid: uid)
                }
            }
        }
        .sheet(isPresented: $showNewAppointment) {
            NewAppointmentView()
        }
    }
    
    
    func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
        }
    }
    
    // MARK: Next Appointment
    var nextAppointmentCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Yaklaşan Randevu")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Button("Tümü") {}
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(primaryBlue)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 14)
            
            if let next = appState.nextAppointment {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [next.type.color, next.type.color.opacity(0.7)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 120).offset(x: 140, y: -40)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(next.type.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.horizontal, 12).padding(.vertical, 5)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                            
                            Text(next.doctorName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text(next.doctorSpecialty)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                            
                            HStack(spacing: 16) {
                                Label(formatDate(next.date), systemImage: "calendar")
                                Label(next.time, systemImage: "clock")
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 4)
                        }
                        Spacer()
                        Image(systemName: next.type.icon)
                            .font(.system(size: 44))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(22)
                }
                .padding(.horizontal, 24)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 36))
                            .foregroundColor(primaryBlue.opacity(0.5))
                        Text("Henüz randevunuz yok")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        Button("Randevu Al") { showNewAppointment = true }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(primaryBlue)
                    }
                    .padding(28)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: Quick Actions
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı İşlemler")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.horizontal, 24)
            HStack(spacing: 12) {
                quickBtn(icon: "calendar.badge.plus", label: "Randevu Al", color: primaryBlue) { showNewAppointment = true }
                quickBtn(icon: "doc.text.fill", label: "Raporlarım", color: Color(red: 0.2, green: 0.7, blue: 0.6)) {}
                quickBtn(icon: "cross.case.fill", label: "Tedaviler", color: Color(red: 0.7, green: 0.3, blue: 0.9)) {}
                quickBtn(icon: "phone.fill", label: "Ara", color: Color(red: 0.95, green: 0.45, blue: 0.2)) {}
            }
            .padding(.horizontal, 24)
        }
    }
    
    func quickBtn(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(color.opacity(0.12)).frame(width: 60, height: 60)
                    Image(systemName: icon).font(.system(size: 22, weight: .semibold)).foregroundColor(color)
                }
                Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(.primary).multilineTextAlignment(.center)
            }
        }.frame(maxWidth: .infinity)
    }
    
    // MARK: Health Score
    var healthScoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Diş Sağlığı Skoru")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.horizontal, 24)
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 15, y: 4)
                HStack(spacing: 24) {
                    ZStack {
                        Circle().stroke(Color.gray.opacity(0.15), lineWidth: 10).frame(width: 90)
                        Circle()
                            .trim(from: 0, to: 0.82)
                            .stroke(LinearGradient(colors: [primaryBlue, Color(red: 0.2, green: 0.7, blue: 0.6)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 90)
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 2) {
                            Text("82").font(.system(size: 26, weight: .bold, design: .rounded))
                            Text("/ 100").font(.system(size: 11)).foregroundColor(.secondary)
                        }
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        healthItem(icon: "checkmark.circle.fill", color: .green, label: "Temizlik", value: "İyi")
                        healthItem(icon: "exclamationmark.circle.fill", color: .orange, label: "Diş Eti", value: "Orta")
                        healthItem(icon: "checkmark.circle.fill", color: .green, label: "Dolgu", value: "İyi")
                    }
                    Spacer()
                }
                .padding(22)
            }
            .padding(.horizontal, 24)
        }
    }
    
    func healthItem(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            Text(label).font(.system(size: 13)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.system(size: 13, weight: .semibold))
        }
    }
    
    // MARK: Dental Tips
    var dentalTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Günün İpucu")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.horizontal, 24)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(tips) { tip in tipCard(tip: tip) }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    func tipCard(tip: DentalTip) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18).fill(tip.color.opacity(0.1)).frame(width: 220, height: 140)
            RoundedRectangle(cornerRadius: 18).stroke(tip.color.opacity(0.2), lineWidth: 1).frame(width: 220, height: 140)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(tip.icon).font(.system(size: 28))
                    Spacer()
                    Text(tip.category).font(.system(size: 10, weight: .semibold)).foregroundColor(tip.color)
                        .padding(.horizontal, 10).padding(.vertical, 4).background(tip.color.opacity(0.15)).cornerRadius(20)
                }
                Text(tip.title).font(.system(size: 15, weight: .bold, design: .rounded))
                Text(tip.content).font(.system(size: 12)).foregroundColor(.secondary).lineLimit(2)
            }
            .padding(16)
        }
        .frame(width: 220, height: 140)
    }
    
    // MARK: Recent Doctors
    var recentDoctorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Doktorlarımız")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Button("Tümünü Gör") {}.font(.system(size: 14, weight: .semibold)).foregroundColor(primaryBlue)
            }
            .padding(.horizontal, 24)
            
            let displayDoctors = appState.doctors.isEmpty ? Doctor.sampleData : appState.doctors
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(displayDoctors) { doctor in
                        NavigationLink(destination: DoctorDetailView(doctor: doctor)) {
                            doctorCard(doctor: doctor)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    func doctorCard(doctor: Doctor) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(Color.white)
                .shadow(color: .black.opacity(0.07), radius: 12, y: 4)
            VStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    Circle().fill(primaryBlue.opacity(0.1)).frame(width: 70, height: 70)
                    Image(systemName: doctor.image).font(.system(size: 30)).foregroundColor(primaryBlue)
                    Circle().fill(doctor.isAvailable ? Color.green : Color.gray).frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2)).offset(x: 4, y: 4)
                }
                Text(doctor.name).font(.system(size: 13, weight: .bold)).foregroundColor(.primary).multilineTextAlignment(.center)
                Text(doctor.specialty).font(.system(size: 11)).foregroundColor(.secondary)
                HStack(spacing: 3) {
                    Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.yellow)
                    Text(String(format: "%.1f", doctor.rating)).font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(16)
        }
        .frame(width: 140, height: 180)
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd MMM"; f.locale = Locale(identifier: "tr_TR"); return f.string(from: date)
    }
}

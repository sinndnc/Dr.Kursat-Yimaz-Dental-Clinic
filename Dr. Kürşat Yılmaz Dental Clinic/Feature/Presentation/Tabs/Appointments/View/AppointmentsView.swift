import SwiftUI

// MARK: - Appointments View
struct AppointmentsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedFilter: AppointmentFilter = .upcoming
    @State private var showNewAppointment = false
    
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    enum AppointmentFilter: String, CaseIterable {
        case upcoming = "Yaklaşan"; case completed = "Geçmiş"; case all = "Tümü"
    }
    
    var filteredAppointments: [Appointment] {
        switch selectedFilter {
        case .upcoming:  return appState.appointments.filter { $0.status == .upcoming }
        case .completed: return appState.appointments.filter { $0.status == .completed }
        case .all:       return appState.appointments
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterPicker.padding(.top, 8).padding(.bottom, 16)
                
                if appState.isLoadingData {
                    Spacer()
                    ProgressView("Randevular yükleniyor...")
                    Spacer()
                } else if filteredAppointments.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(filteredAppointments) { appointment in
                                AppointmentCard(appointment: appointment)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Randevular")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewAppointment = true }) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 22)).foregroundColor(primaryBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $showNewAppointment) { NewAppointmentView() }
    }
    
    var filterPicker: some View {
        HStack(spacing: 0) {
            ForEach(AppointmentFilter.allCases, id: \.self) { filter in
                Button(action: { withAnimation(.spring(response: 0.3)) { selectedFilter = filter } }) {
                    Text(filter.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedFilter == filter ? .white : .secondary)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(selectedFilter == filter ? primaryBlue : Color.clear)
                        .cornerRadius(12)
                }
            }
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .padding(.horizontal, 20)
    }
    
    var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark").font(.system(size: 60)).foregroundColor(.secondary.opacity(0.5))
            Text("Randevu Bulunamadı").font(.system(size: 20, weight: .bold, design: .rounded))
            Text("Bu kategoride henüz randevunuz yok.").font(.system(size: 15)).foregroundColor(.secondary)
            Button("Randevu Al") { showNewAppointment = true }
                .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                .padding(.horizontal, 32).padding(.vertical, 14).background(primaryBlue).cornerRadius(16)
            Spacer()
        }
    }
}

// MARK: - Appointment Detail

// MARK: - New Appointment View (Firebase'e kayıt)
struct NewAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var selectedDoctor: Doctor? = nil
    @State private var selectedService: Appointment.AppointmentType = .checkup
    @State private var selectedDate = Date()
    @State private var selectedTime = "10:00"
    @State private var notes = ""
    @State private var step = 1
    @State private var isSaving = false
    
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    private let availableTimes = ["09:00","09:30","10:00","10:30","11:00","11:30","14:00","14:30","15:00","15:30","16:00"]
    
    var displayDoctors: [Doctor] { appState.doctors.isEmpty ? Doctor.sampleData : appState.doctors }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar.padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch step {
                        case 1: doctorStep
                        case 2: serviceStep
                        case 3: dateTimeStep
                        default: confirmStep
                        }
                    }
                    .padding(.horizontal, 20).padding(.bottom, 100)
                }
                
                HStack(spacing: 12) {
                    if step > 1 {
                        Button("Geri") { withAnimation { step -= 1 } }
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(primaryBlue)
                            .frame(width: 80, height: 54).background(primaryBlue.opacity(0.1)).cornerRadius(16)
                    }
                    Button(action: nextOrSave) {
                        Group {
                            if isSaving { ProgressView().tint(.white) }
                            else { Text(step == 4 ? "Onayla ve Kaydet" : "İleri")
                                .font(.system(size: 16, weight: .bold)).foregroundColor(.white) }
                        }
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(canProceed ? primaryBlue : Color.gray.opacity(0.4))
                        .cornerRadius(16)
                    }
                    .disabled(!canProceed || isSaving)
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                .background(Color.white.ignoresSafeArea())
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Yeni Randevu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("İptal") { dismiss() } } }
        }
    }
    
    var canProceed: Bool {
        switch step {
        case 1: return selectedDoctor != nil
        case 2: return true
        case 3: return true
        case 4: return true
        default: return false
        }
    }
    
    func nextOrSave() {
        if step < 4 { withAnimation { step += 1 } }
        else { saveAppointment() }
    }
    
    func saveAppointment() {
        guard let doctor = selectedDoctor,
              let uid = appState.authService.uid else { return }
        
        isSaving = true
        let appointment = Appointment(
            userId: uid,
            doctorId: doctor.id ?? "",
            doctorName: doctor.name,
            doctorSpecialty: doctor.specialty,
            date: selectedDate,
            time: selectedTime,
            type: selectedService,
            status: .upcoming,
            notes: notes,
            roomNumber: "Oda \(Int.random(in: 1...5))",
            createdAt: Date()
        )
        Task {
            await appState.createAppointment(appointment)
            await MainActor.run { isSaving = false; dismiss() }
        }
    }
    
    var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(1...4, id: \.self) { i in
                RoundedRectangle(cornerRadius: 4)
                    .fill(i <= step ? primaryBlue : Color.gray.opacity(0.2))
                    .frame(height: 6)
                    .animation(.spring(response: 0.3), value: step)
            }
        }
    }
    
    var doctorStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Doktor Seçin").font(.system(size: 22, weight: .bold, design: .rounded))
            ForEach(displayDoctors,id: \.self.id) { doctor in
                Button(action: { selectedDoctor = doctor }) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(primaryBlue.opacity(0.1)).frame(width: 52, height: 52)
                            Image(systemName: doctor.image).font(.system(size: 22)).foregroundColor(primaryBlue)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(doctor.name).font(.system(size: 15, weight: .bold)).foregroundColor(.primary)
                            Text(doctor.specialty).font(.system(size: 13)).foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.yellow)
                                Text(String(format: "%.1f", doctor.rating)).font(.system(size: 12, weight: .semibold)).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if selectedDoctor?.id == doctor.id {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 24)).foregroundColor(primaryBlue)
                        }
                    }
                    .padding(16).background(Color.white).cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(selectedDoctor?.id == doctor.id ? primaryBlue : Color.clear, lineWidth: 2))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var serviceStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hizmet Seçin").font(.system(size: 22, weight: .bold, design: .rounded))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Appointment.AppointmentType.allCases, id: \.self) { service in
                    Button(action: { selectedService = service }) {
                        VStack(spacing: 10) {
                            Image(systemName: service.icon).font(.system(size: 28))
                                .foregroundColor(selectedService == service ? .white : service.color)
                            Text(service.rawValue).font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedService == service ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                        .background(selectedService == service ? service.color : Color.white)
                        .cornerRadius(16).shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    var dateTimeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tarih & Saat Seçin").font(.system(size: 22, weight: .bold, design: .rounded))
            DatePicker("Tarih", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical).padding(16).background(Color.white).cornerRadius(16)
                .environment(\.locale, Locale(identifier: "tr_TR"))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Saat Seçin").font(.system(size: 16, weight: .semibold))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(availableTimes, id: \.self) { time in
                        Button(action: { selectedTime = time }) {
                            Text(time).font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedTime == time ? .white : .primary)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(selectedTime == time ? primaryBlue : Color.white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(16).background(Color.white).cornerRadius(16)
        }
    }
    
    var confirmStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Onaylayın").font(.system(size: 22, weight: .bold, design: .rounded))
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [primaryBlue, Color(red: 0.05, green: 0.25, blue: 0.75)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                VStack(spacing: 14) {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 44)).foregroundColor(.white.opacity(0.9))
                    Text(selectedDoctor?.name ?? "").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Text(selectedService.rawValue).font(.system(size: 14)).foregroundColor(.white.opacity(0.85))
                    HStack(spacing: 20) {
                        Label(formatShortDate(selectedDate), systemImage: "calendar")
                        Label(selectedTime, systemImage: "clock")
                    }
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                }
                .padding(28)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Not (İsteğe Bağlı)").font(.system(size: 16, weight: .semibold))
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $notes).frame(height: 80).padding(12)
                        .background(Color.white).cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                    if notes.isEmpty {
                        Text("Şikayetlerinizi veya notlarınızı yazın...")
                            .foregroundColor(.gray.opacity(0.5)).font(.system(size: 14))
                            .padding(20).allowsHitTesting(false)
                    }
                }
            }
        }
    }
    
    func formatShortDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd MMMM"; f.locale = Locale(identifier: "tr_TR"); return f.string(from: date)
    }
}

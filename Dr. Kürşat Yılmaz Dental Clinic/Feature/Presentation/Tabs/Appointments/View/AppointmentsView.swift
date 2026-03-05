import SwiftUI



// MARK: - Models

enum AppointmentStatus: String, CaseIterable {
    case upcoming  = "Yaklaşan"
    case completed = "Tamamlanan"
    case cancelled = "İptal"

    var color: Color {
        switch self {
        case .upcoming:  return Color(red: 0.4,  green: 0.78, blue: 0.50)
        case .completed: return Color(red: 0.82, green: 0.72, blue: 0.50)
        case .cancelled: return Color(red: 0.85, green: 0.38, blue: 0.38)
        }
    }

    var icon: String {
        switch self {
        case .upcoming:  return "clock.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}

struct AppointmentsView: View {
    @State private var selectedFilter: AppointmentFilter = .all
    @State private var selectedAppointment: Appointment? = nil
    @State private var showNewAppointment = false
    @Namespace private var filterNamespace
    @EnvironmentObject private var appState: AppState
    @State private var headerAppeared = false
    
    
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
        NavigationStack{
            ZStack(alignment: .bottomTrailing) {
                Color.kyBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        summaryStrip
                            .padding(.top, 20)
                        filterBar
                            .padding(.top, 24)
                        appointmentsList
                            .padding(.top, 16)
                            .padding(.bottom, 100)
                    }
                }
                .ignoresSafeArea()
                
                // FAB – New Appointment
                fabButton
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
            }
            .sheet(item: $selectedAppointment) { appt in
                AppointmentDetailSheet(appointment: appt)
            }
            .sheet(isPresented: $showNewAppointment) {
                NewAppointmentSheet()
            }
            .onAppear{
                withAnimation(.easeOut(duration: 0.7)) { headerAppeared = true }
            }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                Color.kyBackground
                RadialGradient(
                    colors: [Color.kyAccent.opacity(0.14), Color.clear],
                    center: UnitPoint(x: 0.9, y: 0.1),
                    startRadius: 0, endRadius: 180
                )
            }
            .ignoresSafeArea()
            .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Circle().fill(Color.kyAccent).frame(width: 5, height: 5)
                    Text("KY CLINIC")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Color.kyAccent)
                }
                Text("Randevularım")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                    .opacity(headerAppeared ? 1 : 0)
                    .offset(y: headerAppeared ? 0 : 10)
                Text("Geçmiş ve planlanan randevularınız")
                    .font(.system(size: 14))
                    .foregroundColor(Color.kySubtext)
            }
            .padding(.top, 25)
            .padding(.horizontal)
        }
    }

    // MARK: Summary Strip
    
    private var summaryStrip: some View {
        HStack(spacing: 10) {
            SummaryBadge(
                value: "\(AppointmentStatus.allCases.filter { $0 == .upcoming }.count)",
                label: "Yaklaşan",
                color: Color(red: 0.4, green: 0.78, blue: 0.5)
            )
            SummaryBadge(
                value: "\(AppointmentStatus.allCases.filter { $0 == .completed }.count)",
                label: "Tamamlanan",
                color: Color.kyAccent
            )
            SummaryBadge(
                value: "\(AppointmentStatus.allCases.filter { $0 == .cancelled }.count)",
                label: "İptal",
                color: Color(red: 0.85, green: 0.38, blue: 0.38)
            )
        }
        .padding(.horizontal, 20)
    }

    // MARK: Filter Bar

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(AppointmentFilter.allCases,id:\.self.rawValue) { filter in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedFilter == filter ? Color.kyBackground : Color.kySubtext)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            Group {
                                if selectedFilter == filter {
                                    LinearGradient(
                                        colors: [Color.kyAccent, Color.kyAccentDark],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                } else {
                                    LinearGradient(colors: [Color.kyCard, Color.kyCard],
                                                   startPoint: .leading, endPoint: .trailing)
                                }
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(
                            selectedFilter == filter ? nil :
                            Capsule().strokeBorder(Color.kyBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: Appointments List

    private var appointmentsList: some View {
        LazyVStack(spacing: 14) {
            ForEach(filteredAppointments) { appt in
                AppointmentRow(appointment: appt)
                    .onTapGesture { selectedAppointment = appt }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: selectedFilter)
    }

    // MARK: FAB

    private var fabButton: some View {
        Button { showNewAppointment = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                Text("Yeni Randevu")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(Color.kyBackground)
            .padding(.horizontal, 22)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [Color.kyAccent, Color.kyAccentDark],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.kyAccent.opacity(0.35), radius: 16, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Summary Badge

struct SummaryBadge: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 7, height: 7)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.kySubtext)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Appointment Row

struct AppointmentRow: View {
    let appointment: Appointment
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Date Badge
            VStack(spacing: 1) {
//                Text(appointment.)
//                    .font(.system(size: 9, weight: .bold, design: .monospaced))
//                    .tracking(1)
                Text(appointment.roomNumber)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Text(appointment.time)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.kySubtext)
            }
            .frame(width: 52)
            .padding(.vertical, 12)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(appointment.type.rawValue)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                    .lineLimit(2)

                HStack(spacing: 5) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color.kySubtext)
                    Text(appointment.doctorName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kySubtext)
                }

                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 9))
                            .foregroundColor(Color.kySubtext.opacity(0.7))
                        Text(appointment.notes)
                            .font(.system(size: 11))
                            .foregroundColor(Color.kySubtext.opacity(0.7))
                    }

                    // Status pill
                    HStack(spacing: 4) {
                        Text(appointment.status.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .clipShape(Capsule())
                }
            }
            
            Spacer(minLength: 0)
            
            // Chevron + icon
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(width: 34, height: 34)
                    Image(systemName: appointment.type.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(appointment.type.color)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.kySubtext.opacity(0.5))
            }
        }
        .padding(14)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}

// MARK: - Appointment Detail Sheet

struct AppointmentDetailSheet: View {
    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Hero
                    ZStack(alignment: .bottomLeading) {
                      
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .frame(width: 60, height: 60)
                                Image(systemName: appointment.type.icon)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(appointment.type.color)
                            }
                            Text(appointment.type.rawValue.capitalized)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(Color.kyText)
                            Text(appointment.doctorSpecialty)
                                .font(.system(size: 13))
                                .foregroundColor(Color.kySubtext)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Status
                        HStack(spacing: 8) {
                            
                            Text(appointment.status.rawValue)
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .clipShape(Capsule())
                        
                        // Detail rows
                        VStack(spacing: 12) {
                            DetailRow(
                                icon: "calendar",
                                label: "Tarih",
                                value: appointment.date.description,
                                color: appointment.type.color
                            )
                            DetailRow(icon: "clock.fill",label: "Saat",value: appointment.time,color: appointment.type.color)
                            DetailRow(
                                icon: "timer",
                                label: "Süre",
                                value: appointment.notes,
                                color: appointment.type.color
                            )
                            DetailRow(icon: "person.fill",label: "Doktor",value: appointment.doctorName,color: appointment.type.color)
                            DetailRow(icon: "mappin.circle.fill", label: "Klinik", value: "KY Clinic · Etiler, Beşiktaş", color: appointment.type.color)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOT")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .tracking(2)
                                .foregroundColor(Color.kySubtext)
                            Text(appointment.notes)
                                .font(.system(size: 14))
                                .foregroundColor(Color.kyText.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .background(Color.kyAccent.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.kyAccent.opacity(0.15), lineWidth: 1)
                        )
                        // Actions
                        if appointment.status == .upcoming {
                            VStack(spacing: 10) {
                                ActionButton(label: "Takvime Ekle",   icon: "calendar.badge.plus",  isPrimary: true,  color: appointment.type.color)
                                ActionButton(label: "Randevuyu İptal Et", icon: "xmark.circle",   isPrimary: false, color: Color(red: 0.85, green: 0.38, blue: 0.38))
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }

            // Dismiss
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.kySubtext)
                        .padding(10)
                        .background(Color.kySurface)
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(color.opacity(0.10))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.kySubtext)
                .frame(width: 52, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.kyText)
            Spacer()
        }
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let label: String
    let icon: String
    let isPrimary: Bool
    let color: Color

    var body: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                Spacer()
            }
            .foregroundColor(isPrimary ? Color.kyBackground : color)
            .padding(.vertical, 15)
            .background(
                isPrimary
                ? AnyView(LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                : AnyView(color.opacity(0.08))
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                isPrimary ? nil :
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(color.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - New Appointment Sheet (Placeholder)

struct NewAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTreatment = ""
    @State private var selectedDate = Date()
    @State private var notes = ""

    private let treatments = [
        "EMS / GBT Diş Temizliği", "Lamina Kaplama", "Kompozit Gülüş Tasarımı",
        "Dental İmplant", "Şeffaf Plak (Aligner)", "3D Tarama & Planlama",
        "Dolgu & Koruyucu Uygulama", "Onlay & Overlay Restorasyon"
    ]

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            Circle().fill(Color.kyAccent).frame(width: 5, height: 5)
                            Text("YENİ RANDEVU")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .tracking(3)
                                .foregroundColor(Color.kyAccent)
                        }
                        Text("Randevu Planla")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color.kyText)
                        Text("Aşağıdaki formu doldurun, en kısa\nsürede sizi arayalım.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.kySubtext)
                            .lineSpacing(3)
                    }
                    .padding(.top, 8)

                    // Treatment Picker
                    VStack(alignment: .leading, spacing: 10) {
                        FormLabel(text: "TEDAVİ SEÇİN")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(treatments, id: \.self) { t in
                                    Button {
                                        withAnimation(.spring(response: 0.28)) {
                                            selectedTreatment = t
                                        }
                                    } label: {
                                        Text(t)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(selectedTreatment == t ? Color.kyBackground : Color.kySubtext)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 9)
                                            .background(
                                                selectedTreatment == t
                                                ? AnyView(LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark], startPoint: .leading, endPoint: .trailing))
                                                : AnyView(Color.kyCard)
                                            )
                                            .clipShape(Capsule())
                                            .overlay(
                                                selectedTreatment == t ? nil :
                                                Capsule().strokeBorder(Color.kyBorder, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                            .padding(.horizontal, 1)
                            .padding(.vertical, 2)
                        }
                    }

                    // Date Picker
                    VStack(alignment: .leading, spacing: 10) {
                        FormLabel(text: "TARİH & SAAT")
                        DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .padding(14)
                            .background(Color.kyCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(Color.kyBorder, lineWidth: 1)
                            )
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 10) {
                        FormLabel(text: "NOTLAR (İSTEĞE BAĞLI)")
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Eklemek istediğiniz bir not var mı?")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.kySubtext.opacity(0.5))
                                    .padding(.horizontal, 14)
                                    .padding(.top, 14)
                            }
                            TextEditor(text: $notes)
                                .font(.system(size: 14))
                                .foregroundColor(Color.kyText)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 90)
                                .padding(10)
                        }
                        .background(Color.kyCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.kyBorder, lineWidth: 1)
                        )
                    }

                    // Submit
                    Button { dismiss() } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Randevu Talebi Gönder")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                        }
                        .foregroundColor(Color.kyBackground)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.kyAccent.opacity(0.3), radius: 12, x: 0, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }

            // Dismiss
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.kySubtext)
                        .padding(10)
                        .background(Color.kySurface)
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

// MARK: - Form Label

struct FormLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .tracking(2)
            .foregroundColor(Color.kySubtext)
    }
}


#Preview {
    AppointmentsView()
        .preferredColorScheme(.dark)
}

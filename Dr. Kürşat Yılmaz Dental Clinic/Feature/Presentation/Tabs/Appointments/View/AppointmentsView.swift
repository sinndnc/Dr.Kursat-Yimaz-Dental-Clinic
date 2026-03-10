//
//  AppointmentView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

enum AppointmentFilter: String, CaseIterable {
    case all = "Tümü"; case upcoming = "Yaklaşan"; case completed = "Geçmiş"
}


struct AppointmentsView: View {
    
    @Injected private var fs: FirestoreServiceProtocol
    
    @Namespace private var filterNamespace
    @EnvironmentObject private var vm: AuthViewModel
    @EnvironmentObject private var navState: AppointmentNavigationState
    
    @State private var selectedFilter: AppointmentFilter = .all
    
    @State private var showCalendar = false
    @State private var headerAppeared = false
    @State private var currentMonth: Date = Date()
    @State private var selectedCalendarDate: Date? = nil
    
    // Search states
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    
    // MARK: - Filtered Appointments
    var filteredAppointments: [Appointment] {
        var base: [Appointment]
        switch selectedFilter {
        case .upcoming:  base = fs.appointments.filter { $0.status == .upcoming }
        case .completed: base = fs.appointments.filter { $0.status == .completed }
        case .all:       base = fs.appointments
        }
        
        // Calendar date filter
        if let date = selectedCalendarDate {
            base = base.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        }
        
        // Search filter
        if !searchText.isEmpty {
            base = base.filter {
                $0.doctorName.localizedCaseInsensitiveContains(searchText) 
            }
        }
        
        return base
    }
    
    /// Dates that have at least one appointment this month
    var appointmentDatesInMonth: Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return Set(fs.appointments.map { formatter.string(from: $0.date) })
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navState.path) {
            ZStack(alignment: .bottomTrailing) {
                Color.kyBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        
                        if showSearch {
                            searchBar
                                .padding(.top, 16)
                                .padding(.horizontal, 20)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        if vm.authState == .authenticated {
                            calendarToggleBar
                                .padding(.top, 20)
                            if showCalendar {
                                calendarSection
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            filterBar
                                .padding(.top, 24)
                        }
                        
                        if let date = selectedCalendarDate {
                            activeDateChip(date: date)
                                .padding(.top, 10)
                                .padding(.horizontal, 20)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        appointmentsList
                            .padding(.top, 16)
                            .padding(.bottom, 100)
                    }
                }
                .ignoresSafeArea()
                
                if vm.authState == .authenticated {
                    fabButton
                        .padding(.trailing, 24)
                        .padding(.bottom, 32)
                }
            }
            .onAppear { withAnimation(.easeOut(duration: 0.7)) { headerAppeared = true } }
            .navigationDestination(for: AppointmentsDestination.self){ route in
                switch route {
                case .auth:
                    AuthSelectionView()
                case .login:
                    LoginView()
                case .signup:
                    SignUpView()
                case .appointmentDetail(let apt):
                    AppointmentDetailView(appointment: apt)
                case .newAppointment:
                    BookingView()
                default:
                    EmptyView()
                }
            }
        }
    }
    
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
            .padding(.horizontal)
            
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showSearch.toggle()
                        if !showSearch { searchText = "" }
                    }
                } label: {
                    Image(systemName: showSearch ? "xmark.circle.fill" : "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.kyAccent)
                        .padding(10)
                        .background(Color.kyCard)
                        .clipShape(Circle())
                        .shadow(color: Color.kyAccent.opacity(0.2), radius: 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.kySubtext)
                .font(.system(size: 14))
            TextField("Doktor, branş veya klinik ara...", text: $searchText)
                .font(.system(size: 14))
                .foregroundColor(Color.kyText)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
    
    private var calendarToggleBar: some View {
        HStack {
            Text("TAKVİM")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(Color.kySubtext)
            Spacer()
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showCalendar.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(showCalendar ? "Gizle" : "Göster")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.kyAccent)
                    Image(systemName: showCalendar ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.kyAccent)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Calendar Section

    private var calendarSection: some View {
        VStack(spacing: 0) {
            // Month Navigation
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.kyAccent)
                        .padding(8)
                        .background(Color.kyCard)
                        .clipShape(Circle())
                }

                Spacer()

                Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.kyAccent)
                        .padding(8)
                        .background(Color.kyCard)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(["Pzt","Sal","Çar","Per","Cum","Cmt","Paz"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.kySubtext)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 6)

            // Day Grid
            let days = generateDays(for: currentMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 4) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    if let day = day {
                        CalendarDayCell(
                            date: day,
                            isToday: Calendar.current.isDateInToday(day),
                            isSelected: selectedCalendarDate.map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false,
                            hasAppointment: appointmentDatesInMonth.contains(dayKey(day))
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                if let sel = selectedCalendarDate, Calendar.current.isDate(sel, inSameDayAs: day) {
                                    selectedCalendarDate = nil
                                } else {
                                    selectedCalendarDate = day
                                }
                            }
                        }
                    } else {
                        Color.clear.frame(height: 30)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private func activeDateChip(date: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.kyAccent)
            Text(date.formatted(.dateTime.day().month(.wide).year()))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.kyAccent)
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    selectedCalendarDate = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.kySubtext)
                    .padding(5)
                    .background(Color.kyBorder.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color.kyAccent.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.kyAccent.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(AppointmentFilter.allCases, id: \.self.rawValue) { filter in
                FilterChip(
                    label: filter.rawValue,
                    isSelected: selectedFilter == filter) {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                            selectedFilter = filter
                        }
                    }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var appointmentsList: some View {
        LazyVStack(spacing: 14) {
            Divider()
            if vm.authState == .authenticated{
                if filteredAppointments.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredAppointments) { appt in
                        AppointmentRow(appointment: appt)
                            .onTapGesture { navState.navigate(to: .appointmentDetail(apt: appt)) }
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
            }else{
                notLoggedInState
            }
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: selectedFilter)
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: selectedCalendarDate)
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: searchText)
    }
    
    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.kyCard)
                    .frame(width: 72, height: 72)
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 28))
                    .foregroundColor(Color.kySubtext)
            }
            Text("Randevu bulunamadı")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(Color.kyText)
            Text(selectedCalendarDate != nil
                 ? "Bu tarih için randevu kaydınız yok."
                 : "Seçili filtre için randevu bulunmuyor.")
                .font(.system(size: 13))
                .foregroundColor(Color.kySubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    
    private var notLoggedInState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.kyCard)
                    .frame(width: 72, height: 72)
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 28))
                    .foregroundColor(Color.kySubtext)
            }
            Text("Giriş yapılmadı")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(Color.kyText)
            Text("Randevularınızı görüntülemek için\nlütfen giriş yapın.")
                .font(.system(size: 13))
                .foregroundColor(Color.kySubtext)
                .multilineTextAlignment(.center)
            
            Button(action: {
                navState.navigate(to: .auth)
            }) {
                Text("Giriş Yap")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    .background(Color.kySubtext)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    
    private var fabButton: some View {
        Button{ navState.navigate(to: .newAppointment) } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
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
            .clipShape(Circle())
            .shadow(color: Color.kyAccent.opacity(0.35), radius: 16, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Calendar Helpers

    private func generateDays(for month: Date) -> [Date?] {
        let calendar = Calendar.current
        guard
            let monthStart  = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
            let monthRange  = calendar.range(of: .day, in: .month, for: monthStart)
        else { return [] }

        // Monday-based weekday offset (1=Mon … 7=Sun)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let offset = (firstWeekday + 5) % 7  // Mon=0 … Sun=6

        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        // Pad to full 6-row grid
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private func dayKey(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// MARK: - CalendarDayCell

struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let hasAppointment: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.kyAccent, Color.kyAccentDark],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                    } else if isToday {
                        Circle()
                            .strokeBorder(Color.kyAccent, lineWidth: 1.5)
                            .frame(width: 30, height: 30)
                    }

                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 13, weight: isToday || isSelected ? .bold : .regular))
                        .foregroundColor(
                            isSelected ? Color.kyBackground :
                            isToday    ? Color.kyAccent :
                                        Color.kyText
                        )
                }

                // Appointment dot
                Circle()
                    .fill(hasAppointment ? Color.kyAccent : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(height: 30)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}


struct FormLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .tracking(2)
            .foregroundColor(Color.kySubtext)
    }
}

// MARK: - Preview

#Preview {
    AppointmentsView()
        .preferredColorScheme(.dark)
}

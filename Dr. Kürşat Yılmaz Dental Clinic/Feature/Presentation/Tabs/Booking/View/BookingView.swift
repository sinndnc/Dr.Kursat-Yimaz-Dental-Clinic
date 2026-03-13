//
//  BookingViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct BookingView: View {
    @StateObject private var vm = BookingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            if vm.isSuccess {
                BookingSuccessView(vm: vm, dismiss: dismiss)
            } else {
                VStack(spacing: 0) {
                    BookingHeader(vm: vm, dismiss: dismiss)
                    BookingStepIndicator(vm: vm)
                    Divider().background(Color.kyBorder)
                    
                    // Step content
                    ZStack {
                        switch vm.currentStep {
                        case .service: ServiceStepView(vm: vm)
                        case .doctor:  DoctorStepView(vm: vm)
                        case .date:    DateStepView(vm: vm)
                        case .confirm: ConfirmStepView(vm: vm)
                        }
                    }
                    .animation(.spring(response: 0.38, dampingFraction: 0.85), value: vm.currentStep)
                    
                    BookingNavigationBar(vm: vm)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Hata", isPresented: .constant(!vm.validationErrors.isEmpty)) {
            Button("Tamam") { vm.validationErrors = [] }
        } message: {
            Text(vm.validationErrors.joined(separator: "\n"))
        }
    }
}

// =========================================================================
// MARK: - Header
// =========================================================================

private struct BookingHeader: View {
    @ObservedObject var vm: BookingViewModel
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: {
                if vm.currentStep == .service { dismiss() } else { vm.goBack() }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: vm.currentStep == .service ? "xmark" : "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    if vm.currentStep != .service {
                        Text(vm.currentStep == .doctor ? "Hizmet" :
                             vm.currentStep == .date   ? "Doktor" : "Tarih & Saat")
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .foregroundColor(.kyAccent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.kyAccent.opacity(0.12), in: Capsule())
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            
            VStack(spacing: 1) {
                Text("Randevu Al")
                    .font(.custom("Georgia", size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(.kyText)
                Text("Adım \(vm.currentStep.rawValue + 1) / \(BookingViewModel.Step.allCases.count)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.kySubtext)
            }
            
            // Right spacer to keep title centered
            Color.clear.frame(maxWidth: .infinity,maxHeight: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

// =========================================================================
// MARK: - Step Indicator
// =========================================================================

private struct BookingStepIndicator: View {
    @ObservedObject var vm: BookingViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(BookingViewModel.Step.allCases, id: \.rawValue) { step in
                let isDone    = step.rawValue < vm.currentStep.rawValue
                let isCurrent = step == vm.currentStep

                Button { vm.selectStep(step) } label: {
                    VStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .fill(isDone || isCurrent ? Color.kyAccent : Color.kyBorder)
                                .frame(width: 28, height: 28)
                            if isDone {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(step.rawValue + 1)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(isCurrent ? .white : .kySubtext)
                            }
                        }
                        .scaleEffect(isCurrent ? 1.08 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: vm.currentStep)

                        Text(step.title)
                            .font(.system(size: 10, weight: isCurrent ? .semibold : .regular))
                            .foregroundColor(isCurrent ? .kyAccent : .kySubtext)
                    }
                }
                .disabled(step.rawValue >= vm.currentStep.rawValue)
                .frame(maxWidth: .infinity)

                if step != BookingViewModel.Step.allCases.last {
                    Rectangle()
                        .fill(step.rawValue < vm.currentStep.rawValue ? Color.kyAccent : Color.kyBorder)
                        .frame(height: 1.5)
                        .padding(.bottom, 20)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

// =========================================================================
// MARK: - STEP 1: Service Selection
// =========================================================================

private struct ServiceStepView: View {
    @ObservedObject var vm: BookingViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 20) {
                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(title: "Tümü", isSelected: vm.selectedCategory == nil) {
                            vm.selectedCategory = nil
                        }
                        ForEach(ServiceCategory.allCases) { cat in
                            CategoryChip(title: cat.rawValue, isSelected: vm.selectedCategory == cat) {
                                vm.selectedCategory = vm.selectedCategory == cat ? nil : cat
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.kySubtext)
                    TextField("Hizmet ara…", text: $vm.serviceSearchQuery)
                        .font(.system(size: 15))
                }
                .padding(12)
                .background(Color.kySurface)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.kyBorder, lineWidth: 1))
                .padding(.horizontal, 20)

                // Service cards
                if vm.filteredServices.isEmpty {
                    EmptyStateView(icon: "stethoscope", message: "Hizmet bulunamadı")
                        .padding(.top, 40)
                } else {
                    ForEach(vm.filteredServices) { service in
                        BookingServiceCard(service: service, isSelected: vm.form.service?.id == service.id) {
                            withAnimation(.spring(response: 0.3)) {
                                vm.form.service = service
                                vm.form.type = appointmentType(for: service)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.top, 16)
        }
    }

    private func appointmentType(for service: Service) -> Appointment.AppointmentType {
        let title = service.title.lowercased()
        if title.contains("implant")   { return .implant }
        if title.contains("ortodonti") || title.contains("aligner") { return .orthodontics }
        if title.contains("kanal")     { return .rootCanal }
        if title.contains("beyazlatma") { return .whitening }
        if title.contains("temizlik") || title.contains("ems") { return .cleaning }
        return .checkup
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .kySubtext)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.kyAccent : Color.kySurface)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(
                    isSelected ? Color.clear : Color.kyBorder, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

private struct BookingServiceCard: View {
    let service: Service
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(colorName: service.colorName).opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: service.sfSymbol)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(colorName: service.colorName))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(service.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.kyText)
                        if let badge = service.badgeText {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.kyAccent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.kyAccent.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    Text(service.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.kySubtext)
                    HStack(spacing: 4) {
                        ForEach(service.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10))
                                .foregroundColor(.kyAccent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.kyAccent.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .kyAccent : .kyBorder)
            }
            .padding(14)
            .background(Color.kySurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.kyAccent : Color.kyBorder,
                            lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: isSelected ? Color.kyAccent.opacity(0.12) : .clear, radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// =========================================================================
// MARK: - STEP 2: Doctor Selection
// =========================================================================

private struct DoctorStepView: View {
    @ObservedObject var vm: BookingViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 14) {

                if let service = vm.form.service {
                    HStack(spacing: 8) {
                        Image(systemName: service.sfSymbol)
                            .font(.system(size: 13))
                        Text("\(service.title) için doktor seçin")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.kyAccent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.kyAccent.opacity(0.12))
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                }

                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(.kySubtext)
                    TextField("Doktor ara…", text: $vm.doctorSearchQuery)
                        .font(.system(size: 15))
                }
                .padding(12)
                .background(Color.kySurface)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.kyBorder, lineWidth: 1))
                .padding(.horizontal, 20)

                if vm.filteredDoctors.isEmpty {
                    EmptyStateView(icon: "person.fill.questionmark", message: "Doktor bulunamadı")
                        .padding(.top, 40)
                } else {
                    ForEach(vm.filteredDoctors) { doctor in
                        BookingDoctorCard(doctor: doctor, isSelected: vm.form.doctor?.id == doctor.id) {
                            withAnimation(.spring(response: 0.3)) {
                                vm.form.doctor = doctor
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer(minLength: 120)
            }
            .padding(.top, 16)
        }
    }
}

private struct BookingDoctorCard: View {
    let doctor: Doctor
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(doctor.accentColor.opacity(0.15))
                        .frame(width: 54, height: 54)
                    Text(doctor.avatarInitials)
                        .font(.custom("Georgia", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(doctor.accentColor)
                }
                .overlay(
                    Circle().stroke(isSelected ? Color.kyAccent : Color.clear, lineWidth: 2)
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(doctor.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.kyText)
                    Text("\(doctor.title) · \(doctor.specialty)")
                        .font(.system(size: 12))
                        .foregroundColor(.kySubtext)

                    HStack(spacing: 10) {
                        Label(doctor.experience, systemImage: "clock")
                        Label(doctor.satisfactionRate, systemImage: "star.fill")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.kyAccent)

                    // Available days chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(doctor.availableDays.prefix(4), id: \.self) { day in
                                Text(String(day.prefix(3)))
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.kyAccent)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.kyAccent.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .kyAccent : .kyBorder)
            }
            .padding(14)
            .background(Color.kySurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.kyAccent : Color.kyBorder,
                            lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: isSelected ? Color.kyAccent.opacity(0.12) : .clear, radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// =========================================================================
// MARK: - STEP 3: Date & Slot Selection
// =========================================================================

private struct DateStepView: View {
    @ObservedObject var vm: BookingViewModel

    private let weekdaySymbols = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // ── Calendar ──────────────────────────────────────────────
                VStack(spacing: 0) {
                    // Month header
                    HStack {
                        Button(action: vm.prevMonth) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.kyAccent)
                                .frame(width: 36, height: 36)
                                .background(Color.kyAccent.opacity(0.12), in: Circle())
                        }
                        Spacer()
                        Text(monthYearString(vm.calendarDisplayMonth))
                            .font(.custom("Georgia", size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.kyText)
                        Spacer()
                        Button(action: vm.nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.kyAccent)
                                .frame(width: 36, height: 36)
                                .background(Color.kyAccent.opacity(0.12), in: Circle())
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 14)

                    // Weekday header
                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(weekdaySymbols, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.kySubtext)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 8)

                    // Day grid
                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(vm.calendarDays) { day in
                            BookingCalendarDayCell(day: day) {
                                vm.selectDate(day)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.kySurface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
                .padding(.horizontal, 20)

                // ── Time Slots ────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Müsait Saatler")
                            .font(.custom("Georgia", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.kyText)
                        Spacer()
                        let available = vm.availableSlots.filter(\.isAvailable).count
                        Text("\(available) müsait")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.kyAccent)
                    }
                    .padding(.horizontal, 20)

                    if vm.isLoadingSlots {
                        HStack { Spacer(); ProgressView().tint(.kyAccent); Spacer() }
                            .frame(height: 80)
                    } else if vm.availableSlots.isEmpty {
                        EmptyStateView(icon: "clock.badge.xmark", message: "Bu gün için müsait saat yok")
                            .frame(height: 80)
                    } else {
                        let slotColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
                        LazyVGrid(columns: slotColumns, spacing: 10) {
                            ForEach(vm.availableSlots) { slot in
                                SlotCell(slot: slot, isSelected: vm.form.selectedSlot?.id == slot.id) {
                                    guard slot.isAvailable else { return }
                                    withAnimation(.spring(response: 0.25)) {
                                        vm.form.selectedSlot = slot
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                // ── Duration picker ───────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Text("Randevu Süresi")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.kyText)
                        .padding(.horizontal, 20)

                    HStack(spacing: 10) {
                        ForEach([30, 45, 60], id: \.self) { dur in
                            Button {
                                vm.form.durationMinutes = dur
                                Task { await vm.loadAvailableSlots() }
                            } label: {
                                Text("\(dur) dk")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(vm.form.durationMinutes == dur ? .white : .kySubtext)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(vm.form.durationMinutes == dur ? Color.kyAccent : Color.kySurface)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.kyBorder, lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .animation(.spring(response: 0.25), value: vm.form.durationMinutes)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 120)
            }
            .padding(.top, 16)
        }
    }

    private func monthYearString(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: date).capitalized
    }
}

private struct BookingCalendarDayCell: View {
    let day: BookingViewModel.CalendarDay
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if day.isSelected {
                    Circle().fill(Color.kyAccent)
                } else if day.isToday {
                    Circle().fill(Color.kyAccent.opacity(0.20))
                }

                Text("\(day.dayNumber)")
                    .font(.system(size: 13, weight: day.isSelected || day.isToday ? .bold : .regular))
                    .foregroundColor(
                        day.isSelected     ? .white :
                        day.isPast         ? Color.kyBorder :
                        !day.isCurrentMonth ? Color.kyBorder :
                        !day.isDoctorAvailable ? Color.kyCard :
                        day.isToday        ? .kyAccent :
                        .kyText
                    )
            }
            .frame(height: 36)
        }
        .disabled(day.isPast || !day.isCurrentMonth || !day.isDoctorAvailable)
        .animation(.spring(response: 0.2), value: day.isSelected)
    }
}

private struct SlotCell: View {
    let slot: TimeSlot
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(slot.time)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(
                    isSelected      ? .white :
                    !slot.isAvailable ? Color.kyCard :
                    .kyText
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isSelected       ? Color.kyAccent :
                    !slot.isAvailable ? Color.kyCard.opacity(0.3) :
                    Color.kySurface
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected        ? Color.kyAccent :
                            !slot.isAvailable ? Color.clear :
                            Color.kyBorder,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(!slot.isAvailable)
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

// =========================================================================
// MARK: - STEP 4: Confirm
// =========================================================================

private struct ConfirmStepView: View {
    @ObservedObject var vm: BookingViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                // Summary card
                VStack(spacing: 0) {
                    ConfirmRow(
                        icon: "stethoscope", label: "Hizmet",
                        value: vm.form.service?.title ?? "—",
                        color: Color(colorName: vm.form.service?.colorName ?? "blue")
                    )
                    Divider().background(Color.kyBorder).padding(.leading, 52)

                    ConfirmRow(
                        icon: "person.fill", label: "Doktor",
                        value: vm.form.doctor.map { "\($0.title) \($0.name)" } ?? "—",
                        color: .kyAccent
                    )
                    Divider().background(Color.kyBorder).padding(.leading, 52)

                    ConfirmRow(
                        icon: "mappin.circle.fill", label: "Klinik",
                        value: vm.form.clinic?.name ?? "—",
                        color: .kyAccent
                    )
                    Divider().background(Color.kyBorder).padding(.leading, 52)

                    ConfirmRow(
                        icon: "calendar", label: "Tarih",
                        value: formattedDate(vm.form.date),
                        color: .kyAccent
                    )
                    Divider().background(Color.kyBorder).padding(.leading, 52)

                    ConfirmRow(
                        icon: "clock.fill", label: "Saat",
                        value: vm.form.selectedSlot?.time ?? "—",
                        color: .kyAccent
                    )
                    Divider().background(Color.kyBorder).padding(.leading, 52)

                    ConfirmRow(
                        icon: "timer", label: "Süre",
                        value: "\(vm.form.durationMinutes) dakika",
                        color: .kySubtext
                    )
                }
                .background(Color.kySurface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
                .padding(.horizontal, 20)

                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notunuz (isteğe bağlı)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.kyText)

                    ZStack(alignment: .topLeading) {
                        if vm.form.notes.isEmpty {
                            Text("Doktorunuza iletmek istediğiniz bilgiler…")
                                .foregroundColor(.kySubtext)
                                .font(.system(size: 14))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $vm.form.notes)
                            .font(.system(size: 14))
                            .foregroundColor(.kyText)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                    }
                    .padding(12)
                    .background(Color.kySurface)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.kyBorder, lineWidth: 1))
                }
                .padding(.horizontal, 20)

                // Consent note
                HStack(spacing: 8) {
                    Image(systemName: "info.circle").foregroundColor(.kySubtext)
                    Text("Randevunuz kliniğimiz tarafından onaylandıktan sonra bildirim alacaksınız.")
                        .font(.system(size: 12))
                        .foregroundColor(.kySubtext)
                }
                .padding(12)
                .background(Color.kyAccent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 20)

                Spacer(minLength: 120)
            }
            .padding(.top, 16)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "d MMMM yyyy, EEEE"
        return fmt.string(from: date)
    }
}

private struct ConfirmRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 32)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.kySubtext)
                .frame(width: 60, alignment: .leading)

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.kyText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// =========================================================================
// MARK: - Bottom Navigation Bar
// =========================================================================

private struct BookingNavigationBar: View {
    @ObservedObject var vm: BookingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Divider().background(Color.kyBorder)
            HStack(spacing: 14) {
                // Summary of selections
                VStack(alignment: .leading, spacing: 2) {
                    if let service = vm.form.service {
                        Text(service.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.kyText)
                            .lineLimit(1)
                    }
                    if let slot = vm.form.selectedSlot {
                        Text("\(formattedShortDate(vm.form.date)) · \(slot.time)")
                            .font(.system(size: 11))
                            .foregroundColor(.kySubtext)
                    } else if let doctor = vm.form.doctor {
                        Text(doctor.name)
                            .font(.system(size: 11))
                            .foregroundColor(.kySubtext)
                    } else {
                        Text("Seçim yapın")
                            .font(.system(size: 11))
                            .foregroundColor(.kySubtext)
                    }
                }

                Spacer()

                // Primary action button
                Button(action: {
                    if vm.currentStep == .confirm {
                        Task { await vm.confirmBooking() }
                    } else {
                        vm.advance()
                    }
                }) {
                    HStack(spacing: 6) {
                        if vm.isSaving {
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Text(vm.currentStep == .confirm ? "Randevu Al" : "Devam Et")
                                .font(.system(size: 15, weight: .semibold))
                            Image(systemName: vm.currentStep == .confirm ? "checkmark" : "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(vm.canAdvance() ? Color.kyAccent : Color.kyBorder)
                    .clipShape(Capsule())
                    .shadow(color: vm.canAdvance() ? Color.kyAccent.opacity(0.3) : .clear, radius: 8, y: 4)
                }
                .disabled(!vm.canAdvance() || vm.isSaving)
                .animation(.spring(response: 0.3), value: vm.canAdvance())
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 28)
            .background(Color.kyBackground)
        }
    }

    private func formattedShortDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "d MMM"
        return fmt.string(from: date)
    }
}

private struct BookingSuccessView: View {
    @ObservedObject var vm: BookingViewModel
    let dismiss: DismissAction
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(Color.kyAccent.opacity(0.08))
                    .frame(width: 140, height: 140)
                    .scaleEffect(animate ? 1.0 : 0.3)
                
                Circle()
                    .fill(Color.kyAccent.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(animate ? 1.0 : 0.3)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.kyAccent)
                    .scaleEffect(animate ? 1.0 : 0.0)
                    .opacity(animate ? 1.0 : 0.0)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1), value: animate)
            
            VStack(spacing: 10) {
                Text("Randevunuz Alındı!")
                    .font(.custom("Georgia", size: 26))
                    .fontWeight(.semibold)
                    .foregroundColor(.kyText)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.5).delay(0.35), value: animate)
                
                Text("Kliniğimiz randevunuzu onayladıktan sonra bildirim alacaksınız.")
                    .font(.system(size: 14))
                    .foregroundColor(.kySubtext)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 10)
                    .animation(.spring(response: 0.5).delay(0.5), value: animate)
            }
            
            // Summary pill
            if let slot = vm.form.selectedSlot, let doctor = vm.form.doctor {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.checkmark")
                        .foregroundColor(.kyAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedDate(vm.form.date) + " · " + slot.time)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.kyText)
                        Text(doctor.name)
                            .font(.system(size: 12))
                            .foregroundColor(.kySubtext)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.kySurface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.kyBorder, lineWidth: 1))
                .padding(.horizontal, 28)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 15)
                .animation(.spring(response: 0.5).delay(0.65), value: animate)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: { vm.reset(); dismiss() }) {
                    Text("Ana Sayfaya Dön")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.kyAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button(action: { vm.reset() }) {
                    Text("Yeni Randevu Al")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.kyAccent)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
            .opacity(animate ? 1 : 0)
            .animation(.easeIn(duration: 0.3).delay(0.8), value: animate)
        }
        .background(Color.kyBackground.ignoresSafeArea())
        .onAppear { animate = true }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "d MMMM"
        return fmt.string(from: date)
    }
}

// =========================================================================
// MARK: - Shared helper views
// =========================================================================

private struct EmptyStateView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(Color.kyBorder)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.kySubtext)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        BookingView()
    }
}

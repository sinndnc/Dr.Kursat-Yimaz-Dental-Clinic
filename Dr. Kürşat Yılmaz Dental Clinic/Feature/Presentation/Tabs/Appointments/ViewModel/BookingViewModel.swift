//
//  BookingViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Combine
import SwiftUI
import FirebaseFirestore

@MainActor
final class BookingViewModel: ObservableObject {

    // MARK: Step management
    enum Step: Int, CaseIterable {
        case service = 0
        case doctor  = 1
        case date    = 2
        case confirm = 3

        var title: String {
            switch self {
            case .service: return "Hizmet"
            case .doctor:  return "Doktor"
            case .date:    return "Tarih & Saat"
            case .confirm: return "Onay"
            }
        }
    }

    @Published var currentStep: Step = .service
    @Published var form = BookingForm()

    // MARK: Catalog data (from Firestore)
    @Published private(set) var services: [Service] = []
    @Published private(set) var doctors:  [Doctor]        = []
    @Published private(set) var clinics:  [Clinic]        = []

    // MARK: Calendar state
    @Published var calendarDisplayMonth: Date = Date()
    @Published private(set) var calendarDays: [CalendarDay] = []

    // MARK: Slots
    @Published private(set) var availableSlots: [TimeSlot] = []
    @Published private(set) var isLoadingSlots = false

    // MARK: Filters for doctor/service list
    @Published var serviceSearchQuery: String = "" { didSet { filterServices() } }
    @Published var selectedCategory: ServiceCategory? { didSet { filterServices() } }
    @Published private(set) var filteredServices: [Service] = []
    @Published var doctorSearchQuery: String = "" { didSet { filterDoctors() } }
    @Published private(set) var filteredDoctors: [Doctor] = []

    // MARK: Booking result
    @Published private(set) var isSaving   = false
    @Published private(set) var isSuccess  = false
    @Published var errorMessage: String?
    @Published var validationErrors: [String] = []

    // MARK: Private
    private let db = Firestore.firestore()
    private let authService = AuthService.shared
    private var listeners: [ListenerRegistration] = []

    // MARK: Init
    init() {
        startCatalogListeners()
        buildCalendar(for: Date())
    }

    deinit { listeners.forEach { $0.remove() } }

    // =========================================================================
    // MARK: - Catalog Listeners
    // =========================================================================

    private func startCatalogListeners() {
        let sl = db.collection("dental_services").whereField("is_active", isEqualTo: true)
            .order(by: "title")
            .addSnapshotListener { [weak self] snap, _ in
                self?.services = (try? snap?.documents.compactMap { try $0.data(as: Service.self) }) ?? []
                self?.filterServices()
            }

        let dl = db.collection("doctors").whereField("is_active", isEqualTo: true)
            .order(by: "name")
            .addSnapshotListener { [weak self] snap, _ in
                self?.doctors = (try? snap?.documents.compactMap { try $0.data(as: Doctor.self) }) ?? []
                self?.filterDoctors()
            }

        let cl = db.collection("clinics").whereField("is_active", isEqualTo: true)
            .order(by: "name")
            .addSnapshotListener { [weak self] snap, _ in
                self?.clinics = (try? snap?.documents.compactMap { try $0.data(as: Clinic.self) }) ?? []
                if self?.form.clinic == nil { self?.form.clinic = self?.clinics.first }
            }

        listeners = [sl, dl, cl]
    }

    // =========================================================================
    // MARK: - Filtering
    // =========================================================================

    private func filterServices() {
        var r = services
        if let cat = selectedCategory { r = r.filter { $0.category == cat } }
        if !serviceSearchQuery.isEmpty {
            let q = serviceSearchQuery.lowercased()
            r = r.filter { $0.title.lowercased().contains(q) || $0.tags.contains { $0.lowercased().contains(q) } }
        }
        filteredServices = r
    }

    private func filterDoctors() {
        var r = doctors
        // Filter by service specialty if a service is selected
        if let service = form.service {
            r = r.filter { $0.specialty.lowercased().contains(service.category.rawValue.lowercased()) || true }
        }
        if !doctorSearchQuery.isEmpty {
            let q = doctorSearchQuery.lowercased()
            r = r.filter { $0.name.lowercased().contains(q) || $0.specialty.lowercased().contains(q) }
        }
        filteredDoctors = r
    }

    // =========================================================================
    // MARK: - Step Navigation
    // =========================================================================

    func canAdvance() -> Bool {
        switch currentStep {
        case .service: return form.service != nil
        case .doctor:  return form.doctor  != nil
        case .date:    return form.selectedSlot != nil
        case .confirm: return true
        }
    }

    func advance() {
        guard canAdvance() else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
            switch currentStep {
            case .service: currentStep = .doctor
            case .doctor:  currentStep = .date; Task { await loadAvailableSlots() }
            case .date:    currentStep = .confirm
            case .confirm: break
            }
        }
    }

    func goBack() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
            switch currentStep {
            case .service: break
            case .doctor:  currentStep = .service
            case .date:    currentStep = .doctor
            case .confirm: currentStep = .date
            }
        }
    }

    func selectStep(_ step: Step) {
        guard step.rawValue < currentStep.rawValue else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
            currentStep = step
        }
    }

    // =========================================================================
    // MARK: - Calendar
    // =========================================================================

    struct CalendarDay: Identifiable {
        let id: String
        let date: Date
        let dayNumber: Int
        let isCurrentMonth: Bool
        let isToday: Bool
        let isPast: Bool
        var isSelected: Bool
        var isDoctorAvailable: Bool
    }

    func buildCalendar(for month: Date) {
        calendarDisplayMonth = month
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: month)),
              let monthEnd   = cal.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart),
              let gridStart  = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: monthStart))
        else { return }

        let selectedDate = cal.startOfDay(for: form.date)
        var days: [CalendarDay] = []
        var cursor = gridStart

        while cursor <= monthEnd || days.count % 7 != 0 {
            let isCurrentMonth = cal.component(.month, from: cursor) == cal.component(.month, from: month)
            let isToday = cal.isDateInToday(cursor)
            let isPast  = cursor < today
            let isDoctorAvailable: Bool = {
                guard let doctor = form.doctor else { return !isPast }
                let fmt = DateFormatter()
                fmt.locale = Locale(identifier: "tr_TR")
                fmt.dateFormat = "EEEE"
                return !isPast && doctor.availableDays.contains(fmt.string(from: cursor).capitalized)
            }()

            days.append(CalendarDay(
                id: ISO8601DateFormatter().string(from: cursor),
                date: cursor,
                dayNumber: cal.component(.day, from: cursor),
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                isPast: isPast,
                isSelected: cal.startOfDay(for: cursor) == selectedDate,
                isDoctorAvailable: isDoctorAvailable
            ))
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? cursor
            if days.count > 42 { break }
        }
        calendarDays = days
    }

    func selectDate(_ day: CalendarDay) {
        guard !day.isPast, day.isCurrentMonth else { return }
        form.date = day.date
        form.selectedSlot = nil
        buildCalendar(for: calendarDisplayMonth)
        Task { await loadAvailableSlots() }
    }

    func prevMonth() {
        guard let prev = Calendar.current.date(byAdding: .month, value: -1, to: calendarDisplayMonth) else { return }
        buildCalendar(for: prev)
    }

    func nextMonth() {
        guard let next = Calendar.current.date(byAdding: .month, value: 1, to: calendarDisplayMonth) else { return }
        buildCalendar(for: next)
    }

    // =========================================================================
    // MARK: - Available Slots
    // =========================================================================

    func loadAvailableSlots() async {
        guard let doctor = form.doctor else { return }
        isLoadingSlots = true
        defer { isLoadingSlots = false }

        let dayStart = Calendar.current.startOfDay(for: form.date)
        let dayEnd   = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        do {
            let snap = try await db.collection("appointments")
                .whereField("doctor_id", isEqualTo: doctor.id ?? "")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: dayStart))
                .whereField("date", isLessThan:             Timestamp(date: dayEnd))
                .getDocuments()

            let booked = try snap.documents
                .compactMap { try $0.data(as: Appointment.self) }
                .filter { $0.status != .cancelled }

            availableSlots = generateSlots(for: form.date).map { slot in
                var s = slot
                s.isAvailable = !booked.contains { appt in
                    slotsOverlap(a: slot.time, aDur: form.durationMinutes,
                                 b: appt.time, bDur: appt.durationMinutes)
                }
                return s
            }
        } catch {
            availableSlots = generateSlots(for: form.date)
        }
    }

    private func generateSlots(for date: Date) -> [TimeSlot] {
        var slots: [TimeSlot] = []
        let cal = Calendar.current
        var cur = cal.date(bySettingHour: 9,  minute: 0, second: 0, of: date)!
        let end = cal.date(bySettingHour: 18, minute: 0, second: 0, of: date)!
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"
        let iso = ISO8601DateFormatter()
        while cur < end {
            slots.append(TimeSlot(id: iso.string(from: cur), time: fmt.string(from: cur), date: cur, isAvailable: true))
            cur = cal.date(byAdding: .minute, value: 30, to: cur) ?? end
        }
        return slots
    }

    private func slotsOverlap(a: String, aDur: Int, b: String, bDur: Int) -> Bool {
        func m(_ t: String) -> Int? { let p = t.split(separator:":").compactMap{Int($0)}; return p.count==2 ? p[0]*60+p[1] : nil }
        guard let ai = m(a), let bi = m(b) else { return false }
        return ai < bi + bDur && ai + aDur > bi
    }

    // =========================================================================
    // MARK: - Book Appointment
    // =========================================================================

    func confirmBooking() async {
        guard let patient = authService.currentPatient,
              let uid = authService.currentUID else {
            validationErrors = ["Giriş yapmanız gerekiyor."]; return
        }
        form.patientId   = uid
        form.patientName = patient.fullName

        let errors = form.validate()
        guard errors.isEmpty else { validationErrors = errors; return }

        isSaving = true
        defer { isSaving = false }

        let appointment = form.toAppointment()
        do {
            let ref = db.collection("appointments").document()
            try ref.setData(from: appointment)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { isSuccess = true }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        form = BookingForm()
        currentStep = .service
        availableSlots = []
        isSuccess = false
        validationErrors = []
        errorMessage = nil
        doctorSearchQuery = ""
        serviceSearchQuery = ""
        selectedCategory = nil
        buildCalendar(for: Date())
    }
}

// MARK: - AppointmentViewModel.swift
// Customer-facing ViewModel.
// A patient can: view their own appointments, book new ones,
// reschedule upcoming ones, cancel, and add personal notes.
// They CANNOT touch other patients' data.

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

/// A bookable time slot shown in the booking picker
struct TimeSlot: Identifiable, Hashable {
    let id: String          // ISO8601 string of the date+time
    let time: String        // "09:00"
    let date: Date
    var isAvailable: Bool
    var isSelected: Bool = false
}

/// Groups appointments by visual section for the list screen
struct AppointmentSection: Identifiable {
    let id: String
    let title: String       // "Bugün", "Yarın", "Bu Hafta", "Kasım 2025"
    var appointments: [Appointment]
}

/// What happened after a booking attempt
enum BookingResult {
    case success(Appointment)
    case slotUnavailable
    case validationFailed([String])
    case failure(Error)
}

/// Summary counts for the home/dashboard widget
struct AppointmentSummary: Equatable {
    var upcomingCount: Int
    var completedCount: Int
    var cancelledCount: Int
    var nextAppointment: Appointment?
    var todayCount: Int

    static let empty = AppointmentSummary(
        upcomingCount: 0, completedCount: 0,
        cancelledCount: 0, nextAppointment: nil, todayCount: 0
    )

    static func == (lhs: AppointmentSummary, rhs: AppointmentSummary) -> Bool {
        lhs.upcomingCount  == rhs.upcomingCount  &&
        lhs.completedCount == rhs.completedCount &&
        lhs.cancelledCount == rhs.cancelledCount &&
        lhs.todayCount     == rhs.todayCount
    }
}

struct BookingForm {

    // Selected by patient
    var doctor: Doctor?
    var clinic: Clinic?
    var service: Service?
    var date: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var selectedSlot: TimeSlot?
    var type: Appointment.AppointmentType = .checkup
    var notes: String = ""
    var durationMinutes: Int = 30

    // Auto-filled from CurrentUser
    var patientId: String = ""
    var patientName: String = ""

    // MARK: Derived
    var time: String { selectedSlot?.time ?? "" }

    // MARK: Validation
    func validate() -> [String] {
        var errors: [String] = []
        if patientId.isEmpty             { errors.append("Kullanıcı oturumu bulunamadı.") }
        if doctor == nil                 { errors.append("Lütfen bir doktor seçin.") }
        if clinic == nil                 { errors.append("Lütfen bir klinik seçin.") }
        if selectedSlot == nil           { errors.append("Lütfen randevu saati seçin.") }
        if selectedSlot?.isAvailable == false { errors.append("Bu saat dolu, lütfen başka bir saat seçin.") }
        if date < Calendar.current.startOfDay(for: Date()) { errors.append("Geçmiş bir tarih seçilemez.") }
        return errors
    }

    /// Fills doctor/clinic from pre-selected service context
    mutating func apply(doctor: Doctor, clinic: Clinic) {
        self.doctor = doctor
        self.clinic = clinic
    }

    /// Converts to an Appointment ready to write to Firestore
    func toAppointment() -> Appointment {
        Appointment(
            patientId:       patientId,
            patientName:     patientName,
            doctorId:        doctor?.id ?? "",
            doctorName:      doctor?.name ?? "",
            doctorSpecialty: doctor?.specialty ?? "",
            clinicId:        clinic?.id ?? "",
            date:            date,
            time:            time,
            durationMinutes: durationMinutes,
            type:            type,
            status:          .upcoming,
            notes:           notes,
            roomNumber:      "",
            serviceId:       service?.id
        )
    }

    mutating func reset() {
        doctor = nil; clinic = nil; service = nil
        selectedSlot = nil; notes = ""
        date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        type = .checkup; durationMinutes = 30
    }
}

// =========================================================================
// MARK: - AppointmentViewModel
// =========================================================================

@MainActor
final class AppointmentViewModel: ObservableObject {

    // MARK: Published — list & sections
    @Published private(set) var appointments: [Appointment] = []
    @Published private(set) var sections: [AppointmentSection] = []
    @Published private(set) var summary: AppointmentSummary = .empty

    // MARK: Published — booking flow
    @Published var bookingForm = BookingForm()
    @Published private(set) var availableSlots: [TimeSlot] = []
    @Published private(set) var isLoadingSlots = false

    // MARK: Published — active tab filter
    @Published var activeFilter: AppointmentListFilter = .upcoming {
        didSet { buildSections() }
    }

    // MARK: Published — selected detail
    @Published var selectedAppointment: Appointment?

    // MARK: Published — sheet visibility
    @Published var showBookingSheet = false
    @Published var showRescheduleSheet = false
    @Published var showCancelAlert = false

    // MARK: Published — feedback
    @Published private(set) var isLoading = false
    @Published private(set) var isSavingBooking = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: Private
    private let db = Firestore.firestore()
    private let currentUser = AuthService.shared
    private var listenerRegistration: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Init
    init() {
        // Start listener as soon as we have a UID
        currentUser.$firebaseUser
            .compactMap { $0?.uid }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] uid in
                self?.startListener(for: uid)
            }
            .store(in: &cancellables)
    }

    deinit { listenerRegistration?.remove() }

    // =========================================================================
    // MARK: - Real-time Listener (scoped to current patient)
    // =========================================================================

    private func startListener(for patientId: String) {
        listenerRegistration?.remove()

        listenerRegistration = db.collection("appointments")
            .whereField("patient_id", isEqualTo: patientId)
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.errorMessage = "Randevular yüklenemedi: \(error.localizedDescription)"
                    return
                }
                do {
                    self.appointments = try snapshot?.documents
                        .compactMap { try $0.data(as: Appointment.self) } ?? []
                    self.buildSections()
                    self.buildSummary()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
    }

    // =========================================================================
    // MARK: - BOOKING (Customer creates appointment)
    // =========================================================================

    /// Call from the booking sheet's "Randevu Al" button.
    @discardableResult
    func bookAppointment() async -> BookingResult {
        // 1. Fill patient info from current user
        guard let patient = currentUser.currentPatient,
              let uid = currentUser.currentUID else {
            return .validationFailed(["Giriş yapmanız gerekiyor."])
        }
        bookingForm.patientId   = uid
        bookingForm.patientName = patient.fullName

        // 2. Validate form
        let errors = bookingForm.validate()
        guard errors.isEmpty else { return .validationFailed(errors) }

        // 3. Re-check slot is still free (concurrent booking guard)
        let stillFree = await isSlotStillAvailable()
        guard stillFree else {
            errorMessage = "Bu saat az önce doldu. Lütfen başka bir saat seçin."
            await loadAvailableSlots()   // refresh slots for the user
            return .slotUnavailable
        }

        // 4. Write to Firestore
        isSavingBooking = true
        defer { isSavingBooking = false }

        let appointment = bookingForm.toAppointment()
        do {
            let ref = db.collection("appointments").document()
            try ref.setData(from: appointment)
            var saved = appointment
            saved.id = ref.documentID
            successMessage = "Randevunuz başarıyla alındı! 🎉"
            showBookingSheet = false
            bookingForm.reset()
            return .success(saved)
        } catch {
            errorMessage = "Randevu oluşturulamadı: \(error.localizedDescription)"
            return .failure(error)
        }
    }

    // =========================================================================
    // MARK: - RESCHEDULE (Customer moves their own appointment)
    // =========================================================================

    func reschedule(_ appointment: Appointment, to newDate: Date, newSlot: TimeSlot) async {
        guard let id = appointment.id else { return }
        guard newSlot.isAvailable else {
            errorMessage = "Seçilen saat dolu. Lütfen başka bir saat seçin."
            return
        }
        // Guard: only the owner can reschedule
        guard appointment.patientId == currentUser.currentUID else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await db.collection("appointments").document(id).updateData([
                "date":       Timestamp(date: newDate),
                "time":       newSlot.time,
                "status":     Appointment.AppointmentStatus.upcoming.rawValue,
                "updated_at": Timestamp(date: Date())
            ])
            successMessage = "Randevunuz \(newSlot.time) saatine taşındı."
            showRescheduleSheet = false
        } catch {
            errorMessage = "Randevu güncellenemedi: \(error.localizedDescription)"
        }
    }

    // =========================================================================
    // MARK: - CANCEL (Customer cancels their own upcoming appointment)
    // =========================================================================

    func cancelAppointment(_ appointment: Appointment) async {
        guard let id = appointment.id else { return }
        // Guard: only owner can cancel, only upcoming/inProgress
        guard appointment.patientId == currentUser.currentUID,
              appointment.status == .upcoming || appointment.status == .inProgress else {
            errorMessage = "Bu randevu iptal edilemez."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await db.collection("appointments").document(id).updateData([
                "status":     Appointment.AppointmentStatus.cancelled.rawValue,
                "updated_at": Timestamp(date: Date())
            ])
            successMessage = "Randevunuz iptal edildi."
            showCancelAlert = false
            selectedAppointment = nil
        } catch {
            errorMessage = "İptal işlemi başarısız: \(error.localizedDescription)"
        }
    }

    // =========================================================================
    // MARK: - ADD / UPDATE PERSONAL NOTE
    // =========================================================================

    func updateNote(for appointment: Appointment, note: String) async {
        guard let id = appointment.id,
              appointment.patientId == currentUser.currentUID else { return }

        do {
            try await db.collection("appointments").document(id).updateData([
                "notes":      note,
                "updated_at": Timestamp(date: Date())
            ])
            successMessage = "Notunuz kaydedildi."
        } catch {
            errorMessage = "Not kaydedilemedi: \(error.localizedDescription)"
        }
    }

    // =========================================================================
    // MARK: - AVAILABLE SLOTS
    // =========================================================================

    /// Loads free slots for the doctor + date currently in bookingForm.
    func loadAvailableSlots() async {
        guard let doctor = bookingForm.doctor else { return }

        isLoadingSlots = true
        defer { isLoadingSlots = false }

        // Fetch all non-cancelled appointments for this doctor on this day
        let dayStart = Calendar.current.startOfDay(for: bookingForm.date)
        let dayEnd   = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        do {
            let snapshot = try await db.collection("appointments")
                .whereField("doctor_id", isEqualTo: doctor.id ?? "")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: dayStart))
                .whereField("date", isLessThan: Timestamp(date: dayEnd))
                .getDocuments()

            let booked = try snapshot.documents
                .compactMap { try $0.data(as: Appointment.self) }
                .filter { $0.status != .cancelled }

            let raw = generateSlots(for: bookingForm.date)
            availableSlots = raw.map { slot in
                var s = slot
                s.isAvailable = !booked.contains { appt in
                    slotsOverlap(
                        slotTime: slot.time, slotDuration: bookingForm.durationMinutes,
                        bookedTime: appt.time, bookedDuration: appt.durationMinutes
                    )
                }
                return s
            }
        } catch {
            errorMessage = "Müsait saatler yüklenemedi: \(error.localizedDescription)"
            availableSlots = generateSlots(for: bookingForm.date)   // show all, server validates
        }
    }

    /// Reload slots when the date changes in the booking form
    func onDateChanged() async {
        bookingForm.selectedSlot = nil
        await loadAvailableSlots()
    }

    /// Reload slots when the doctor changes
    func onDoctorChanged() async {
        bookingForm.selectedSlot = nil
        await loadAvailableSlots()
    }

    // =========================================================================
    // MARK: - COMPUTED VIEWS
    // =========================================================================

    var upcomingAppointments: [Appointment] {
        appointments
            .filter { $0.status == .upcoming && $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }

    var pastAppointments: [Appointment] {
        appointments
            .filter { $0.status == .completed || $0.status == .cancelled || $0.status == .noShow || ($0.status == .upcoming && $0.date < Date()) }
            .sorted { $0.date > $1.date }
    }

    var nextAppointment: Appointment? { upcomingAppointments.first }

    var cancelledAppointments: [Appointment] {
        appointments.filter { $0.status == .cancelled }.sorted { $0.date > $1.date }
    }

    func canCancel(_ appointment: Appointment) -> Bool {
        guard appointment.status == .upcoming else { return false }
        // Allow cancellation at least 2 hours before
        return appointment.date > Date().addingTimeInterval(2 * 3600)
    }

    func canReschedule(_ appointment: Appointment) -> Bool {
        appointment.status == .upcoming && appointment.date > Date().addingTimeInterval(3600)
    }

    // =========================================================================
    // MARK: - SECTION BUILDING
    // =========================================================================

    enum AppointmentListFilter: String, CaseIterable, Identifiable {
        case upcoming  = "Yaklaşan"
        case past      = "Geçmiş"
        case cancelled = "İptal"
        var id: String { rawValue }
    }

    private func buildSections() {
        let source: [Appointment]
        switch activeFilter {
        case .upcoming:  source = upcomingAppointments
        case .past:      source = pastAppointments
        case .cancelled: source = cancelledAppointments
        }

        let cal = Calendar.current
        let today    = cal.startOfDay(for: Date())
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
        let weekEnd  = cal.date(byAdding: .day, value: 7, to: today)!

        var todayGroup:    [Appointment] = []
        var tomorrowGroup: [Appointment] = []
        var thisWeekGroup: [Appointment] = []
        var monthGroups:   [String: [Appointment]] = [:]

        let monthFmt = DateFormatter()
        monthFmt.locale = Locale(identifier: "tr_TR")
        monthFmt.dateFormat = "MMMM yyyy"

        for appt in source {
            let d = cal.startOfDay(for: appt.date)
            if d == today                       { todayGroup.append(appt) }
            else if d == cal.startOfDay(for: tomorrow) { tomorrowGroup.append(appt) }
            else if d > today && d < weekEnd    { thisWeekGroup.append(appt) }
            else {
                let key = monthFmt.string(from: appt.date)
                monthGroups[key, default: []].append(appt)
            }
        }

        var result: [AppointmentSection] = []
        if !todayGroup.isEmpty    { result.append(.init(id: "today",    title: "Bugün",    appointments: todayGroup))    }
        if !tomorrowGroup.isEmpty { result.append(.init(id: "tomorrow", title: "Yarın",    appointments: tomorrowGroup)) }
        if !thisWeekGroup.isEmpty { result.append(.init(id: "week",     title: "Bu Hafta", appointments: thisWeekGroup)) }

        let orderedKeys = monthGroups.keys.sorted {
            (monthFmt.date(from: $0) ?? .distantPast) < (monthFmt.date(from: $1) ?? .distantPast)
        }
        for key in orderedKeys {
            if let group = monthGroups[key] {
                result.append(.init(id: key, title: key, appointments: group))
            }
        }
        sections = result
    }

    // =========================================================================
    // MARK: - SUMMARY (Dashboard widget)
    // =========================================================================

    private func buildSummary() {
        let cal = Calendar.current
        let today    = cal.startOfDay(for: Date())
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!

        summary = AppointmentSummary(
            upcomingCount:  upcomingAppointments.count,
            completedCount: appointments.filter { $0.status == .completed }.count,
            cancelledCount: appointments.filter { $0.status == .cancelled }.count,
            nextAppointment: nextAppointment,
            todayCount: appointments.filter { $0.date >= today && $0.date < tomorrow }.count
        )
    }

    // =========================================================================
    // MARK: - Private Helpers
    // =========================================================================

    /// Checks Firestore one more time before confirming the booking.
    private func isSlotStillAvailable() async -> Bool {
        guard let doctor = bookingForm.doctor,
              let slot = bookingForm.selectedSlot else { return false }

        let dayStart = Calendar.current.startOfDay(for: bookingForm.date)
        let dayEnd   = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        do {
            let snapshot = try await db.collection("appointments")
                .whereField("doctor_id", isEqualTo: doctor.id ?? "")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: dayStart))
                .whereField("date", isLessThan: Timestamp(date: dayEnd))
                .getDocuments()

            let booked = try snapshot.documents
                .compactMap { try $0.data(as: Appointment.self) }
                .filter { $0.status != .cancelled }

            return !booked.contains { appt in
                slotsOverlap(
                    slotTime: slot.time, slotDuration: bookingForm.durationMinutes,
                    bookedTime: appt.time, bookedDuration: appt.durationMinutes
                )
            }
        } catch { return true }
    }

    /// 09:00–18:00 in 30-min slots
    private func generateSlots(for date: Date) -> [TimeSlot] {
        var slots: [TimeSlot] = []
        let cal = Calendar.current
        var current = cal.date(bySettingHour: 9,  minute: 0, second: 0, of: date)!
        let closing = cal.date(bySettingHour: 18, minute: 0, second: 0, of: date)!
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"
        let iso = ISO8601DateFormatter()

        while current < closing {
            slots.append(TimeSlot(
                id: iso.string(from: current),
                time: fmt.string(from: current),
                date: current,
                isAvailable: true
            ))
            current = cal.date(byAdding: .minute, value: 30, to: current) ?? closing
        }
        return slots
    }

    private func slotsOverlap(
        slotTime: String,   slotDuration: Int,
        bookedTime: String, bookedDuration: Int
    ) -> Bool {
        func mins(_ t: String) -> Int? {
            let p = t.split(separator: ":").compactMap { Int($0) }
            return p.count == 2 ? p[0] * 60 + p[1] : nil
        }
        guard let a = mins(slotTime), let b = mins(bookedTime) else { return false }
        return a < b + bookedDuration && a + slotDuration > b
    }
}

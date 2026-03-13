import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

@MainActor
final class AppointmentViewModel: ObservableObject {
    
    @Injected private var repository: AppointmentRepositoryProtocol

    @Published var searchText: String = ""
    @Published var showSearch: Bool = false
    @Published var showCalendar: Bool = false
    @Published var headerAppeared: Bool = false
    @Published var currentMonth: Date = Date()
    @Published var selectedCalendarDate: Date? = nil
    @Published var selectedAppointment: Appointment?
    @Published var selectedFilter: AppointmentFilter = .all
    
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var appointments: [Appointment] = []
    @Published private(set) var error: AppointmentRepositoryError? = nil
    
    
    private var cancellables = Set<AnyCancellable>()
    /// Mevcut kullanıcı ID'si — realtime listener için gerekli.
    private var currentUserId: String? { Auth.auth().currentUser?.uid }
    
    init() {
        startObserving()
    }
    
    var nextAppointment: Appointment? { upcoming.first }
    
    var upcoming: [Appointment] {
        appointments.filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }
    
    var past: [Appointment] {
        appointments.filter { $0.date < Date() }
            .sorted { $0.date > $1.date }
    }
    
    var next: Appointment? { upcoming.first }
    
    private func startObserving() {
        guard let patientId = currentUserId else {
            isLoading = false
            return
        }
        
        repository
            .observeByPatient(patientId: patientId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.error = err
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] appointments in
                self?.appointments = appointments
                self?.isLoading = false
                self?.error = nil
            }
            .store(in: &cancellables)
    }
    
    //
    // Randevu oluşturulduğunda (AppointmentViewModel veya benzeri):
    //
    // func bookAppointment(...) async {
    //     // 1. Firestore'a yaz
    //     let appointment = try await appointmentService.create(...)
    //
    //     // 2. Local reminder zamanla + in-app bildirim oluştur
    //     await notificationVM.onAppointmentConfirmed(appointment, patientId: currentUser.id)
    // }
    //
    // func cancelAppointment(_ appointment: Appointment) async {
    //     try await appointmentService.cancel(appointment)
    //     await notificationVM.onAppointmentCancelled(appointment, patientId: currentUser.id)
    // }
    //
    // func rescheduleAppointment(old: Appointment, new: Appointment) async {
    //     try await appointmentService.reschedule(old: old, new: new)
    //     await notificationVM.onAppointmentRescheduled(old: old, new: new, patientId: currentUser.id)
    // }
    
    func create(_ appointment: Appointment) async {
        do {
            let created = try await repository.create(appointment)
            // Optimistic insert — listener zaten günceller ama anında yansıtır
            if !appointments.contains(where: { $0.id == created.id }) {
                appointments.append(created)
            }
        } catch let err as AppointmentRepositoryError {
            error = err
        } catch {
            self.error = .unknown(error)
        }
    }
    
    func update(_ appointment: Appointment) async {
        do {
            try await repository.update(appointment)
        } catch let err as AppointmentRepositoryError {
            error = err
        } catch {
            self.error = .unknown(error)
        }
    }
    
    func cancel(_ appointment: Appointment) async {
        guard let id = appointment.id else { return }
        do {
            try await repository.updateStatus(id: id, status: .cancelled)
        } catch let err as AppointmentRepositoryError {
            error = err
        } catch {
            self.error = .unknown(error)
        }
    }
    
    func delete(_ appointment: Appointment) async {
        guard let id = appointment.id else { return }
        do {
            try await repository.delete(id: id)
        } catch let err as AppointmentRepositoryError {
            error = err
        } catch {
            self.error = .unknown(error)
        }
    }
    
    
    var filteredAppointments: [Appointment] {
        var base: [Appointment]
        
        switch selectedFilter {
        case .completed: base = past
        case .upcoming:  base = upcoming
        case .all:       base = appointments
        }
        
        if let date = selectedCalendarDate {
            base = base.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        }
        
        if !searchText.isEmpty {
            base = base.filter {
                $0.doctorName.localizedCaseInsensitiveContains(searchText) ||
                $0.patientName.localizedCaseInsensitiveContains(searchText) ||
                $0.type.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return base
    }
    
    var appointmentDatesInMonth: Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return Set(
            appointments
                .filter { Calendar.current.isDate($0.date, equalTo: currentMonth, toGranularity: .month) }
                .map { formatter.string(from: $0.date) }
        )
    }
    
    var appointmentsOnSelectedDate: [Appointment] {
        guard let date = selectedCalendarDate else { return [] }
        return appointments
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.time < $1.time }
    }
    
}

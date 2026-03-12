import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

@MainActor
final class AppointmentViewModel: ObservableObject {
    
    @Injected private var repository: AppointmentRepositoryProtocol
    
    @Published var selectedFilter: AppointmentFilter = .all
    @Published var showCalendar = false
    @Published var headerAppeared = false
    @Published var currentMonth: Date = Date()
    @Published var selectedCalendarDate: Date? = nil
    @Published var searchText: String = ""
    @Published var showSearch: Bool = false
    @Published var selectedAppointment: Appointment?
    
    @Published private(set) var appointments: [Appointment] = []
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var error: AppointmentRepositoryError? = nil
    
    
    private var cancellables = Set<AnyCancellable>()
    /// Mevcut kullanıcı ID'si — realtime listener için gerekli.
    private var currentUserId: String? { Auth.auth().currentUser?.uid }
    
    init() {
        startObserving()
    }
    
    
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
        case .upcoming:  base = appointments.filter { $0.status == .upcoming }
        case .completed: base = appointments.filter { $0.status == .completed }
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
    
    var nextAppointment: Appointment? { appointments.upcoming.first }
}

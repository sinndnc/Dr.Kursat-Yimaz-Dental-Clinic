import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

@MainActor
final class AppointmentViewModel: ObservableObject {
    
    @Injected private var firestoreService: FirestoreServiceProtocol
    
    @Published var selectedFilter: AppointmentFilter = .all
    @Published var showCalendar = false
    @Published var headerAppeared = false
    @Published var currentMonth: Date = Date()
    @Published var selectedCalendarDate: Date? = nil
    
    @Published var searchText: String = ""
    @Published var showSearch: Bool = false
    
    @Published var selectedAppointment: Appointment?
    @Published private(set) var appointments: [Appointment] = []
    
    
    init() {
        firestoreService.appointmentsPublisher
            .assign(to: &$appointments)
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
                $0.doctorName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return base
    }
    
    var appointmentDatesInMonth: Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return Set(appointments.map { formatter.string(from: $0.date) })
    }
}


import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

@MainActor
final class AppointmentViewModel: ObservableObject {
    
    @Injected private var firestoreService: FirestoreServiceProtocol
    
    // MARK: Published — list & sections
    @Published var selectedAppointment: Appointment?
    @Published private(set) var appointments: [Appointment] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        firestoreService.appointmentsPublisher
            .assign(to: &$appointments)
    }
    
    
}


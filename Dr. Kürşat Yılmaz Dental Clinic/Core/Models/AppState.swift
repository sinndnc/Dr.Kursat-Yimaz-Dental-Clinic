import SwiftUI
import Combine
import FirebaseFirestore
internal import FirebaseAuthInternal

// MARK: - App State (Firebase'e bağlı merkezi state)
@MainActor
class AppState: ObservableObject {
    
    // Auth
    @Published var authService  = AuthService()
    @Published var firestoreService = FirestoreService()
    
    // Data
    @Published var currentUser: User = .empty
    @Published var appointments: [Appointment] = []
    @Published var doctors: [Doctor] = []
    @Published var services: [DentalService] = []
    @Published var notifications: [NotificationItem] = []
    
    // UI
    @Published var isLoadingData: Bool = false
    @Published var globalError: String? = nil
    
    // Firestore listeners (memory leak önleme)
    private var appointmentListener: ListenerRegistration?
    private var doctorListener: ListenerRegistration?
    private var notificationListener: ListenerRegistration?
    
    init() {
        // Auth değişikliğini izle
        Task {
            for await _ in NotificationCenter.default
                .notifications(named: .AuthStateDidChange)
                .map({ _ in () }) {
                await handleAuthChange()
            }
        }
    }
    
    // MARK: - Auth değişimi
     func handleAuthChange() async {
        if authService.isLoggedIn, let uid = authService.uid {
            await loadUserData(uid: uid)
            startListeners(uid: uid)
        } else {
            stopListeners()
            clearData()
        }
    }
    
    // MARK: - İlk veri yükleme
    func loadUserData(uid: String) async {
        isLoadingData = true
        defer { isLoadingData = false }
        
        do {
            // Kullanıcı profilini çek
            currentUser = try await firestoreService.fetchUser(uid: uid)
            
            // Hizmetleri çek
            services = try await firestoreService.fetchServices()
            if services.isEmpty {
                services = []
            }
            
            // İlk kurulumda örnek verileri seed et
            
        } catch {
            globalError = error.localizedDescription
        }
    }
    
    // MARK: - Real-time listeners başlat
    func startListeners(uid: String) {
        // Randevular
        appointmentListener = firestoreService.listenAppointments(uid: uid) { [weak self] items in
            self?.appointments = items
        }
        
        // Doktorlar
//        doctorListener = firestoreService.listenDoctors { [weak self] items in
//            self?.doctors = items.isEmpty ? Doctor.sampleData : items
//        }
        
        // Bildirimler
        notificationListener = firestoreService.listenNotifications(uid: uid) { [weak self] items in
            self?.notifications = items
        }
    }
    
    // MARK: - Listeners durdur
    func stopListeners() {
        appointmentListener?.remove()
        doctorListener?.remove()
        notificationListener?.remove()
        appointmentListener = nil
        doctorListener = nil
        notificationListener = nil
    }
    
    // MARK: - Veriyi temizle (logout)
    func clearData() {
        currentUser = .empty
        appointments = []
        doctors = []
        services = []
        notifications = []
    }
    
    // MARK: - Appointment işlemleri
    func createAppointment(_ appointment: Appointment) async {
        do {
            _ = try await firestoreService.createAppointment(appointment)
            // Listener otomatik güncelleyecek
        } catch {
            globalError = error.localizedDescription
        }
    }
    
    func cancelAppointment(_ appointment: Appointment) async {
        guard let id = appointment.id else { return }
        do {
            try await firestoreService.cancelAppointment(id: id)
        } catch {
            globalError = error.localizedDescription
        }
    }
    
    // MARK: - Profil güncelle
    func updateProfile(name: String, phone: String) async {
        guard var user = Optional(currentUser), let uid = user.id else { return }
        user.name = name
        user.phone = phone
        do {
            try await firestoreService.updateUser(user)
            currentUser = user
        } catch {
            globalError = error.localizedDescription
        }
    }
    
    // MARK: - Bildirim okundu
    func markNotificationRead(_ notif: NotificationItem) async {
        guard let id = notif.id else { return }
        do {
            try await firestoreService.markNotificationRead(id: id)
        } catch {
            globalError = error.localizedDescription
        }
    }
    
    // MARK: - Computed
    var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var upcomingAppointments: [Appointment] {
        appointments.filter { $0.status == .upcoming }
            .sorted { $0.date < $1.date }
    }
    
    var nextAppointment: Appointment? {
        upcomingAppointments.first
    }
    
    // MARK: - Logout
    func logout() {
        stopListeners()
        clearData()
        authService.logout()
    }
}

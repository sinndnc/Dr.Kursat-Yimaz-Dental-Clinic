import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthService: ObservableObject {
    @Published var currentFirebaseUser: FirebaseAuth.User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    init() {
        // Auth durumu değişikliklerini dinle
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Task { @MainActor in
                self?.currentFirebaseUser = user
            }
        }
    }
    
    var isLoggedIn: Bool { currentFirebaseUser != nil }
    var uid: String? { currentFirebaseUser?.uid }
    
    // MARK: - Kayıt
    func register(name: String, email: String, phone: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Display name güncelle
            let changeReq = result.user.createProfileChangeRequest()
            changeReq.displayName = name
            try await changeReq.commitChanges()
            
            // Firestore'a kullanıcı kaydı oluştur
            let user = User(
                id: result.user.uid,
                name: name,
                email: email,
                phone: phone,
                profileImage: "person.circle.fill",
                totalVisits: 0,
                loyaltyPoints: 0,
                createdAt: Date()
            )
            try db.collection("users").document(result.user.uid).setData(from: user)
            
        } catch let err as NSError {
            errorMessage = mapAuthError(err)
            throw err
        }
    }
    
    // MARK: - Giriş
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch let err as NSError {
            errorMessage = mapAuthError(err)
            throw err
        }
    }
    
    // MARK: - Çıkış
    func logout() {
        try? Auth.auth().signOut()
    }
    
    // MARK: - Şifre Sıfırla
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let err as NSError {
            errorMessage = mapAuthError(err)
            throw err
        }
    }
    
    // MARK: - Hata mesajları Türkçeleştirme
    private func mapAuthError(_ error: NSError) -> String {
        let code = AuthErrorCode(rawValue: error.code)
        switch code {
        case .emailAlreadyInUse:    return "Bu e-posta adresi zaten kullanımda."
        case .invalidEmail:         return "Geçersiz e-posta adresi."
        case .weakPassword:         return "Şifre en az 6 karakter olmalıdır."
        case .userNotFound:         return "Kullanıcı bulunamadı."
        case .wrongPassword:        return "Hatalı şifre."
        case .networkError:         return "İnternet bağlantınızı kontrol edin."
        case .tooManyRequests:      return "Çok fazla deneme. Lütfen bekleyin."
        default:                    return "Bir hata oluştu. Lütfen tekrar deneyin."
        }
    }
}

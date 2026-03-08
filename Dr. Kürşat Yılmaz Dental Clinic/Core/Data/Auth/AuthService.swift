// MARK: - AuthService.swift
// Production-level Firebase Authentication service.
// Handles sign-in, registration, sign-out, password reset,
// session persistence, and syncs the current user's Patient profile.

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthService: ObservableObject {

    // MARK: Shared instance
    static let shared = AuthService()

    // MARK: Published state
    @Published private(set) var authState: AuthState = .loading
    @Published private(set) var firebaseUser: FirebaseAuth.User?
    @Published private(set) var currentPatient: Patient?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: Private
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var patientListener: ListenerRegistration?
    private let db = Firestore.firestore()
    private let auth = Auth.auth()

    // MARK: Convenience
    var isAuthenticated: Bool { authState == .authenticated }
    var currentUID: String? { auth.currentUser?.uid }

    // MARK: Init
    private init() {
        attachAuthStateListener()
    }

    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
        patientListener?.remove()
    }

    // =========================================================================
    // MARK: - Auth State Listener
    // =========================================================================

    private func attachAuthStateListener() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                self.firebaseUser = user
                if let user {
                    await self.handleSignedInUser(user)
                } else {
                    self.handleSignedOutUser()
                }
            }
        }
    }

    private func handleSignedInUser(_ user: FirebaseAuth.User) async {
        patientListener?.remove()
        attachPatientListener(uid: user.uid)
    }

    private func handleSignedOutUser() {
        patientListener?.remove()
        patientListener = nil
        currentPatient = nil
        authState = .unauthenticated
    }

    // =========================================================================
    // MARK: - Real-time Patient Profile Listener
    // =========================================================================

    private func attachPatientListener(uid: String) {
        patientListener = db
            .collection("patients")
            .document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                Task { @MainActor in
                    if let error {
                        print("⛔️ Patient listener error: \(error.localizedDescription)")
                        self.authState = .registrationPending
                        return
                    }
                    guard let snapshot, snapshot.exists else {
                        // Firebase user exists but no Patient doc yet
                        
                        self.authState = .registrationPending
                        return
                    }
                    do {
                        self.currentPatient = try snapshot.data(as: Patient.self)
                        self.authState = .authenticated
                    } catch {
                        print("⛔️ Patient decode error: \(error.localizedDescription)")
                        self.authState = .registrationPending
                    }
                }
            }
    }

    // =========================================================================
    // MARK: - Sign In (Email & Password)
    // =========================================================================

    func signIn(email: String, password: String) async throws {
        clearError()
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            firebaseUser = result.user
            print("Result: \(result.user.uid)")
            
            // Patient listener is attached automatically via authStateDidChange
        } catch let error as NSError {
            let message = mapFirebaseError(error)
            errorMessage = message
            throw AuthError.signInFailed(message)
        }
    }

    // =========================================================================
    // MARK: - Registration (Email & Password + Patient profile)
    // =========================================================================

    /// Creates a Firebase Auth account and writes the Patient document to Firestore.
    /// The Patient document ID equals the Firebase UID so lookups are O(1).
    func register(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phone: String? = nil,
        birthDate: Date? = nil,
        gender: Patient.Gender? = nil
    ) async throws {
        clearError()
        isLoading = true
        defer { isLoading = false }

        // 1. Create Firebase Auth user
        let result: AuthDataResult
        do {
            result = try await auth.createUser(withEmail: email, password: password)
        } catch let error as NSError {
            let message = mapFirebaseError(error)
            errorMessage = message
            throw AuthError.registrationFailed(message)
        }

        let uid = result.user.uid

        // 2. Build Patient profile (document ID = Firebase UID)
        let patient = Patient(
            id: uid,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            gender: gender,
            phone: phone,
            email: email,
            createdAt: Date(),
            updatedAt: Date()
        )

        // 3. Write Patient document to Firestore
        do {
            try db.collection("patients").document(uid).setData(from: patient)
        } catch {
            // Auth user created but Firestore write failed → mark pending
            authState = .registrationPending
            errorMessage = "Profil kaydedilemedi. Lütfen tekrar deneyin."
            throw AuthError.registrationFailed(error.localizedDescription)
        }

        // 4. Optionally send email verification
        try? await result.user.sendEmailVerification()
    }

    // =========================================================================
    // MARK: - Sign Out
    // =========================================================================

    func signOut() throws {
        do {
            try auth.signOut()
            // authStateDidChange fires → handleSignedOutUser cleans up
        } catch let error as NSError {
            let message = mapFirebaseError(error)
            errorMessage = message
            throw AuthError.signOutFailed(message)
        }
    }

    // =========================================================================
    // MARK: - Password Reset
    // =========================================================================

    func sendPasswordReset(to email: String) async throws {
        clearError()
        isLoading = true
        defer { isLoading = false }

        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            let message = mapFirebaseError(error)
            errorMessage = message
            throw AuthError.passwordResetFailed(message)
        }
    }

    // =========================================================================
    // MARK: - Update Current Patient Profile
    // =========================================================================

    /// Persists changes to the current user's Patient document.
    func updateCurrentPatient(_ updated: Patient) async throws {
        guard let uid = currentUID else { throw AuthError.userNotFound }

        var patient = updated
        patient.updatedAt = Date()

        do {
            try db.collection("patients").document(uid).setData(from: patient, merge: true)
            // currentPatient updates automatically via real-time listener
        } catch {
            throw AuthError.unknown(error)
        }
    }

    // =========================================================================
    // MARK: - Delete Account
    // =========================================================================

    /// Deletes the Firebase Auth user AND their Firestore Patient document.
    func deleteAccount() async throws {
        guard let user = auth.currentUser,
              let uid = currentUID else { throw AuthError.userNotFound }

        // 1. Delete Firestore patient document
        try await db.collection("patients").document(uid).delete()

        // 2. Delete Firebase Auth account
        do {
            try await user.delete()
        } catch let error as NSError {
            throw AuthError.unknown(error)
        }
    }

    // =========================================================================
    // MARK: - Re-authenticate (required before sensitive operations)
    // =========================================================================

    func reauthenticate(email: String, password: String) async throws {
        guard let user = auth.currentUser else { throw AuthError.userNotFound }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await user.reauthenticate(with: credential)
        } catch let error as NSError {
            throw AuthError.signInFailed(mapFirebaseError(error))
        }
    }

    // =========================================================================
    // MARK: - Change Password
    // =========================================================================

    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = auth.currentUser,
              let email = user.email else { throw AuthError.userNotFound }

        // Re-authenticate first (Firebase requires this for sensitive ops)
        try await reauthenticate(email: email, password: currentPassword)

        do {
            try await user.updatePassword(to: newPassword)
        } catch let error as NSError {
            throw AuthError.unknown(error)
        }
    }

    // =========================================================================
    // MARK: - Private Helpers
    // =========================================================================

    private func clearError() {
        errorMessage = nil
    }

    /// Maps Firebase NSError codes to human-readable Turkish messages.
    private func mapFirebaseError(_ error: NSError) -> String {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return error.localizedDescription
        }
        switch errorCode {
        case .emailAlreadyInUse:       return "Bu e-posta adresi zaten kullanımda."
        case .invalidEmail:            return "Geçersiz e-posta adresi."
        case .weakPassword:            return "Şifre en az 6 karakter olmalıdır."
        case .wrongPassword:           return "Hatalı şifre. Lütfen tekrar deneyin."
        case .userNotFound:            return "Bu e-posta adresiyle kayıtlı bir hesap bulunamadı."
        case .userDisabled:            return "Bu hesap devre dışı bırakılmıştır."
        case .networkError:            return "Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin."
        case .tooManyRequests:         return "Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin."
        case .requiresRecentLogin:     return "Bu işlem için tekrar giriş yapmanız gerekmektedir."
        case .invalidCredential:       return "Geçersiz kimlik bilgileri. Lütfen bilgilerinizi kontrol edin."
        case .operationNotAllowed:     return "Bu işlem şu anda kullanılamıyor."
        default:                       return error.localizedDescription
        }
    }
}

//
//  AuthService.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//
//  Production-level Firebase Authentication service.
//  Registered as a .singleton in DIContainer.
//
//  Responsibilities:
//  - Firebase Auth state tracking (sign-in, register, sign-out, password ops)
//  - Owns `currentPatient` — loaded from Firestore via UID on auth state change
//  - FirestoreService is NOT responsible for currentPatient

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthService: AuthServiceProtocol {
    
    @Injected private var fs: FirestoreServiceProtocol
    
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var currentPatient: Patient?
    @Published private(set) var authState: AuthState = .loading
    @Published private(set) var firebaseUser: FirebaseAuth.User?
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> { $isLoading.eraseToAnyPublisher() }
    var authStatePublisher: AnyPublisher<AuthState, Never> { $authState.eraseToAnyPublisher() }
    var errorMessagePublisher: AnyPublisher<String?, Never> { $errorMessage.eraseToAnyPublisher() }
    var currentPatientPublisher: AnyPublisher<Patient?, Never> { $currentPatient.eraseToAnyPublisher() }
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var patientListener: ListenerRegistration?
    private let db:   Firestore
    private let auth: Auth
    
    var isAuthenticated: Bool    { authState == .authenticated }
    var currentUID:      String? { auth.currentUser?.uid }
    
    init(db: Firestore, auth: Auth) {
        self.db   = db
        self.auth = auth
        attachAuthStateListener()
    }
    
    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
        patientListener?.remove()
    }
    
    private func attachAuthStateListener() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                self.firebaseUser = user
                if let user {
                    self.attachPatientListener(uid: user.uid)
                    self.fs.startAuthenticatedListeners(patientId: user.uid,clinicId: nil)
                } else {
                    self.tearDownSession()
                    self.fs.removeAuthenticatedListeners()
                }
            }
        }
    }
    
    /// Attaches a real-time Firestore listener to the authenticated user's Patient document.
    /// Sets `authState` to `.authenticated` on success, `.registrationPending` if the document
    /// doesn't exist yet or cannot be decoded (e.g. first-launch registration flow).
    private func attachPatientListener(uid: String) {
        patientListener?.remove()
        
        patientListener = db
            .collection(FSCollection.patients)
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
                        print("🟡 Patient document not found → registrationPending")
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
    
    private func tearDownSession() {
        patientListener?.remove()
        patientListener = nil
        currentPatient  = nil
        authState = .unauthenticated
        
    }
    
    func signIn(email: String, password: String) async throws {
        clearError()
        isLoading = true
        defer { isLoading = false }
        do {
            let result   = try await auth.signIn(withEmail: email, password: password)
            firebaseUser = result.user
            // Patient is loaded automatically via attachPatientListener triggered
            // by addStateDidChangeListener — no manual fetch needed here.
        } catch let error as NSError {
            let message  = mapFirebaseError(error)
            errorMessage = message
            throw AuthError.signInFailed(message)
        }
    }
    
    func register(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phone:String?         = nil,
        birthDate: Date?           = nil,
        gender:Gender? = nil
    ) async throws {
        clearError()
        isLoading = true
        defer { isLoading = false }
        
        let result: AuthDataResult
        do {
            result = try await auth.createUser(withEmail: email, password: password)
        } catch let error as NSError {
            let message  = mapFirebaseError(error)
            errorMessage = message
            throw AuthError.registrationFailed(message)
        }
        
        let uid = result.user.uid
        
        let patient = Patient(
            id:        uid,
            firstName: firstName,
            lastName:  lastName,
            birthDate: birthDate ?? .now,
            gender:    gender ?? .male,
            phone:     phone,
            email:     email,
            createdAt: Date(),
            updatedAt: Date()
        )

        // 3. Persist Patient to Firestore — the real-time listener (already attached
        //    by addStateDidChangeListener) will pick this up and set authState = .authenticated
        do {
            try db.collection(FSCollection.patients).document(uid).setData(from: patient)
        } catch {
            authState    = .registrationPending
            errorMessage = "Profil kaydedilemedi. Lütfen tekrar deneyin."
            throw AuthError.registrationFailed(error.localizedDescription)
        }

        // 4. Email verification — non-critical
        try? await result.user.sendEmailVerification()
    }

    func signOut() throws {
        do {
            try auth.signOut()
            // tearDownSession() is called automatically via addStateDidChangeListener
        } catch let error as NSError {
            let message  = mapFirebaseError(error)
            errorMessage = message
            throw AuthError.signOutFailed(message)
        }
    }

    func sendPasswordReset(to email: String) async throws {
        clearError()
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            let message  = mapFirebaseError(error)
            errorMessage = message
            throw AuthError.passwordResetFailed(message)
        }
    }

    func updateCurrentPatient(_ updated: Patient) async throws {
        guard let uid = currentUID else { throw AuthError.userNotFound }
        var patient       = updated
        patient.updatedAt = Date()
        do {
            try db.collection(FSCollection.patients).document(uid).setData(from: patient, merge: true)
            // Real-time listener updates `currentPatient` automatically
        } catch {
            throw AuthError.unknown(error)
        }
    }

    func deleteAccount() async throws {
        guard let user = auth.currentUser,
              let uid  = currentUID else { throw AuthError.userNotFound }
        try await db.collection(FSCollection.patients).document(uid).delete()
        do {
            try await user.delete()
        } catch let error as NSError {
            throw AuthError.unknown(error)
        }
    }

    func reauthenticate(email: String, password: String) async throws {
        guard let user = auth.currentUser else { throw AuthError.userNotFound }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await user.reauthenticate(with: credential)
        } catch let error as NSError {
            throw AuthError.signInFailed(mapFirebaseError(error))
        }
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user  = auth.currentUser,
              let email = user.email else { throw AuthError.userNotFound }
        try await reauthenticate(email: email, password: currentPassword)
        do {
            try await user.updatePassword(to: newPassword)
        } catch let error as NSError {
            throw AuthError.unknown(error)
        }
    }

    // MARK: - Helpers

    private func clearError() { errorMessage = nil }

    private func mapFirebaseError(_ error: NSError) -> String {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return error.localizedDescription
        }
        switch code {
        case .emailAlreadyInUse:   return "Bu e-posta adresi zaten kullanımda."
        case .invalidEmail:        return "Geçersiz e-posta adresi."
        case .weakPassword:        return "Şifre en az 6 karakter olmalıdır."
        case .wrongPassword:       return "Hatalı şifre. Lütfen tekrar deneyin."
        case .userNotFound:        return "Bu e-posta adresiyle kayıtlı bir hesap bulunamadı."
        case .userDisabled:        return "Bu hesap devre dışı bırakılmıştır."
        case .networkError:        return "Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin."
        case .tooManyRequests:     return "Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin."
        case .requiresRecentLogin: return "Bu işlem için tekrar giriş yapmanız gerekmektedir."
        case .invalidCredential:   return "Geçersiz kimlik bilgileri. Lütfen bilgilerinizi kontrol edin."
        case .operationNotAllowed: return "Bu işlem şu anda kullanılamıyor."
        default:                   return error.localizedDescription
        }
    }
}

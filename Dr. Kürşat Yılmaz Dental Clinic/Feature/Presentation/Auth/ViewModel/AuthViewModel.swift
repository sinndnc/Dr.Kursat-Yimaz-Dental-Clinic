//
//  AuthViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published private(set) var isLoading:      Bool      = false
    @Published private(set) var authState:      AuthState = .loading
    @Published private(set) var errorMessage:   String?   = nil
    @Published private(set) var currentPatient: Patient?  = nil
    
    @Injected private var authService: AuthServiceProtocol
    @Injected private var firestoreService: FirestoreServiceProtocol
    
    private var currentClinicId = "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
    private var cancellables = Set<AnyCancellable>()
    private var publicListenersStarted = false
    
    init() {
        startPublicListenersOnce()
        bindToAuthService()
    }
    
    private func startPublicListenersOnce() {
        guard !publicListenersStarted else { return }
        publicListenersStarted = true
        firestoreService.startUnauthticatedListeners(clinicId: currentClinicId)
    }
    
    private func bindToAuthService() {
        isLoading = true
        authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                // AuthService zaten tüm state yönetimini yapıyor (attachPatientListener vs.)
                // Burada sadece ViewModel'in kendi authState'ini mirror'la, yan etki yok
                self.authState = state
                self.isLoading = false
            }
            .store(in: &cancellables)
        
        authService.currentPatientPublisher
            .assign(to: &$currentPatient)
        
        authService.isLoadingPublisher
            .assign(to: &$isLoading)
        
        authService.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else { return }
                self.errorMessage = message
            }
            .store(in: &cancellables)
    }
    
    var isAuthenticated: Bool { authState == .authenticated }
    
    
    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
            await waitForAuthenticated()
        } catch {
            showError(error)
        }
    }
    
    /// authState .authenticated olana kadar bekler (max 10 saniye)
    private func waitForAuthenticated() async {
        guard authState != .authenticated else { return }
        await withCheckedContinuation { continuation in
            var resumed = false
            var cancellable: AnyCancellable?
            cancellable = authService.authStatePublisher
                .filter { $0 == .authenticated || $0 == .unauthenticated }
                .first()
                .timeout(.seconds(10), scheduler: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in
                        if !resumed { resumed = true; continuation.resume() }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in
                        if !resumed { resumed = true; continuation.resume() }
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    func register(
        email:     String,
        password:  String,
        firstName: String,
        lastName:  String,
        phone:     String? = nil,
        birthDate: Date?   = nil,
        gender:    Gender? = nil
    ) async {
        errorMessage = nil
        do {
            try await authService.register(
                email:     email,
                password:  password,
                firstName: firstName,
                lastName:  lastName,
                phone:     phone,
                birthDate: birthDate,
                gender:    gender
            )
            // Firestore'a yazıldı, şimdi patientListener authenticated yapana kadar bekle
            await waitForAuthenticated()
            if authState == .authenticated {
                ToastManager.shared.success("Hoş geldiniz!", message: "Hesabınız başarıyla oluşturuldu.")
            }
        } catch {
            showError(error)
        }
    }
    
    func signOut() {
        AlertManager.shared.confirmDestructive(
            title: "Çıkış Yapmak İstediğinize Emin Misiniz?",
            message: "Oturumunuz kapatılacak. Tekrar giriş yapmanız gerekecek.",
            confirmLabel: "Evet, Çıkış Yap"
        ) { [weak self] in
            guard let self else { return }
            do {
                try self.authService.signOut()
                ToastManager.shared.info("Çıkış yapıldı", message: "Görüşmek üzere!")
            } catch {
                self.showError(error)
            }
        }
    }
    
    func sendPasswordReset(to email: String) async {
        do {
            try await authService.sendPasswordReset(to: email)
            ToastManager.shared.success(
                "E-posta Gönderildi",
                message: "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."
            )
        } catch {
            showError(error)
        }
    }
    
    func updateCurrentPatient(_ patient: Patient) async {
        do {
            try await authService.updateCurrentPatient(patient)
            ToastManager.shared.success("Kaydedildi", message: "Bilgileriniz güncellendi.")
        } catch {
            showError(error)
        }
    }
    
    func deleteAccount() {
        AlertManager.shared.confirmDestructive(
            title: "Hesabı Kalıcı Olarak Sil",
            message: "Bu işlem geri alınamaz. Tüm verileriniz ve randevularınız silinecektir.",
            confirmLabel: "Evet, Hesabı Sil"
        ) { [weak self] in
            guard let self else { return }
            Task {
                do {
                    try await self.authService.deleteAccount()
                } catch {
                    self.showError(error)
                }
            }
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) async {
        do {
            try await authService.changePassword(
                currentPassword: currentPassword,
                newPassword:     newPassword
            )
            ToastManager.shared.success("Şifre Değiştirildi", message: "Yeni şifreniz aktif.")
        } catch {
            showError(error)
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Helpers
    
    private func showError(_ error: Error) {
        let message = error.localizedDescription
        errorMessage = message
        ToastManager.shared.error("Bir hata oluştu", message: message, duration: 4.0)
    }
}

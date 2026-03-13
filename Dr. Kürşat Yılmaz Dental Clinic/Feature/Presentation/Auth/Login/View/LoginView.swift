//
//  LoginView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

// MARK: - Login View
struct LoginView: View {
    
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var animateIn = false
    @State private var shakeOffset: CGFloat = 0
    @FocusState private var focusedField: Field?
    
    @Environment(AppNavigationState.self) private var appNav
    @EnvironmentObject private var auth: AuthViewModel
    
    enum Field { case email, password }
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            Circle()
                .fill(Color.kyAccent.opacity(0.04))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 120, y: -160)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign In")
                            .font(.kySerif(36, weight: .semibold))
                            .foregroundColor(.kyText)

                        Text("Good to have you back.")
                            .font(.kySans(15))
                            .foregroundColor(.kySubtext)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 16)

                    // Form
                    VStack(spacing: 16) {
                        KyTextField(
                            label: "Email",
                            placeholder: "you@example.com",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            isFocused: focusedField == .email
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                        KySecureField(
                            label: "Password",
                            placeholder: "••••••••",
                            text: $password,
                            showPassword: $showPassword,
                            isFocused: focusedField == .password
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil; handleLogin() }
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 16)
                    .offset(x: shakeOffset)

                    // Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot password?") {
                            handleForgotPassword()
                        }
                        .font(.kySans(13))
                        .foregroundColor(.kyAccent)
                    }
                    .padding(.top, 12)
                    .opacity(animateIn ? 1 : 0)

                    Spacer().frame(height: 36)

                    // Login Button
                    Button(action: handleLogin) {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .tint(Color.kyBackground)
                            } else {
                                Text("Sign In")
                                    .font(.kySans(16, weight: .semibold))
                                    .foregroundColor(.kyBackground)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(
                                colors: [Color.kyAccent, Color.kyAccentDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.kyAccent.opacity(0.3), radius: 20, y: 8)
                    }
                    .disabled(isLoading || !isFormValid)
                    .opacity(isFormValid ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                    // Biometric option
                    Button {
                        // Face ID / Touch ID action
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "faceid")
                                .font(.system(size: 16))
                            Text("Use Face ID")
                                .font(.kySans(14))
                        }
                        .foregroundColor(.kySubtext)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    }
                    .opacity(animateIn ? 1 : 0)

                    Spacer().frame(height: 40)

                    // Bottom divider + sign up
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Rectangle().fill(Color.kyBorder).frame(height: 1)
                            Text("New here?")
                                .font(.kySans(12))
                                .foregroundColor(.kySubtext)
                                .fixedSize()
                            Rectangle().fill(Color.kyBorder).frame(height: 1)
                        }

                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("Create an account")
                                .font(.kySans(15, weight: .medium))
                                .foregroundColor(.kyAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.kyAccent.opacity(0.08))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.kyAccent.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .opacity(animateIn ? 1 : 0)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    appNav.authSheet = nil
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Back")
                            .font(.kySans(15))
                    }
                    .foregroundColor(.kySubtext)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.8).delay(0.05)) {
                animateIn = true
            }
        }
    }

    // MARK: - Computed

    private var isFormValid: Bool {
        email.contains("@") && password.count >= 6
    }

    // MARK: - Actions

    private func handleLogin() {
        guard isFormValid else {
            triggerShake()
            ToastManager.shared.warning(
                "Eksik Bilgi",
                message: "Lütfen geçerli bir e-posta ve şifre giriniz."
            )
            return
        }
        focusedField = nil
        Task {
            withAnimation { isLoading = true }
            await auth.signIn(email: email, password: password)
            withAnimation { isLoading = false }
            guard auth.errorMessage == nil else { return }
            appNav.authSheet = nil
        }
    }

    private func handleForgotPassword() {
        guard email.contains("@") else {
            ToastManager.shared.warning(
                "E-posta Gerekli",
                message: "Şifre sıfırlama için önce e-posta adresinizi girin."
            )
            focusedField = .email
            return
        }
        AlertManager.shared.show(AppAlertData(
            type: .info,
            title: "Şifre Sıfırlama",
            message: "\(email) adresine sıfırlama bağlantısı gönderilecek.",
            confirmLabel: "Gönder",
            cancelLabel: "İptal",
            onConfirm: {
                Task { await auth.sendPasswordReset(to: email) }
            }
        ))
    }

    private func triggerShake() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) { shakeOffset = 0 }
        }
    }
}

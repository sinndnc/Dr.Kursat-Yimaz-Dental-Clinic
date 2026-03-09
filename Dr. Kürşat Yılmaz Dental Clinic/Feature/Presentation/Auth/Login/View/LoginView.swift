//
//  LoginView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct LoginView: View {
    @Binding var showLogin: Bool
    @Injected var authService: AuthServiceProtocol

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showForgotPassword = false
    @FocusState private var focusedField: Field?
    
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    enum Field { case email, password }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.94, green: 0.97, blue: 1.0), Color.white],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Logo
                    logoSection
                        .padding(.top, 70)
                        .padding(.bottom, 48)
                    
                    // Form
                    VStack(spacing: 16) {
                        authField(
                            icon: "envelope.fill",
                            placeholder: "E-posta",
                            text: $email,
                            isSecure: false,
                            field: .email
                        )
                        
                        authField(
                            icon: "lock.fill",
                            placeholder: "Şifre",
                            text: $password,
                            isSecure: !showPassword,
                            field: .password,
                            trailingButton: AnyView(
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            )
                        )
                        
                        HStack {
                            Spacer()
                            Button("Şifremi Unuttum") { showForgotPassword = true }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(primaryBlue)
                        }
                        .padding(.top, -4)
                    }
                    .padding(.horizontal, 28)
                    
                    // Error
                    if let error = authService.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(10)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .animation(.spring(), value: authService.errorMessage)
                    }
                    
                    // Login Button
                    Button(action: performLogin) {
                        ZStack {
                            if authService.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Giriş Yap")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(colors: [primaryBlue, Color(red: 0.05, green: 0.25, blue: 0.75)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: primaryBlue.opacity(0.4), radius: 12, y: 6)
                    }
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                    .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)
                    .padding(.horizontal, 28)
                    .padding(.top, 28)
                    
                    // Divider
                    HStack {
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                        Text("veya")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 24)
                    
                    // Register
                    Button(action: { withAnimation { showLogin = false } }) {
                        HStack(spacing: 4) {
                            Text("Hesabın yok mu?")
                                .foregroundColor(.secondary)
                            Text("Kayıt Ol")
                                .foregroundColor(primaryBlue)
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 15))
                    }
                    
                    Spacer().frame(height: 40)
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    func performLogin() {
        focusedField = nil
        Task {
//            try? await authService.login(email: email, password: password)
        }
    }
    
    var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [primaryBlue, Color(red: 0.05, green: 0.25, blue: 0.75)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 88, height: 88)
                    .shadow(color: primaryBlue.opacity(0.4), radius: 16, y: 8)
                
                Text("🦷")
                    .font(.system(size: 44))
            }
            
            VStack(spacing: 6) {
                Text("DentCare")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Diş Sağlığınız Bizimlé Güvende")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    func authField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool, field: Field, trailingButton: AnyView? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(primaryBlue)
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(field == .email ? .emailAddress : .default)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            .font(.system(size: 16))
            .focused($focusedField, equals: field)
            
            if let btn = trailingButton { btn }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(focusedField == field ? primaryBlue : Color.gray.opacity(0.15), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

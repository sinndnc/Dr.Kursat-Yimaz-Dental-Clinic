//
//  RegisterView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct RegisterView: View {
    @Binding var showLogin: Bool
    @Injected var authService: AuthServiceProtocol
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @FocusState private var focusedField: Field?
    
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    enum Field { case name, email, phone, password, confirm }
    
    var passwordsMatch: Bool { password == confirmPassword }
    var canRegister: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty &&
        password.count >= 6 && passwordsMatch && !authService.isLoading
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.94, green: 0.97, blue: 1.0), Color.white],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Hesap Oluştur")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        Text("Diş sağlığınızı takip etmeye başlayın")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 36)
                    
                    // Fields
                    VStack(spacing: 14) {
                        regField(icon: "person.fill", placeholder: "Ad Soyad", text: $name, field: .name)
                        regField(icon: "envelope.fill", placeholder: "E-posta", text: $email, field: .email, keyboardType: .emailAddress)
                        regField(icon: "phone.fill", placeholder: "Telefon (+90...)", text: $phone, field: .phone, keyboardType: .phonePad)
                        
                        regField(icon: "lock.fill", placeholder: "Şifre (min. 6 karakter)", text: $password, field: .password, isSecure: !showPassword, trailingButton: AnyView(
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye").foregroundColor(.secondary)
                            }
                        ))
                        
                        regField(icon: "lock.badge.checkmark.fill", placeholder: "Şifreyi Tekrarla", text: $confirmPassword, field: .confirm, isSecure: true)
                        
                        if !confirmPassword.isEmpty && !passwordsMatch {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.red).font(.system(size: 13))
                                Text("Şifreler eşleşmiyor").font(.system(size: 13)).foregroundColor(.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 28)
                    
                    // Error
                    if let error = authService.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                            Text(error).font(.system(size: 13)).foregroundColor(.red)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(10)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)
                    }
                    
                    // Register Button
                    Button(action: performRegister) {
                        ZStack {
                            if authService.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Kayıt Ol")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(
                            LinearGradient(colors: [primaryBlue, Color(red: 0.05, green: 0.25, blue: 0.75)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: primaryBlue.opacity(0.4), radius: 12, y: 6)
                    }
                    .disabled(!canRegister)
                    .opacity(canRegister ? 1 : 0.6)
                    .padding(.horizontal, 28)
                    .padding(.top, 24)
                    
                    Button(action: { withAnimation { showLogin = true } }) {
                        HStack(spacing: 4) {
                            Text("Zaten hesabın var mı?").foregroundColor(.secondary)
                            Text("Giriş Yap").foregroundColor(primaryBlue).fontWeight(.bold)
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.top, 20)
                    
                    Spacer().frame(height: 40)
                }
            }
        }
    }
    
    func performRegister() {
        focusedField = nil
        Task {
//            try? await authService.register(name: name, email: email, phone: phone, password: password)
        }
    }
    
    func regField(icon: String, placeholder: String, text: Binding<String>, field: Field,
                  keyboardType: UIKeyboardType = .default, isSecure: Bool = false, trailingButton: AnyView? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(primaryBlue).frame(width: 20)
            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboardType)
                        .autocapitalization(field == .name ? .words : .none)
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
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(focusedField == field ? primaryBlue : Color.gray.opacity(0.15), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

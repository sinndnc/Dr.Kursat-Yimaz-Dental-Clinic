//
//  ForgotPasswordView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Injected var authService: AuthServiceProtocol
    
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var sent = false
    
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 60))
                    .foregroundColor(primaryBlue)
                    .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text("Şifre Sıfırla")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Text(sent
                         ? "E-postanıza şifre sıfırlama bağlantısı gönderildi."
                         : "E-posta adresinizi girin, size sıfırlama bağlantısı gönderelim.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                if !sent {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill").foregroundColor(primaryBlue).frame(width: 20)
                        TextField("E-posta adresiniz", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.15), lineWidth: 1.5))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                    .padding(.horizontal, 28)
                    
                    Button(action: sendReset) {
                        Group {
                            if authService.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sıfırlama Bağlantısı Gönder")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(primaryBlue)
                        .cornerRadius(16)
                    }
                    .disabled(email.isEmpty || authService.isLoading)
                    .opacity(email.isEmpty ? 0.6 : 1)
                    .padding(.horizontal, 28)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Button("Tamam") { dismiss() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(primaryBlue)
                        .cornerRadius(16)
                        .padding(.horizontal, 28)
                }
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }
    
    func sendReset() {
        Task {
//            try? await authService.resetPassword(email: email)
//            await MainActor.run { sent = true }
        }
    }
}

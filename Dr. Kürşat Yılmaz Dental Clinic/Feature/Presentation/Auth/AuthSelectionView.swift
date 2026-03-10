//
//  AuthSelectionView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct AuthSelectionView: View {
    @State private var animateIn = false
    
    @Environment(AppNavigationState.self) private var appNav
    @State private var authPath = NavigationPath()
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.kyAccent.opacity(0.06), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 5) {
                    ZStack {
                        Image("ClinicLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 88, height: 88)
                    }
                    .scaleEffect(animateIn ? 1 : 0.7)
                    .opacity(animateIn ? 1 : 0)
                    
                    VStack(spacing: 6) {
                        Text("Clinic")
                            .font(.kySerif(38, weight: .semibold))
                            .foregroundColor(.kyText)
                        
                        Text("Sağlıklı gülüşünüze hoş geldiniz")
                            .font(.kySans(14))
                            .foregroundColor(.kySubtext)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 12)
                }
                
                Spacer()
                
                // Auth Options
                VStack(spacing: 12) {
                    NavigationLink{
                        SignUpView()
                    } label: {
                        SocialAuthButton(
                            icon: "apple.logo",
                            label: "Continue with Apple",
                            isSystemImage: true
                        )
                        
                    }
                    NavigationLink{
                        SignUpView()
                    } label: {
                        SocialAuthButton(
                            icon: "google_icon",
                            label: "Continue with Google",
                            isSystemImage: false,
                            useCustomIcon: true
                        )
                    }
                    
                    NavigationLink{
                        LoginView()
                    } label: {
                        SocialAuthButton(
                            icon: "envelope.fill",
                            label: "Continue with Email",
                            isSystemImage: true,
                            accent: true
                        )
                    }
                    
                    // Divider
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(Color.kyBorder)
                            .frame(height: 1)
                        Text("or")
                            .font(.kySans(12))
                            .foregroundColor(.kySubtext)
                        Rectangle()
                            .fill(Color.kyBorder)
                            .frame(height: 1)
                    }
                    .padding(.vertical, 4)
                    
                    NavigationLink{
                        SignUpView()
                    } label: {
                        Text("Create a new account")
                            .font(.kySans(15, weight: .medium))
                            .foregroundColor(.kyAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.kyAccent.opacity(0.08))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color.kyAccent.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
                
                // Footer
                Text("By continuing, you agree to our Terms & Privacy Policy")
                    .font(.kySans(11))
                    .foregroundColor(.kySubtext.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 36)
                    .opacity(animateIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) {
                animateIn = true
            }
        }
    }
    
}

// MARK: - Social Auth Button
struct SocialAuthButton: View {
    let icon: String
    let label: String
    var isSystemImage: Bool = true
    var useCustomIcon: Bool = false
    var accent: Bool = false

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if isSystemImage {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                } else {
                    // Google icon fallback using text
                    Text("G")
                        .font(.kySerif(18, weight: .semibold))
                }
            }
            .foregroundColor(accent ? Color.kyBackground : .kyText)
            .frame(width: 24)
            
            Text(label)
                .font(.kySans(15, weight: .medium))
                .foregroundColor(accent ? Color.kyBackground : .kyText)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            accent
            ? Color.kyAccent
            : Color.kySurface
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    accent ? Color.clear : Color.kyBorder,
                    lineWidth: 1
                )
        )
        .scaleEffect(isPressed ? 0.97 : 1)
    }
}

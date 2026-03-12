//
//  RegisterView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirm = false
    @State private var agreedToTerms = false
    @State private var isLoading = false
    @State private var animateIn = false
    @State private var currentStep = 0   // 0 = personal, 1 = security
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password, confirm }

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            // Ambient glow
            Circle()
                .fill(Color.kyPurple.opacity(0.04))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(x: -100, y: 200)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                StepProgressBar(currentStep: currentStep, totalSteps: 2)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                    .opacity(animateIn ? 1 : 0)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(currentStep == 0 ? "Create Account" : "Secure It")
                                .font(.kySerif(34, weight: .semibold))
                                .foregroundColor(.kyText)
                                .animation(.none, value: currentStep)

                            Text(currentStep == 0
                                 ? "Tell us a bit about yourself."
                                 : "Choose a strong password.")
                                .font(.kySans(15))
                                .foregroundColor(.kySubtext)
                                .animation(.none, value: currentStep)
                        }
                        .padding(.bottom, 36)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 14)

                        // Step 0: Personal Info
                        if currentStep == 0 {
                            VStack(spacing: 16) {
                                KyTextField(
                                    label: "Full Name",
                                    placeholder: "Jane Doe",
                                    text: $fullName,
                                    icon: "person",
                                    isFocused: focusedField == .name
                                )
                                .focused($focusedField, equals: .name)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .email }

                                KyTextField(
                                    label: "Email Address",
                                    placeholder: "you@example.com",
                                    text: $email,
                                    icon: "envelope",
                                    keyboardType: .emailAddress,
                                    isFocused: focusedField == .email
                                )
                                .focused($focusedField, equals: .email)
                                .submitLabel(.done)
                                .onSubmit { focusedField = nil }
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }

                        // Step 1: Security
                        if currentStep == 1 {
                            VStack(spacing: 16) {
                                KySecureField(
                                    label: "Password",
                                    placeholder: "Min. 8 characters",
                                    text: $password,
                                    showPassword: $showPassword,
                                    isFocused: focusedField == .password
                                )
                                .focused($focusedField, equals: .password)

                                KySecureField(
                                    label: "Confirm Password",
                                    placeholder: "Repeat password",
                                    text: $confirmPassword,
                                    showPassword: $showConfirm,
                                    isFocused: focusedField == .confirm
                                )
                                .focused($focusedField, equals: .confirm)

                                // Password strength indicator
                                if !password.isEmpty {
                                    PasswordStrengthView(password: password)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }

                                // Terms
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        agreedToTerms.toggle()
                                    }
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(agreedToTerms ? Color.kyAccent : Color.kyCard)
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .strokeBorder(
                                                            agreedToTerms ? Color.clear : Color.kyBorder,
                                                            lineWidth: 1
                                                        )
                                                )

                                            if agreedToTerms {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.kyBackground)
                                            }
                                        }

                                        Text("I agree to the **Terms of Service** and **Privacy Policy**")
                                            .font(.kySans(13))
                                            .foregroundColor(.kySubtext)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }

                        Spacer().frame(height: 36)

                        // Action Button
                        Button(action: handleAction) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(Color.kyBackground)
                                } else {
                                    HStack(spacing: 8) {
                                        Text(currentStep == 0 ? "Continue" : "Create Account")
                                            .font(.kySans(16, weight: .semibold))
                                        Image(systemName: currentStep == 0 ? "arrow.right" : "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
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
                        .disabled(isLoading || !isStepValid)
                        .opacity(isStepValid ? 1 : 0.45)
                        .opacity(animateIn ? 1 : 0)

                        // Back to step 0 (only on step 1)
                        if currentStep == 1 {
                            Button {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    currentStep = 0
                                }
                            } label: {
                                Text("Back")
                                    .font(.kySans(14))
                                    .foregroundColor(.kySubtext)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 14)
                            }
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
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

    private var isStepValid: Bool {
        if currentStep == 0 {
            return fullName.count >= 2 && email.contains("@")
        } else {
            return password.count >= 8 && password == confirmPassword && agreedToTerms
        }
    }

    private func handleAction() {
        if currentStep == 0 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                currentStep = 1
            }
        } else {
            focusedField = nil
            withAnimation { isLoading = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { isLoading = false }
            }
        }
    }
}

// MARK: - Step Progress Bar
struct StepProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.kyAccent : Color.kySurface)
                    .frame(height: 3)
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.kyBorderSubtle, lineWidth: 1)
                    )
                    .animation(.spring(response: 0.4), value: currentStep)
            }
        }
    }
}

// MARK: - Password Strength View
struct PasswordStrengthView: View {
    let password: String
    
    private var strength: (level: Int, label: String, color: Color) {
        let len = password.count
        let hasUpper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNum = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil
        
        let score = (len >= 8 ? 1 : 0) + (len >= 12 ? 1 : 0) + (hasUpper ? 1 : 0) + (hasNum ? 1 : 0) + (hasSpecial ? 1 : 0)
        
        switch score {
        case 0...1: return (1, "Weak", .kyDanger)
        case 2...3: return (2, "Fair", .kyOrange)
        case 4:     return (3, "Good", .kyBlue)
        default:    return (4, "Strong", .kyGreen)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                ForEach(1...4, id: \.self) { i in
                    Capsule()
                        .fill(i <= strength.level ? strength.color : Color.kySurface)
                        .frame(height: 3)
                        .animation(.spring(response: 0.3), value: strength.level)
                }
            }
            
            Text("Password strength: \(strength.label)")
                .font(.kySans(11))
                .foregroundColor(strength.color)
        }
        .padding(.top, 4)
    }
}

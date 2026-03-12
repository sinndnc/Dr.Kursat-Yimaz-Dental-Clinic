//
//  RegisterView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI
import WebKit

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
    @State private var currentStep = 0
    @FocusState private var focusedField: Field?

    // KVKK Sheet
    @State private var activeConsentSheet: ConsentSheetType? = nil

    enum Field { case name, email, password, confirm }
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            Circle()
                .fill(Color.kyPurple.opacity(0.04))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(x: -100, y: 200)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                StepProgressBar(currentStep: currentStep, totalSteps: 2)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                    .opacity(animateIn ? 1 : 0)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
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
                                
                                if !password.isEmpty {
                                    PasswordStrengthView(password: password)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                                
                                // ── Terms Checkbox ──────────────────────────────
                                Button {
                                    if agreedToTerms {
                                        // Zaten onaylıysa geri al
                                        withAnimation(.spring(response: 0.3)) {
                                            agreedToTerms = false
                                        }
                                    } else {
                                        // Önce Terms of Service sayfasını aç
                                        activeConsentSheet = .terms
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
                                // ────────────────────────────────────────────────
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                        
                        Spacer().frame(height: 36)
                        
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
                Button { dismiss() } label: {
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
        // KVKK Sheet — Terms → Privacy Policy → KVKK sırasıyla açılır,
        // son sayfada "Okudum, Onaylıyorum" denince agreedToTerms = true olur
        .sheet(item: $activeConsentSheet) { sheetType in
            ConsentDocumentSheet(type: sheetType) { nextSheet in
                activeConsentSheet = nextSheet   // nil ise sheet kapanır, checkmark işaretlenir
                if nextSheet == nil {
                    withAnimation(.spring(response: 0.3)) {
                        agreedToTerms = true
                    }
                }
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

// MARK: - Consent Sheet Türleri
enum ConsentSheetType: String, Identifiable {
    case terms   = "Terms of Service"
    case privacy = "Privacy Policy"
    case kvkk    = "KVKK Aydınlatma Metni"
    
    var id: String { rawValue }
    
    var url: URL {
        switch self {
        case .terms:   return URL(string: "https://indigo-egret-2c6.notion.site/Terms-of-Use-32101f2ea246801fa1f6e03d33130420?pvs=73")!
        case .privacy: return URL(string: "https://indigo-egret-2c6.notion.site/Privacy-Policy-32101f2ea2468070a5d2eb6284a292ae")!
        case .kvkk:    return URL(string: "https://indigo-egret-2c6.notion.site/KVKK-Disclosure-Statement-32101f2ea24680839a2ddf82dcdce6c0?pvs=73")!
        }
    }
    
    /// Onaylandıktan sonra sıradaki sayfa (nil = akış bitti)
    var next: ConsentSheetType? {
        switch self {
        case .terms:   return .privacy
        case .privacy: return .kvkk
        case .kvkk:    return nil
        }
    }
    
    var buttonLabel: String {
        switch self {
        case .terms:   return "I've Read — Continue to Privacy Policy"
        case .privacy: return "I've Read — Continue to KVKK"
        case .kvkk:    return "I Agree to All — Done"
        }
    }
}

// MARK: - Belge Sheet
struct ConsentDocumentSheet: View {
    let type: ConsentSheetType
    /// next = nil ise akış tamamlandı, sheet kapanacak
    var onApproved: (ConsentSheetType?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var scrolledToBottom = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Adım göstergesi
                HStack(spacing: 6) {
                    ForEach([ConsentSheetType.terms, .privacy, .kvkk], id: \.id) { step in
                        Capsule()
                            .fill(stepColor(step))
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                
                // Web içeriği
                WebViewWrapper(url: type.url) {
                    scrolledToBottom = true
                }
                
                Divider()
                
                // Alt onay alanı
                VStack(spacing: 10) {
                    if !scrolledToBottom {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 12))
                            Text("Scroll to the bottom to continue")
                                .font(.kySans(12))
                        }
                        .foregroundColor(.kySubtext)
                        .transition(.opacity)
                    }
                    
                    Button {
                        onApproved(type.next)
                    } label: {
                        Text(type.buttonLabel)
                            .font(.kySans(15, weight: .semibold))
                            .foregroundColor(.kyBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                scrolledToBottom
                                ? LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(14)
                    }
                    .disabled(!scrolledToBottom)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.kySans(13))
                            .foregroundColor(.kySubtext)
                            .underline()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.kyCard)
            }
            .navigationTitle(type.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.kySubtext)
                    }
                }
            }
        }
    }
    
    private func stepColor(_ step: ConsentSheetType) -> Color {
        let order: [ConsentSheetType] = [.terms, .privacy, .kvkk]
        guard let current = order.firstIndex(of: type),
              let target  = order.firstIndex(of: step) else { return Color.kySurface }
        return target <= current ? Color.kyAccent : Color.kySurface
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    var onScrolledToBottom: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScrolledToBottom: onScrolledToBottom)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // JS → Swift mesaj köprüsü
        config.userContentController.add(context.coordinator, name: "scrolledToBottom")
        
        let scrollJS = """
        window.addEventListener('scroll', function() {
            var scrolled = window.scrollY + window.innerHeight;
            var total    = document.documentElement.scrollHeight;
            if (scrolled >= total - 80) {
                window.webkit.messageHandlers.scrolledToBottom.postMessage('reached');
            }
        });
        if (document.documentElement.scrollHeight <= window.innerHeight + 80) {
            window.webkit.messageHandlers.scrolledToBottom.postMessage('reached');
        }
        """
        let script = WKUserScript(source: scrollJS,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var onScrolledToBottom: () -> Void
        private var didFire = false
        
        init(onScrolledToBottom: @escaping () -> Void) {
            self.onScrolledToBottom = onScrolledToBottom
        }
        
        func userContentController(_ controller: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard !didFire, message.name == "scrolledToBottom" else { return }
            didFire = true
            DispatchQueue.main.async { self.onScrolledToBottom() }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let recheck = """
            (function() {
                if (document.documentElement.scrollHeight <= window.innerHeight + 80) {
                    window.webkit.messageHandlers.scrolledToBottom.postMessage('reached');
                }
            })();
            """
            webView.evaluateJavaScript(recheck, completionHandler: nil)
        }
    }
}

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

struct PasswordStrengthView: View {
    let password: String
    
    private var strength: (level: Int, label: String, color: Color) {
        let len = password.count
        let hasUpper   = password.range(of: "[A-Z]",      options: .regularExpression) != nil
        let hasNum     = password.range(of: "[0-9]",      options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil
        
        let score = (len >= 8 ? 1 : 0) + (len >= 12 ? 1 : 0)
                  + (hasUpper ? 1 : 0) + (hasNum ? 1 : 0) + (hasSpecial ? 1 : 0)
        
        switch score {
        case 0...1: return (1, "Weak",   .kyDanger)
        case 2...3: return (2, "Fair",   .kyOrange)
        case 4:     return (3, "Good",   .kyBlue)
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

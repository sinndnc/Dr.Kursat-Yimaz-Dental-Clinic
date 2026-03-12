//
//  BookingWebView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//
import SwiftUI
import WebKit


struct BookingWebView: View {
    @Environment(\.dismiss) private var dismiss
    private let appointmentURL = "https://klinik.medicasimple.com/online-randevu/eyJpZCI6MTM4OCwicSI6Im1lZGljYXNpbXBsZV8yMiIsImRlZmF1bHRMYW5ndWFnZSI6InRyIn0%3D"
    
    @State private var isLoading = true
    @State private var loadingProgress: Double = 0
    @State private var pageTitle: String = "Appointment"
    @State private var canGoBack = false
    @State private var webViewRef: WKWebView?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // WebView
                WebViewRepresentable(
                    urlString: appointmentURL,
                    isLoading: $isLoading,
                    loadingProgress: $loadingProgress,
                    pageTitle: $pageTitle,
                    canGoBack: $canGoBack,
                    webViewRef: $webViewRef
                )
                .ignoresSafeArea(edges: .bottom)
                
                // Progress Bar
                if isLoading {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color(hex: "#1A73E8"))
                            .frame(width: geo.size.width * loadingProgress, height: 3)
                            .animation(.easeInOut(duration: 0.2), value: loadingProgress)
                    }
                    .frame(height: 3)
                }
            }
            .navigationTitle(pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 4) {
                        // Geri butonu
                        Button {
                            webViewRef?.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .disabled(!canGoBack)
                        .opacity(canGoBack ? 1 : 0.4)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A73E8"))
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - WKWebView Representable
struct WebViewRepresentable: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    @Binding var loadingProgress: Double
    @Binding var pageTitle: String
    @Binding var canGoBack: Bool
    @Binding var webViewRef: WKWebView?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // KVO observers
        webView.addObserver(context.coordinator, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(context.coordinator, forKeyPath: "canGoBack", options: .new, context: nil)
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
            webView.load(request)
        }
        
        DispatchQueue.main.async {
            self.webViewRef = webView
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let webView = object as? WKWebView else { return }
            DispatchQueue.main.async {
                if keyPath == "estimatedProgress" {
                    self.parent.loadingProgress = webView.estimatedProgress
                } else if keyPath == "title", let title = webView.title, !title.isEmpty {
                    self.parent.pageTitle = title
                } else if keyPath == "canGoBack" {
                    self.parent.canGoBack = webView.canGoBack
                }
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async { self.parent.isLoading = true }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadingProgress = 1.0
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }
    }
}

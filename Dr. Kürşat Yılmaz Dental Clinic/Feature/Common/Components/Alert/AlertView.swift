//
//  AppAlertType.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct AlertView: View {
    let data: AppAlertData
    let onDismiss: () -> Void
    
    @State private var appeared = false
    @State private var iconBounce = false
   
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            
            // Card
            VStack(spacing: 0) {
                
                // Icon + Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(data.type.accentColor.opacity(0.12))
                            .frame(width: 72, height: 72)
                        
                        Circle()
                            .stroke(data.type.accentColor.opacity(0.25), lineWidth: 1.5)
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: data.type.icon)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(data.type.accentColor)
                            .scaleEffect(iconBounce ? 1.18 : 1.0)
                    }
                    .padding(.top, 32)
                    .onAppear {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.45).delay(0.15)) {
                            iconBounce = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                iconBounce = false
                            }
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Text(data.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text(data.message)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
                
                // Divider
                Rectangle()
                    .fill(Color(.separator).opacity(0.5))
                    .frame(height: 0.5)
                
                // Buttons
                HStack(spacing: 0) {
                    // Cancel
                    Button {
                        dismiss()
                        data.onCancel?()
                    } label: {
                        Text(data.cancelLabel)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(AlertButtonStyle())
                    
                    // Vertical divider
                    Rectangle()
                        .fill(Color(.separator).opacity(0.5))
                        .frame(width: 0.5)
                    
                    // Confirm
                    Button {
                        dismiss()
                        data.onConfirm()
                    } label: {
                        Text(data.confirmLabel)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(data.type.accentColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(AlertButtonStyle())
                }
                .frame(height: 52)
            }
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 40)
            .scaleEffect(appeared ? 1 : 0.82)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                    appeared = true
                }
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onDismiss()
        }
    }
}



struct AlertDemoView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Destructive Onay") {
                    Button("Çıkış Yap") {
                        AlertManager.shared.confirmDestructive(
                            title: "Çıkış Yapmak İstediğinize Emin Misiniz?",
                            message: "Oturumunuz kapatılacak. Tekrar giriş yapmanız gerekecek.",
                            confirmLabel: "Evet, Çıkış Yap"
                        ) {
                            print("Kullanıcı çıkış yaptı")
                        }
                    }
                    .foregroundColor(.red)
                    
                    Button("Hesabı Sil") {
                        AlertManager.shared.confirmDestructive(
                            title: "Hesabı Kalıcı Olarak Sil",
                            message: "Bu işlem geri alınamaz. Tüm verileriniz silinecektir.",
                            confirmLabel: "Evet, Sil"
                        ) {
                            print("Hesap silindi")
                        }
                    }
                    .foregroundColor(.red)
                }
                
                Section("Diğer Tipler") {
                    Button("Başarı") {
                        AlertManager.shared.success(
                            title: "Kayıt Başarılı",
                            message: "Bilgileriniz başarıyla güncellendi."
                        )
                    }
                    Button("Hata") {
                        AlertManager.shared.error(
                            title: "Bağlantı Hatası",
                            message: "Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin."
                        )
                    }
                    Button("Uyarı") {
                        AlertManager.shared.warning(
                            title: "Değişiklikler Kaydedilmedi",
                            message: "Sayfadan çıkmak istediğinize emin misiniz?"
                        )
                    }
                    Button("Bilgi") {
                        AlertManager.shared.info(
                            title: "Güncelleme Mevcut",
                            message: "Yeni sürüm için App Store'a yönlendirileceksiniz."
                        )
                    }
                }
            }
            .navigationTitle("Alert Örnekleri")
        }
        .alertContainer()
    }
}

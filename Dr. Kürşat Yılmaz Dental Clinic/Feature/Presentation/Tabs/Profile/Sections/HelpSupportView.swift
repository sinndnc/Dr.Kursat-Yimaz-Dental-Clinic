//
//  HelpSupportView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct HelpSupportView: View {
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Yardım & Destek")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        KYCard {
                            VStack(spacing: 2) {
                                KYNavigationRow(icon: "phone.fill", title: "Kliniği Ara", subtitle: "+90 (232) 000 00 00", iconBg: .kyGreen) {}
                                KYDivider()
                                KYNavigationRow(icon: "message.fill", title: "WhatsApp", subtitle: "Hızlı mesaj gönder", iconBg: Color(red: 0.24, green: 0.72, blue: 0.44)) {}
                                KYDivider()
                                KYNavigationRow(icon: "envelope.fill", title: "E-posta", subtitle: "info@kyclinic.com", iconBg: .kyBlue) {}
                            }
                        }

                        KYCard {
                            VStack(spacing: 2) {
                                KYNavigationRow(icon: "questionmark.circle.fill", title: "Sık Sorulan Sorular", iconBg: .kyAccent) {}
                                KYDivider()
                                KYNavigationRow(icon: "bubble.left.and.exclamationmark.bubble.right.fill", title: "Geri Bildirim Gönder", iconBg: .kyPurple) {}
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


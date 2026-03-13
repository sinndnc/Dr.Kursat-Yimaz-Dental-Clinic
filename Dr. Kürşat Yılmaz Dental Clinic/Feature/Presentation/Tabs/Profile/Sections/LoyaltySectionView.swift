//
//  LoyaltyPointsView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct LoyaltySectionView: View {
    @State var patient: Patient
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Sadakat Puanları")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Points hero
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.kyAccent.opacity(0.12))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.kyAccent)
                            }
                            Text("\(patient.loyaltyPoints)")
                                .font(.kySerif(48, weight: .bold))
                                .foregroundColor(.kyText)
                            Text("Sadakat Puanı")
                                .font(.kyMono(13, weight: .semibold))
                                .tracking(1)
                                .foregroundColor(.kySubtext)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(28)
                        .background(Color.kyCard)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.kyAccent.opacity(0.25), lineWidth: 1)
                        )
                        
                        KYCard {
                            VStack(spacing: 12) {
                                Text("Puan Kazanma")
                                    .font(.kySans(15, weight: .bold))
                                    .foregroundColor(.kyText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(spacing: 8) {
                                    LoyaltyRow(icon: "calendar.badge.checkmark", text: "Her randevu: +50 puan", color: .kyBlue)
                                    LoyaltyRow(icon: "heart.text.square.fill", text: "Tedavi tamamlama: +200 puan", color: .kyGreen)
                                    LoyaltyRow(icon: "star.fill", text: "Değerlendirme bırakma: +30 puan", color: .kyAccent)
                                    LoyaltyRow(icon: "person.badge.plus.fill", text: "Arkadaş davet: +100 puan", color: .kyPurple)
                                }
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

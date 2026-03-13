//
//  EmergencyContactsView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct EmergencyContactsDetailView: View {
    @State var patient: Patient
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Acil Durum Kontakları")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        if(patient.emergencyContacts.isEmpty){
                            KYEmptyState(
                                icon: "person.crop.circle.badge.exclamationmark",
                                title: "Acil Kontakt Yok",
                                message: "Bu hastaya ait henüz\nbir acil durum kontağı eklenmemiş."
                            )
                        }else{
                            ForEach(patient.emergencyContacts) { contact in
                                KYCard {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.kyDanger.opacity(0.12))
                                                .frame(width: 48, height: 48)
                                            Text(String(contact.name.prefix(1)))
                                                .font(.kySerif(20, weight: .bold))
                                                .foregroundColor(.kyDanger)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(contact.name)
                                                .font(.kySans(16, weight: .semibold))
                                                .foregroundColor(.kyText)
                                            KYBadge(text: contact.relationship, color: .kySubtext)
                                            Label(contact.phone, systemImage: "phone.fill")
                                                .font(.kySans(13))
                                                .foregroundColor(.kySubtext)
                                        }
                                        Spacer()
                                        Button {
                                            // Call action
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.kyGreen.opacity(0.15))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: "phone.fill")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.kyGreen)
                                            }
                                        }
                                    }
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

//
//  AllergiesDetailView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct AllergiesDetailView: View {
    @State var patient: Patient
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Alerjiler")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if patient.allergies.isEmpty {
                            KYEmptyState(icon: "checkmark.shield.fill", title: "Alerji Yok", message: "Kayıtlı alerji bilginiz bulunmuyor.")
                        } else {
                            ForEach(patient.allergies) { allergy in
                                KYCard(glowColor: .gray) {
                                    VStack(spacing: 10) {
                                        HStack {
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .frame(width: 10, height: 10)
                                                Text(allergy.name)
                                                    .font(.kySans(16, weight: .bold))
                                                    .foregroundColor(.kyText)
                                            }
                                            Spacer()
                                            KYBadge(
                                                text: allergy.severity.rawValue,
                                                color: .gray
                                            )
                                        }
                                        if let notes = allergy.notes {
                                            Text(notes)
                                                .font(.kySans(13))
                                                .foregroundColor(.kySubtext)
                                                .frame(maxWidth: .infinity, alignment: .leading)
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


struct MedicationsDetailView: View {
    @State var patient: Patient
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Düzenli İlaçlar")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(patient.medications) { med in
                            KYCard {
                                VStack(spacing: 10) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.kyBlue.opacity(0.12))
                                                .frame(width: 42, height: 42)
                                            Image(systemName: "pills.fill")
                                                .font(.system(size: 17))
                                                .foregroundColor(.kyBlue)
                                        }
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(med.name)
                                                .font(.kySans(15, weight: .semibold))
                                                .foregroundColor(.kyText)
                                            Text("\(med.dosage) · \(med.frequency)")
                                                .font(.kySans(13))
                                                .foregroundColor(.kySubtext)
                                        }
                                        Spacer()
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


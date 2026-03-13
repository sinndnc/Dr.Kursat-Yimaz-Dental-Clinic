//
//  MedicationsDetailView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct MedicationsDetailView: View {
    @State var patient: Patient
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Düzenli İlaçlar")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        if(patient.medications.isEmpty){
                            KYEmptyState(
                                icon: "pills",
                                title: "İlaç Kaydı Yok",
                                message: "Bu hastaya ait henüz\nbir düzenli ilaç kaydı bulunmuyor."
                            )
                        }else{
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

struct NoMedicationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.kyBlue.opacity(0.10))
                    .frame(width: 72, height: 72)
                Image(systemName: "pills")
                    .font(.system(size: 28))
                    .foregroundColor(.kyBlue.opacity(0.6))
            }
            Text("İlaç Kaydı Yok")
                .font(.kySans(17, weight: .semibold))
                .foregroundColor(.kyText)
            Text("Bu hastaya ait henüz\nbir düzenli ilaç kaydı bulunmuyor.")
                .font(.kySans(14))
                .foregroundColor(.kySubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }
}

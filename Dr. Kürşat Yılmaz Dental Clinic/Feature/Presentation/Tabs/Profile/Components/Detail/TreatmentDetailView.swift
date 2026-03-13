//
//  TreatmentDetailView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct TreatmentDetailView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    let treatmentId: String
    
    var treatment: ToothTreatment? {
        vm.treatments.first { $0.id.uuidString == treatmentId }
    }
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Tedavi Detayı")
                if let t = treatment {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            KYCard(glowColor: .gray) {
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(t.treatmentName)
                                                .font(.kySerif(22, weight: .bold))
                                                .foregroundColor(.kyText)
                                            if let tooth = t.toothNumber {
                                                KYBadge(text: "Diş Numarası: \(tooth)", color: .kyBlue, icon: "number")
                                            }
                                        }
                                        Spacer()
                                        KYBadge(
                                            text: t.status.rawValue,
                                            color: .gray
                                        )
                                    }
                                    
                                    if t.totalSessions > 0 {
                                        VStack(spacing: 8) {
                                            HStack {
                                                Text("Tedavi İlerlemesi")
                                                    .font(.kySans(13))
                                                    .foregroundColor(.kySubtext)
                                                Spacer()
                                                Text("\(t.completedSessions) / \(t.totalSessions) Seans")
                                                    .font(.kyMono(13, weight: .bold))
                                                    .foregroundColor(.gray)
                                            }
                                            KYProgressBar(progress: t.progressPercentage, color: .gray, height: 8, showLabel: false)
                                            
                                            // Session dots
                                            HStack(spacing: 6) {
                                                ForEach(0..<t.totalSessions, id: \.self) { i in
                                                    Circle()
                                                        .fill(i < t.completedSessions ? .gray : .gray.opacity(0.2))
                                                        .frame(width: 10, height: 10)
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Info card
                            KYCard {
                                VStack(spacing: 14) {
                                    KYDetailRow(icon: "person.fill", label: "Doktor", value: t.doctorName, iconColor: .kyAccent)
                                    KYDivider()
                                    KYDetailRow(icon: "calendar", label: "Başlangıç", value: t.startDate.kyFormatted, iconColor: .kyBlue)
                                    if let end = t.estimatedEndDate {
                                        KYDivider()
                                        KYDetailRow(icon: "calendar.badge.checkmark", label: "Tahmini Bitiş", value: end.kyFormatted, iconColor: .kyGreen)
                                    }
                                    KYDivider()
                                    KYDetailRow(icon: "turkishlirasign.circle.fill", label: "Toplam Ücret", value: t.cost.formatted_TRY, iconColor: .kyOrange)
                                    if let notes = t.notes {
                                        KYDivider()
                                        KYDetailRow(icon: "note.text", label: "Not", value: notes, iconColor: .kySubtext)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct NoTreatmentsView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.kyBlue.opacity(0.10))
                    .frame(width: 72, height: 72)
                Image(systemName: "cross.case")
                    .font(.system(size: 28))
                    .foregroundColor(.kyBlue.opacity(0.6))
            }
            Text("Tedavi Kaydı Yok")
                .font(.kySans(17, weight: .semibold))
                .foregroundColor(.kyText)
            Text("Bu hastaya ait henüz\nbir tedavi kaydı bulunmuyor.")
                .font(.kySans(14))
                .foregroundColor(.kySubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }
}

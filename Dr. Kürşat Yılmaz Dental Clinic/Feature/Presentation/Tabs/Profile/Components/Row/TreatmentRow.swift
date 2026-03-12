//
//  TreatmentRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct TreatmentRow: View {
    let treatment: ToothTreatment
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.gray.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: treatmentIcon(for: treatment.treatmentName))
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(treatment.treatmentName)
                                .font(.kySans(15, weight: .semibold))
                                .foregroundColor(.kyText)
                            if let tooth = treatment.toothNumber {
                                KYBadge(text: "Diş #\(tooth)", color: .kySubtext)
                            }
                        }
                        Text(treatment.doctorName)
                            .font(.kySans(12))
                            .foregroundColor(.kySubtext)
                    }
                    
                    Spacer()
                    
                    KYBadge(text: treatment.status.rawValue, color: .gray)
                }
                
                if treatment.status == .active || treatment.status == .planned {
                    VStack(spacing: 6) {
                        HStack {
                            Text("\(treatment.completedSessions)/\(treatment.totalSessions) seans tamamlandı")
                                .font(.kySans(12))
                                .foregroundColor(.kySubtext)
                            Spacer()
                            Text("\(Int(treatment.progressPercentage * 100))%")
                                .font(.kyMono(11, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        KYProgressBar(progress: treatment.progressPercentage, color: .gray, height: 5)
                    }
                }
            }
            .padding(14)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    func treatmentIcon(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("implant") { return "bolt.circle.fill" }
        if n.contains("kanal") { return "arrow.triangle.branch" }
        if n.contains("beyazlatma") { return "sparkles" }
        if n.contains("zirkonyum") || n.contains("kron") { return "crown.fill" }
        if n.contains("dolgu") { return "square.fill.on.square.fill" }
        if n.contains("temizlik") { return "drop.fill" }
        return "cross.case.fill"
    }
}

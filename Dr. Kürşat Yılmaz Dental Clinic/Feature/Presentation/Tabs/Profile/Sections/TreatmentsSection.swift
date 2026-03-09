//
//  TreatmentsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
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

// MARK: - Treatment List View

struct TreatmentListView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var navState: ProfileNavigationState

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Tedavilerim", subtitle: "\(vm.treatments.count) toplam")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(vm.treatments) { treatment in
                            TreatmentRow(treatment: treatment) {
                                navState.navigate(to: .treatmentDetail(id: treatment.id.uuidString))
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

// MARK: - Treatment Detail View

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
                            // Header card with progress
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

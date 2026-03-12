//
//  HealthInfoSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI

struct HealthInfoSection: View {
    @Binding var patient: Patient
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var navState: ProfileNavigationState

    var body: some View {
        VStack(spacing: 20) {
            KYSectionHeader(title: "Sağlık Bilgilerim") {
                navState.navigate(to: .healthInfo)
            }
            
            // Quick health summary
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                HealthInfoStat(
                    icon: "drop.fill",
                    label: "Kan Grubu",
                    value: patient.bloodType?.rawValue ?? "—",
                    color: .kyDanger
                )
                HealthInfoStat(
                    icon: "person.fill",
                    label: "Cinsiyet",
                    value: patient.gender.rawValue,
                    color: .kyPurple
                )
                HealthInfoStat(
                    icon: "birthday.cake.fill",
                    label: "Yaş",
                    value: "\(patient.age)",
                    color: .kyAccent
                )
                HealthInfoStat(
                    icon: "waveform.path.ecg",
                    label: "Diş Hassasiyeti",
                    value: sensitivityLabel(1),
                    color: .kyOrange
                )
            }
            .padding(.horizontal, 20)
            
            Button {
                navState.navigate(to: .allergiesDetail)
            } label: {
                KYCard(glowColor: patient.allergies.isEmpty ? nil : .kyDanger) {
                    VStack(spacing: 12) {
                        HStack {
                            Label("Alerjiler", systemImage: "exclamationmark.triangle.fill")
                                .font(.kySans(14, weight: .bold))
                                .foregroundColor(.kyDanger)
                            Spacer()
                            KYBadge(text: "\(patient.allergies.count) alerji", color: .kyDanger)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.kySubtext.opacity(0.4))
                        }

                        if !patient.allergies.isEmpty {
                            VStack(spacing: 6) {
                                ForEach(patient.allergies) { allergy in
                                    HStack {
                                        Circle()
                                            .frame(width: 7, height: 7)
                                        Text(allergy.name)
                                            .font(.kySans(13))
                                            .foregroundColor(.kyText)
                                        Spacer()
                                        Text(allergy.severity.rawValue)
                                            .font(.kyMono(10))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            // Medications card
            Button {
                navState.navigate(to: .medicationsDetail)
            } label: {
                KYCard(glowColor: patient.medications.isEmpty ? nil : .kyBlue) {
                    VStack(spacing: 12) {
                        HStack {
                            Label("Düzenli İlaçlar", systemImage: "pills.fill")
                                .font(.kySans(14, weight: .bold))
                                .foregroundColor(.kyBlue)
                            Spacer()
                            KYBadge(text: "\(patient.medications.count) ilaç", color: .kyBlue)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.kySubtext.opacity(0.4))
                        }

                        if !patient.medications.isEmpty {
                            VStack(spacing: 6) {
                                ForEach(patient.medications.prefix(3)) { med in
                                    HStack {
                                        Text(med.name)
                                            .font(.kySans(13))
                                            .foregroundColor(.kyText)
                                        Spacer()
                                        Text(med.frequency)
                                            .font(.kyMono(11))
                                            .foregroundColor(.kySubtext)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            // Other health info
            KYCard {
                VStack(spacing: 14) {
                    KYDetailRow(
                        icon: "smoke.fill",
                        label: "Sigara",
                        value: patient.smokingStatus.rawValue,
                        iconColor: .kySubtext
                    )
                    KYDivider()
                    KYDetailRow(
                        icon: "wineglass.fill",
                        label: "Alkol",
                        value: patient.alcoholStatus.rawValue,
                        iconColor: .kySubtext
                    )
                    if let pregnant = patient.isPregnant {
                        KYDivider()
                        KYDetailRow(
                            icon: "figure.and.child.holdinghands",
                            label: "Hamilelik",
                            value: pregnant ? "Evet" : "Hayır",
                            iconColor: .kySubtext
                        )
                    }
                    if let tetanus = patient.lastTetanusDate {
                        KYDivider()
                        KYDetailRow(
                            icon: "syringe.fill",
                            label: "Son Tetanoz",
                            value: tetanus.kyFormatted,
                            iconColor: .kySubtext
                        )
                    }
                }
            }
            .padding(.horizontal, 20)

            // Chronic diseases
            if !patient.chronicDiseases.isEmpty {
                KYCard(glowColor: .kyOrange) {
                    VStack(spacing: 12) {
                        HStack {
                            Label("Kronik Hastalıklar", systemImage: "heart.text.square.fill")
                                .font(.kySans(14, weight: .bold))
                                .foregroundColor(.kyOrange)
                            Spacer()
                        }
                        VStack(spacing: 8) {
                            ForEach(patient.chronicDiseases) { disease in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(disease.name)
                                            .font(.kySans(14, weight: .semibold))
                                            .foregroundColor(.kyText)
                                        if let year = disease.diagnosedYear {
                                            Text("Teşhis: \(year)")
                                                .font(.kySans(12))
                                                .foregroundColor(.kySubtext)
                                        }
                                    }
                                    Spacer()
                                    if let notes = disease.notes {
                                        Text(notes)
                                            .font(.kySans(11))
                                            .foregroundColor(.kySubtext)
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Emergency contacts
            Button {
                navState.navigate(to: .emergencyContacts)
            } label: {
                KYCard {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.kyDanger.opacity(0.12))
                                .frame(width: 40, height: 40)
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.kyDanger)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Acil Durum Kontakları")
                                .font(.kySans(14, weight: .semibold))
                                .foregroundColor(.kyText)
                            Text("\(patient.emergencyContacts.count) kişi ekli")
                                .font(.kySans(12))
                                .foregroundColor(.kySubtext)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.kySubtext.opacity(0.4))
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }

    func sensitivityLabel(_ level: Int) -> String {
        switch level {
        case 1: return "Çok Az"
        case 2: return "Az"
        case 3: return "Orta"
        case 4: return "Fazla"
        case 5: return "Çok Fazla"
        default: return "Orta"
        }
    }
}

struct HealthInfoDetailView: View {
    @State var patient: Patient
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var navState: ProfileNavigationState
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Sağlık Bilgilerim")
                ScrollView(showsIndicators: false) {
                    HealthInfoSection(patient: $patient)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


struct EmergencyContactsView: View {
    @State var patient: Patient
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Acil Durum Kontakları")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
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
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

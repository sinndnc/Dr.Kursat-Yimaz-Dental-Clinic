//
//  EditProfileView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct ProfileSectionView: View {
    @State var patient: Patient
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    
    @EnvironmentObject private var authVm: AuthViewModel
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Profili Düzenle")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Avatar
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color.kyAccent, Color.kyAccentDark],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 90, height: 90)
                                Text(patient.avatarLetter)
                                    .font(.kySerif(34, weight: .bold))
                                    .foregroundColor(.kyBackground)
                            }
                            Button {
                                // Change photo
                            } label: {
                                KYBadge(text: "Fotoğrafı Değiştir", color: .kyAccent, icon: "camera.fill")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Form fields
                        KYCard {
                            VStack(spacing: 16) {
                                ProfileTextField(label: "Ad", placeholder: patient.firstName, text: $firstName, icon: "person.fill")
                                KYDivider()
                                ProfileTextField(label: "Soyad", placeholder: patient.lastName, text: $lastName, icon: "person.fill")
                                KYDivider()
                                ProfileTextField(label: "Telefon", placeholder: patient.phone ?? "", text: $phone, icon: "phone.fill")
                                KYDivider()
                                ProfileTextField(label: "E-posta", placeholder: patient.email ?? "", text: $email, icon: "envelope.fill")
                            }
                        }
                        
                        KYCard {
                            VStack(spacing: 14) {
                                KYDetailRow(icon: "number", label: "TC Kimlik No", value: patient.tcKimlikNo ?? "", iconColor: .kySubtext)
                                KYDivider()
                                KYDetailRow(icon: "calendar", label: "Doğum Tarihi", value: patient.birthDate.kyFormatted, iconColor: .kySubtext)
                                KYDivider()
                                KYDetailRow(icon: "person.2.fill", label: "Cinsiyet", value: patient.gender.rawValue, iconColor: .kySubtext)
                            }
                        }
                        
                        ActionButton(title: "Değişiklikleri Kaydet", icon: "checkmark.circle.fill", color: .kyAccent, style: .filled) {
                            authVm.updatePatient(patientId: patient.id!,firstName: firstName,lastName: lastName,phone: phone,email: email)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            firstName = patient.firstName
            lastName = patient.lastName
            phone = patient.phone ?? ""
            email = patient.email ?? ""
        }
        .navigationBarHidden(true)
    }
}

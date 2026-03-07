//
//  EditProfileSheet.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct EditProfileSheet: View {
    @Binding var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var name:  String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var birth: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            Circle().fill(Color.kyAccent).frame(width: 5, height: 5)
                            Text("PROFİL DÜZENLE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .tracking(3).foregroundColor(Color.kyAccent)
                        }
                        Text("Bilgilerini Güncelle")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color.kyText)
                    }
                    .padding(.top, 8)

                    // Avatar editor
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.kyAccent, Color.kyAccentDark],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 72, height: 72)
                            Text(user.avatarInitials)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.kyBackground)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Profil Fotoğrafı")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.kyText)
                            Button {} label: {
                                Text("Fotoğraf Değiştir")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color.kyAccent)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.kyCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.kyBorder, lineWidth: 1))

                    // Fields
                    VStack(spacing: 14) {
                        EditField(label: "AD SOYAD",      placeholder: user.fullName, icon: "person.fill",    color: Color.kyAccent,                             text: $name)
                        EditField(label: "E-POSTA",       placeholder: user.email,    icon: "envelope.fill",  color: Color(red: 0.30, green: 0.60, blue: 0.90),  text: $email)
                        EditField(label: "TELEFON",       placeholder: user.phone,    icon: "phone.fill",     color: Color(red: 0.38, green: 0.78, blue: 0.50),  text: $phone)
                        EditField(label: "DOĞUM TARİHİ", placeholder: user.birthDate, icon: "calendar",      color: Color(red: 0.55, green: 0.45, blue: 0.85),  text: $birth)
                    }

                    // Save
                    Button {
                        if !name.isEmpty  { user.fullName = name }
                        if !email.isEmpty { user.email = email }
                        if !phone.isEmpty { user.phone = phone }
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Kaydet")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                        }
                        .foregroundColor(Color.kyBackground)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.kyAccent.opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.bottom, 48)
                }
                .padding(.horizontal, 24)
            }
            
            // Dismiss
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.kySubtext)
                        .padding(10)
                        .background(Color.kySurface)
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

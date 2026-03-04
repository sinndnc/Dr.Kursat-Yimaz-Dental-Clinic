//
//  EditProfileView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var isSaving = false
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        NavigationView {
            Form {
                Section("Kişisel Bilgiler") {
                    LabeledContent {
                        TextField("Ad Soyad", text: $name).multilineTextAlignment(.trailing)
                    } label: { Label("Ad Soyad", systemImage: "person") }
                    
                    LabeledContent {
                        TextField("Telefon", text: $phone).multilineTextAlignment(.trailing).keyboardType(.phonePad)
                    } label: { Label("Telefon", systemImage: "phone") }
                    
                    LabeledContent {
                        Text(appState.currentUser.email).foregroundColor(.secondary)
                    } label: { Label("E-posta", systemImage: "envelope") }
                }
                
                Section {
                    Button(action: saveProfile) {
                        Group {
                            if isSaving { ProgressView().tint(.white) }
                            else { Text("Kaydet").font(.system(size: 16, weight: .semibold)).foregroundColor(.white) }
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 4)
                    }
                    .listRowBackground(primaryBlue)
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Profili Düzenle").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("İptal") { dismiss() } } }
        }
        .onAppear {
            name = appState.currentUser.name
            phone = appState.currentUser.phone
        }
    }
    
    func saveProfile() {
        isSaving = true
        Task {
            await appState.updateProfile(name: name, phone: phone)
            await MainActor.run { isSaving = false; dismiss() }
        }
    }
}



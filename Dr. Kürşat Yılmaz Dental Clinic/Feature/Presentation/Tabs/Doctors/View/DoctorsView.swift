//
//  DoctorsView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct DoctorsView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedSpecialty = "Tümü"
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var displayDoctors: [Doctor] { appState.doctors.isEmpty ? Doctor.sampleData : appState.doctors }
    var specialties: [String] { ["Tümü"] + Array(Set(displayDoctors.map(\.specialty))).sorted() }
    
    var filteredDoctors: [Doctor] {
        displayDoctors.filter {
            (selectedSpecialty == "Tümü" || $0.specialty == selectedSpecialty) &&
            (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Doktor ara...", text: $searchText).font(.system(size: 15))
                }
                .padding(14).background(Color.white).cornerRadius(14)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                .padding(.horizontal, 20).padding(.top, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(specialties, id: \.self) { spec in
                            Button(action: { withAnimation(.spring(response: 0.3)) { selectedSpecialty = spec } }) {
                                Text(spec).font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selectedSpecialty == spec ? .white : .primary)
                                    .padding(.horizontal, 16).padding(.vertical, 8)
                                    .background(selectedSpecialty == spec ? primaryBlue : Color.white)
                                    .cornerRadius(20).shadow(color: .black.opacity(0.05), radius: 4, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 20).padding(.vertical, 14)
                }
                
                if appState.isLoadingData {
                    Spacer(); ProgressView("Doktorlar yükleniyor..."); Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(filteredDoctors) { doctor in
                                NavigationLink(destination: DoctorDetailView(doctor: doctor)) {
                                    DoctorListCard(doctor: doctor)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 100)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Doktorlar").navigationBarTitleDisplayMode(.large)
        }
    }
}

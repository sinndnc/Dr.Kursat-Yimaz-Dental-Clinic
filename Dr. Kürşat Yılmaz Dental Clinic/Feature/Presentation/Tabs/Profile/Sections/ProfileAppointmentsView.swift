//
//  AppointmentsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI

struct AppointmentListView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var navState: ProfileNavigationState
    @State private var filter: AppointmentFilter = .all
    
    var filteredAppointments: [Appointment] {
        switch filter {
        case .all: return vm.appointments.sorted { $0.date > $1.date }
        case .upcoming: return vm.upcomingAppointments
        case .completed: return vm.completedAppointments
        }
    }
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                KYDetailHeader(title: "Randevularım", subtitle: "\(vm.appointments.count) toplam")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AppointmentFilter.allCases, id: \.self) { f in
                            FilterChip(label: f.rawValue, isSelected: filter == f) {
                                withAnimation(.default) {
                                    filter = f
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(filteredAppointments) { apt in
                            AppointmentRow(appointment: apt)
                                .onTapGesture {
                                    navState.navigate(to: .appointmentDetail(appointment: apt))
                                }
                        }
                        if filteredAppointments.isEmpty {
                            KYEmptyState(
                                icon: "calendar.badge.clock",
                                title: "Randevu Yok",
                                message: "Bu kategoride randevunuz bulunmuyor."
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


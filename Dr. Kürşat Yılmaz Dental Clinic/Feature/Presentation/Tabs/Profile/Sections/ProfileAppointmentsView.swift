//
//  AppointmentsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI

struct AppointmentListView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var apptvm: AppointmentViewModel
    @EnvironmentObject private var navState: ProfileNavigationState
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                KYDetailHeader(title: "Randevularım", subtitle: "\(vm.appointments.count) toplam")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AppointmentFilter.allCases, id: \.self) { f in
                            FilterChip(
                                label: f.rawValue,
                                isSelected: apptvm.selectedFilter == f
                            ) {
                                withAnimation(.default) {
                                    apptvm.selectedFilter = f
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(apptvm.filteredAppointments) { apt in
                            AppointmentCard(appointment: apt)
                                .onTapGesture {
                                    navState.navigate(to: .appointmentDetail(appointment: apt))
                                }
                        }
                        if apptvm.filteredAppointments.isEmpty {
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


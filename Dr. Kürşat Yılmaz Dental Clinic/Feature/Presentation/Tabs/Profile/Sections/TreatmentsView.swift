//
//  TreatmentsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//
import SwiftUI

struct TreatmentsView: View {
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


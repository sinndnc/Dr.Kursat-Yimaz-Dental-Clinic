//
//  SkeletonAppointmentCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct SkeletonAppointmentCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.kyCard)
            .frame(height: 300)
            .overlay(ProgressView())
    }
}

#Preview {
    SkeletonAppointmentCard()
}

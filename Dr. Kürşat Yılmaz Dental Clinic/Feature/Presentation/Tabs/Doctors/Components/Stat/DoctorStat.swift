//
//  DoctorStat.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct DoctorStat: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(Color.kyText)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color.kySubtext)
        }
        .frame(maxWidth: .infinity)
    }
}

//
//  KYDivider.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.kyBorder)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }
}

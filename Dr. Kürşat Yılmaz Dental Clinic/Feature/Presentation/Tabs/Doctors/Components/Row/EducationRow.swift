//
//  EducationRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct EducationRow: View {
    let edu: DoctorEducation
    let accentColor: Color
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 5)
                if !isLast {
                    Rectangle()
                        .fill(Color.kyBorder)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }
            .frame(width: 8)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(edu.degree)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.kyText)
                    Spacer()
                    Text(edu.year)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(accentColor)
                }
                Text(edu.institution)
                    .font(.system(size: 12))
                    .foregroundColor(Color.kySubtext)
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
    }
}

//
//  EducationRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct EducationRow: View {
    let edu: DoctorEducation
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            
            VStack(spacing: 0) {
                Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
                    .padding(.top, 5)
                if !isLast {
                    Rectangle()
                        .fill(Color.kyBorder)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 8)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(edu.degree)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.kyText)
                Text(edu.institution)
                    .font(.system(size: 12))
                    .foregroundColor(Color.kySubtext)
                Text(edu.year)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 1)
            }
            .padding(.bottom, isLast ? 0 : 16)
            
            Spacer()
            
        }
    }
}

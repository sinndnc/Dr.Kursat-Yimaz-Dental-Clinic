//
//  DocumentCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct DocumentCard: View {
    let document: PatientDocument
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 72)
                    Image(systemName: document.thumbnailSystemImage)
                        .font(.system(size: 28))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(document.title)
                        .font(.kySans(13, weight: .semibold))
                        .foregroundColor(.kyText)
                        .lineLimit(2)
                    Text(document.date.kyFormatted)
                        .font(.kyMono(10))
                        .foregroundColor(.kySubtext)
                    HStack(spacing: 4) {
                        KYBadge(text: document.type.rawValue, color: .gray)
                        Spacer()
                        Text(document.fileSize)
                            .font(.kyMono(9))
                            .foregroundColor(.kySubtext.opacity(0.6))
                    }
                }
            }
            .padding(12)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}


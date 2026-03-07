//
//  NotificationsSheet.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct NotificationsSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BİLDİRİMLER")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(3).foregroundColor(Color.kyAccent)
                        Text("Tercihler")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color.kyText)
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.kySubtext)
                            .padding(10)
                            .background(Color.kySurface)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 8)

                NotificationTogglesCard()
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

//
//  NotificationTogglesCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct NotificationTogglesCard: View {
    @State private var toggleStates: [NotificationSetting: Bool] = [
        .appointmentReminder: true,
        .treatmentUpdates:    true,
        .promotions:          false,
        .smsAlerts:           true,
    ]

    private let icons: [NotificationSetting: (String, Color)] = [
        .appointmentReminder: ("bell.badge.fill",       Color(red: 0.25, green: 0.70, blue: 0.85)),
        .treatmentUpdates:    ("cross.case.fill",       Color(red: 0.38, green: 0.78, blue: 0.50)),
        .promotions:          ("tag.fill",              Color(red: 0.82, green: 0.72, blue: 0.50)),
        .smsAlerts:           ("message.fill",          Color(red: 0.55, green: 0.45, blue: 0.85)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(NotificationSetting.allCases.enumerated()), id: \.element) { i, setting in
                HStack(spacing: 12) {
                    let iconData = icons[setting]!
                    ZStack {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(iconData.1.opacity(0.12))
                            .frame(width: 34, height: 34)
                        Image(systemName: iconData.0)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(iconData.1)
                    }

                    Text(setting.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.kyText)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { toggleStates[setting] ?? false },
                        set: { toggleStates[setting] = $0 }
                    ))
                    .labelsHidden()
                    .tint(Color.kyAccent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if i < NotificationSetting.allCases.count - 1 {
                    Rectangle()
                        .fill(Color.kyBorder)
                        .frame(height: 1)
                        .padding(.leading, 62)
                }
            }
        }
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}

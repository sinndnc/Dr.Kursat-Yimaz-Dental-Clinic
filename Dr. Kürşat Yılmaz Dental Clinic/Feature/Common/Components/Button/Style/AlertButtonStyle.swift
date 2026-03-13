//
//  AlertButtonStyle.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct AlertButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed
                        ? Color(.tertiarySystemBackground)
                        : Color(.systemBackground))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

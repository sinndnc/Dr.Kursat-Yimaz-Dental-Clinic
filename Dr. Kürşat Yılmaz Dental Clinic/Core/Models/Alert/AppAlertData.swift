//
//  AppAlertData.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI
import Foundation

public struct AppAlertData: Identifiable {
    public let id = UUID()
    public let type: AppAlertType
    public let title: String
    public let message: String
    public let confirmLabel: String
    public let cancelLabel: String
    public let onConfirm: () -> Void
    public let onCancel: (() -> Void)?

    public init(
        type: AppAlertType = .warning,
        title: String,
        message: String,
        confirmLabel: String = "Evet",
        cancelLabel: String = "İptal",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.confirmLabel = confirmLabel
        self.cancelLabel = cancelLabel
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
}

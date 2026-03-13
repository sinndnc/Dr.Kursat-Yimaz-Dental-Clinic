//
//  AlertManager.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import Combine
import SwiftUI

@MainActor
public final class AlertManager: ObservableObject {
    public static let shared = AlertManager()
    @Published public var current: AppAlertData? = nil
    private init() {}
    
    public func show(_ alert: AppAlertData) {
        current = alert
    }
    
    public func dismiss() {
        current = nil
    }
    
    // MARK: - Convenience Helpers
    
    /// Çıkış yap, hesap sil gibi destructive onay alertleri
    public func confirmDestructive(
        title: String,
        message: String,
        confirmLabel: String = "Evet, Çıkış Yap",
        cancelLabel: String = "İptal",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        show(AppAlertData(
            type: .destructive,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            onConfirm: onConfirm,
            onCancel: onCancel
        ))
    }
    
    public func success(
        title: String,
        message: String,
        confirmLabel: String = "Tamam",
        onConfirm: @escaping () -> Void = {}
    ) {
        show(AppAlertData(
            type: .success,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: "Kapat",
            onConfirm: onConfirm
        ))
    }
    
    public func error(
        title: String,
        message: String,
        confirmLabel: String = "Anladım",
        onConfirm: @escaping () -> Void = {}
    ) {
        show(AppAlertData(
            type: .error,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: "Kapat",
            onConfirm: onConfirm
        ))
    }
    
    public func warning(
        title: String,
        message: String,
        confirmLabel: String = "Devam Et",
        onConfirm: @escaping () -> Void = {}
    ) {
        show(AppAlertData(
            type: .warning,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: "İptal",
            onConfirm: onConfirm
        ))
    }
    
    public func info(
        title: String,
        message: String,
        confirmLabel: String = "Tamam",
        onConfirm: @escaping () -> Void = {}
    ) {
        show(AppAlertData(
            type: .info,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: "Kapat",
            onConfirm: onConfirm
        ))
    }
}

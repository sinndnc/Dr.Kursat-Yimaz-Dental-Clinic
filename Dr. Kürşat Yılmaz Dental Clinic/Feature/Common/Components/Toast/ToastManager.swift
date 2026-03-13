//
//  ToastManager.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import Combine
import SwiftUI
import Foundation

@MainActor
public final class ToastManager: ObservableObject {
    public static let shared = ToastManager()
    
    @Published public private(set) var toasts: [ToastData] = []
    
    private var dismissTasks: [UUID: Task<Void, Never>] = [:]
    private let maxVisible = 3
    
    private init() {}
    
    public func show(_ toast: ToastData) {
        // Limit queue
        if toasts.count >= maxVisible {
            dismiss(toasts[0])
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            toasts.append(toast)
        }
        
        guard toast.duration > 0 else { return }
        
        let task = Task {
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run { dismiss(toast) }
        }
        dismissTasks[toast.id] = task
    }
    
    public func dismiss(_ toast: ToastData) {
        dismissTasks[toast.id]?.cancel()
        dismissTasks[toast.id] = nil
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            toasts.removeAll { $0.id == toast.id }
        }
    }
    
    public func dismissAll() {
        dismissTasks.values.forEach { $0.cancel() }
        dismissTasks.removeAll()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            toasts.removeAll()
        }
    }
    
    /// Sadece loading toastlarını kapat — error/success/warning toastlarına dokunma
    public func dismissLoading() {
        let loadingToasts = toasts.filter {
            if case .loading = $0.type { return true }
            return false
        }
        loadingToasts.forEach { dismiss($0) }
    }
    
    public func success(_ title: String, message: String? = nil, duration: TimeInterval = 3.0) {
        show(ToastData(title: title, message: message, type: .success, duration: duration))
    }
 
    public func error(_ title: String, message: String? = nil, duration: TimeInterval = 4.0) {
        show(ToastData(title: title, message: message, type: .error, duration: duration))
    }
 
    public func warning(_ title: String, message: String? = nil, duration: TimeInterval = 3.5) {
        show(ToastData(title: title, message: message, type: .warning, duration: duration))
    }
 
    public func info(_ title: String, message: String? = nil, duration: TimeInterval = 3.0) {
        show(ToastData(title: title, message: message, type: .info, duration: duration))
    }
 
    public func loading(_ title: String, message: String? = nil) {
        show(ToastData(title: title, message: message, type: .loading, duration: 0))
    }
}

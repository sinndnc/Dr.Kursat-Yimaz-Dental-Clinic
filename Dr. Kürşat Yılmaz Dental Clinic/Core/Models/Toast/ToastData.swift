//
//  ToastData.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import Foundation 

public struct ToastData: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let message: String?
    public let type: ToastType
    public let duration: TimeInterval
    public let action: ToastAction?
    public let position: ToastPosition
    
    public static func == (lhs: ToastData, rhs: ToastData) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        message: String? = nil,
        type: ToastType = .info,
        duration: TimeInterval = 3.0,
        action: ToastAction? = nil,
        position: ToastPosition = .top
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.duration = duration
        self.action = action
        self.position = position
    }
}

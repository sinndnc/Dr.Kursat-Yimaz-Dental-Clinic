//
//  ToastAction.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//


public struct ToastAction: Equatable {
    public let label: String
    public let handler: () -> Void
 
    public static func == (lhs: ToastAction, rhs: ToastAction) -> Bool {
        lhs.label == rhs.label
    }
 
    public init(label: String, handler: @escaping () -> Void) {
        self.label = label
        self.handler = handler
    }
}
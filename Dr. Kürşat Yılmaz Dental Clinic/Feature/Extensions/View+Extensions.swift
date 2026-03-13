//
//  View+Extensions.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import Foundation
import SwiftUI
 
public extension View {
    func toastContainer() -> some View {
        modifier(ToastModifier())
    }
    
    func alertContainer() -> some View {
        modifier(AlertModifier())
    }
}


//
//  ToastModifier.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                ToastContainerView()
                Spacer()
            }
        }
    }
}

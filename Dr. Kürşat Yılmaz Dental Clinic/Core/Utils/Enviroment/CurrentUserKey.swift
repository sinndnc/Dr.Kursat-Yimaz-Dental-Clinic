//
//  CurrentUserKey.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import SwiftUI



private struct CurrentUserKey: EnvironmentKey {
    static let defaultValue: CurrentUser = CurrentUser()
}

extension EnvironmentValues {
    var currentUser: CurrentUser {
        get { self[CurrentUserKey.self] }
        set { self[CurrentUserKey.self] = newValue }
    }
}

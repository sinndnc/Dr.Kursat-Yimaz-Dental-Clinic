//
//  AuthState.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//


enum AuthState: Equatable {
    case loading
    case unauthenticated
    case authenticated
    case registrationPending   
}

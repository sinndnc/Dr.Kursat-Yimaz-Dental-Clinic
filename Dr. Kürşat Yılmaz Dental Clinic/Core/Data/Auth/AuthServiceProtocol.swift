//
//  AuthServiceProtocol.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Foundation
import Combine

protocol AuthServiceProtocol: AnyObject {
    
    var authState:      AuthState  { get }
    var currentPatient: Patient?   { get }
    var isLoading:      Bool       { get }
    var errorMessage:   String?    { get }
    var isAuthenticated: Bool      { get }
    var currentUID:     String?    { get }
    
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    var currentPatientPublisher: AnyPublisher<Patient?, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }
    
    func signOut() throws
    func deleteAccount() async throws
    func sendPasswordReset(to email: String) async throws
    func signIn(email: String, password: String) async throws
    func register(email:String,password:String,firstName:String,lastName:String,phone:String?,birthDate: Date?,gender:Gender?) async throws
    func updateCurrentPatient(_ updated: Patient) async throws
    func reauthenticate(email: String, password: String) async throws
    func changePassword(currentPassword: String, newPassword: String) async throws
}

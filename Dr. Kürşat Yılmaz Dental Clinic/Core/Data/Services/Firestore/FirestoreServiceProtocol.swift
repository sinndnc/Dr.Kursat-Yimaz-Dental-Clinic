//
//  FirestoreServiceProtocol.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//
//  All @Published state is exposed as AnyPublisher so any consumer
//  can subscribe without importing Firebase or referencing the
//  concrete FirestoreService type.

import Foundation
import Combine

protocol FirestoreServiceProtocol: AnyObject {
    
    var doctors: [Doctor] { get  }
    var clinics: [Clinic] { get  }
    var services: [Service] { get  }
    var appointments: [Appointment] { get  }
    
    var doctorsStatePublisher: AnyPublisher<[Doctor], Never> { get }
    var clinicsPublisher: AnyPublisher<[Clinic], Never> { get }
    var servicesPublisher: AnyPublisher<[Service], Never> { get }
    var appointmentsPublisher: AnyPublisher<[Appointment], Never> { get }
    
    func removeAllListeners()
    func removeAuthenticatedListeners()
    func startUnauthticatedListeners(clinicId: String?)
    func startAuthenticatedListeners(patientId: String, clinicId: String?)
    
    func listenToAppointments(
        clinicId:  String?,
        doctorId:  String?,
        patientId: String?
    )
    func fetchPatient(id: String)     async throws -> Patient
    func fetchDoctor(id: String)      async throws -> Doctor
    func fetchClinic(id: String)      async throws -> Clinic
    func fetchService(id: String)     async throws -> Service
    func fetchAppointment(id: String) async throws -> Appointment
    
    func fetchAppointments(forPatientId patientId: String) async throws -> [Appointment]
    func fetchAppointments(from startDate: Date,to endDate:Date,clinicId:String?) async throws -> [Appointment]
    
    @discardableResult func createPatient(_ patient: Patient)      async throws -> String
    @discardableResult func createDoctor(_ doctor: Doctor)         async throws -> String
    @discardableResult func createClinic(_ clinic: Clinic)         async throws -> String
    @discardableResult func createService(_ service: Service)      async throws -> String
    @discardableResult func createAppointment(_ appt: Appointment) async throws -> String
    
    func updatePatient(_ patient: Patient) async throws
    func updateDoctor(_ doctor: Doctor) async throws
    func updateClinic(_ clinic: Clinic) async throws
    func updateService(_ service: Service) async throws
    func updateAppointment(_ appointment: Appointment) async throws
    func updateAppointmentStatus(_ id: String, status: AppointmentStatus) async throws
    func updatePatientField(_ field: String, value: Any, patientID: String) async throws
    
    func deletePatient(id: String)     async throws
    func deleteDoctor(id: String)      async throws
    func deleteClinic(id: String)      async throws
    func deleteService(id: String)     async throws
    func cancelAppointment(id: String) async throws
    
    func batchUpdateAppointmentStatuses(
        _ updates: [(id: String, status: AppointmentStatus)]
    ) async throws
    
}

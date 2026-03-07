//
//  DoctorsDestination.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//


enum DoctorsDestination: Hashable {
    case doctorDetail(id: String)
    case doctorReviews(doctorId: String)
    case bookAppointment(doctorId: String)
    case doctorFilter
}

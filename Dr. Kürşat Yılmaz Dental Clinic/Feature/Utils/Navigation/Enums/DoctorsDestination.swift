//
//  DoctorsDestination.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//


enum DoctorsDestination: Hashable {
    case doctorDetail(doc: EnrichedDoctor)
    case bookAppointment
    case doctorFilter
}

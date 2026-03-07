//
//  AppointmentsDestination.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//


enum AppointmentsDestination: Hashable {
    case newAppointment
    case appointmentDetail(id: String)
    case appointmentEdit(id: String)
    case doctorSelection
    case dateTimePicker(appointmentId: String)
}
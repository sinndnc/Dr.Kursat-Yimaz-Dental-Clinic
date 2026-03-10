//
//  AppointmentsDestination.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//


enum AppointmentsDestination: Hashable {
    case newAppointment
    case doctorSelection
    case dateTimePicker(apt: Appointment)
    case appointmentEdit(apt: Appointment)
    case appointmentDetail(apt: Appointment)
}

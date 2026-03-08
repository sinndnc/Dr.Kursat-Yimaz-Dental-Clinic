//
//  NotificationSetting.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//


enum NotificationSetting: String, CaseIterable {
    case appointmentReminder = "Randevu Hatırlatıcısı"
    case treatmentUpdates    = "Tedavi Güncellemeleri"
    case promotions          = "Kampanya & Haberler"
    case smsAlerts           = "SMS Bildirimleri"
}
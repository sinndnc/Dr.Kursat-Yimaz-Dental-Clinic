//
//  HomeDestination.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

enum HomeDestination: Hashable {
    case notifications
    case notificationDetail(id: String)
    case campaigns
    case campaignDetail(id: String)
    case healthSummary
}

//
//  ServicesDestination.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//


enum ServicesDestination: Hashable {
    case serviceDetail(service: DentalService)
    case serviceCategory(category: ServiceCategory)
    case bookService(id: String)
}

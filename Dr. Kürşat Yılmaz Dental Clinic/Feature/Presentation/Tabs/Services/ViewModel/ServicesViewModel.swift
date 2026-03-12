//
//  ServicesViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/11/26.
//

import Foundation
import Combine

final class ServicesViewModel: ObservableObject{
    
    @Injected private var fs: FirestoreServiceProtocol
    
    @Published var services: [Service] = []
    @Published var showDetail: Bool = false
    @Published var showAppointment: Bool = false
    @Published var selectedCategory: ServiceCategory = .restorative
    
    var filteredServices: [Service] {
        services.filter { $0.category == selectedCategory }
    }
    
    init(){
        fs.servicesPublisher
            .assign(to: &$services)
    }
}

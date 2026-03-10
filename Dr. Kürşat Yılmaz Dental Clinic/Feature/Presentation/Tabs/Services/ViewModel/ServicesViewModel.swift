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
    
    @Published var showDetail: Bool = false
    @Published var headerAppeared: Bool = false
    @Published var showAppointment: Bool = false
    @Published var selectedCategory: ServiceCategory = .restorative
    
    var filteredServices: [Service] {
        fs.services.filter { $0.category == selectedCategory }
    }
}

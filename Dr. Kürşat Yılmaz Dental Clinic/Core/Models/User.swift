//
//  User.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import FirebaseFirestore
import Foundation

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var phone: String
    var profileImage: String
    var totalVisits: Int
    var loyaltyPoints: Int
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, profileImage, totalVisits, loyaltyPoints, createdAt
    }
    
    static let empty = User(
        name: "",
        email: "",
        phone: "",
        profileImage: "person.circle.fill",
        totalVisits: 0,
        loyaltyPoints: 0
    )
}

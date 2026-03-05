//
//  FirestoreMockService.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//
import SwiftUI
import Foundation

class FirestoreMockService{
    
    static let testimonials: [Testimonial] = [
        Testimonial(
            name: "Ayşe K.",
            initials: "AK",
            text: "Lamina kaplama sonrası gülümsemeye bayılıyorum. Dr. Kürşat son derece titiz ve güven verici.",
            rating: 5,
            treatment: "Lamina Kaplama",
            avatarColor: Color(red: 0.82, green: 0.72, blue: 0.50)
        ),
        Testimonial(
            name: "Mehmet T.",
            initials: "MT",
            text: "Implant tedavim boyunca hiç endişe yaşamadım. 3D planlama süreci gerçekten etkileyiciydi.",
            rating: 5,
            treatment: "Dental İmplant",
            avatarColor: Color(red: 0.4, green: 0.75, blue: 0.65)
        ),
        Testimonial(
            name: "Selin D.",
            initials: "SD",
            text: "EMS temizliği inanılmaz konforlu, ağzımı bambaşka hissettiriyor. Kliniğin atmosferi mükemmel.",
            rating: 5,
            treatment: "EMS / GBT Temizlik",
            avatarColor: Color(red: 0.55, green: 0.45, blue: 0.85)
        ),
    ]
}

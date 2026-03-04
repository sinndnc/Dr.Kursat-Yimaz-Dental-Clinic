//
//  Doctor.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//
import FirebaseFirestore
import Foundation


struct Doctor: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var specialty: String
    var rating: Double
    var reviewCount: Int
    var experience: Int
    var image: String
    var availableDays: [String]
    var bio: String
    var isAvailable: Bool
    
    static let sampleData: [Doctor] = [
        Doctor(name: "Dr. Elif Şahin", specialty: "Ortodonti", rating: 4.9, reviewCount: 128, experience: 12, image: "stethoscope", availableDays: ["Pzt", "Sal", "Çar"], bio: "İstanbul Üniversitesi mezunu, 12 yıllık deneyimiyle ortodonti alanında uzman.", isAvailable: true),
        Doctor(name: "Dr. Mert Kaya", specialty: "İmplant", rating: 4.8, reviewCount: 96, experience: 8, image: "cross.case.fill", availableDays: ["Sal", "Per", "Cum"], bio: "İmplant ve estetik diş hekimliği konusunda uzmanlaşmış.", isAvailable: true),
        Doctor(name: "Dr. Selin Arslan", specialty: "Pedodonti", rating: 4.9, reviewCount: 214, experience: 10, image: "heart.fill", availableDays: ["Pzt", "Çar", "Per"], bio: "Çocuk diş hekimliğinde Türkiye'nin önde gelen uzmanlarından.", isAvailable: false),
        Doctor(name: "Dr. Burak Demir", specialty: "Periodontoloji", rating: 4.7, reviewCount: 87, experience: 6, image: "waveform.path.ecg", availableDays: ["Sal", "Çar", "Cum"], bio: "Diş eti hastalıkları ve periodontoloji alanında uzman.", isAvailable: true)
    ]
}

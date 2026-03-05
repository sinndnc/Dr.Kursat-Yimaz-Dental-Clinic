//
//  Doctor.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//
import FirebaseFirestore
import Foundation
import SwiftUI

struct Doctor: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let title: String
    let specialty: String
    let tagline: String
    let bio: String
    let experience: String
    let patientCount: String
    let satisfactionRate: String
    let avatarInitials: String
    let expertise: [DoctorExpertise]
    let education: [DoctorEducation]
    let languages: [String]
    let availableDays: [String]
    
    var color: Color{
        Color.kyAccent
    }
}

struct DoctorExpertise: Identifiable ,Codable{
    let id = UUID()
    let title: String
    let icon: String
    
    var color: Color{
        Color.kyAccent
    }
}

struct DoctorEducation: Identifiable , Codable{
    let id = UUID()
    let degree: String
    let institution: String
    let year: String
}



extension Doctor {
    static let all: [Doctor] = [
        Doctor(
            name: "Dr. Kürşat Yılmaz",
            title: "Diş Hekimi",
            specialty: "Estetik & Restoratif Diş Hekimliği",
            tagline: "Yeni nesil gülüş tasarımının öncüsü",
            bio: "Dr. Kürşat Yılmaz, estetik ve restoratif diş hekimliği alanında 8 yılı aşkın deneyimiyle minimal invaziv tedavi felsefesini benimseyen bir klinisyendir. CAD/CAM teknolojileri, dijital gülüş tasarımı ve E.max lamina kaplama konularında uzmanlaşmış olup her tedaviyi kişiye özel dijital planlama ile yürütür.",
            experience: "8+ Yıl",
            patientCount: "2.500+",
            satisfactionRate: "%99",
            avatarInitials: "KY",
            expertise: [
                DoctorExpertise(title: "Lamina Kaplama",icon: "seal.fill"),
                DoctorExpertise(title: "Dental İmplant",icon: "bolt.shield.fill"),
                DoctorExpertise(title: "Kompozit Tasarım",icon: "wand.and.stars"),
                DoctorExpertise(title: "CAD/CAM",icon: "cpu.fill"),
                DoctorExpertise(title: "Aligner Tedavisi",icon: "mouth.fill"),
                DoctorExpertise(title: "EMS Temizlik",icon: "wind"),
            ],
            education: [
                DoctorEducation(degree: "Diş Hekimliği Fakültesi",institution: "Marmara Üniversitesi",year: "2014"),
                DoctorEducation(degree: "Estetik Diş Hekimliği Sertifikası",institution: "European Academy of Esthetic Dentistry", year: "2017"),
                DoctorEducation(degree: "İmplantoloji İleri Eğitim",institution: "Straumann Institute",year: "2019"),
                DoctorEducation(degree: "Digital Smile Design (DSD)",institution: "DSD Barcelona",year: "2021"),
            ],
            languages: ["Türkçe", "İngilizce"],
            availableDays: ["Pzt", "Sal", "Çar", "Per", "Cum"],
        ),
        Doctor(
            name: "Dr. Elif Arslan",
            title: "Uzman Diş Hekimi",
            specialty: "Ortodonti & Şeffaf Plak",
            tagline: "Görünmez ortodontinin uzmanı",
            bio: "Dr. Elif Arslan, ortodonti ve şeffaf plak tedavilerinde uzmanlaşmış, dijital planlama yöntemlerini kullanan deneyimli bir diş hekimidir. Her hastaya özel hizalama protokolleri tasarlar.",
            experience: "6 Yıl",
            patientCount: "1.200+",
            satisfactionRate: "%98",
            avatarInitials: "EA",
            expertise: [
                DoctorExpertise(title: "Aligner",icon: "mouth.fill"),
                DoctorExpertise(title: "Dijital Planlama",icon: "camera.metering.center.weighted"),
                DoctorExpertise(title: "Retainer", icon: "checkmark.shield.fill"),
            ],
            education: [
                DoctorEducation(degree: "Diş Hekimliği Fakültesi",  institution: "Hacettepe Üniversitesi", year: "2016"),
                DoctorEducation(degree: "Ortodonti Uzmanlığı",      institution: "İstanbul Üniversitesi",  year: "2020"),
                DoctorEducation(degree: "Invisalign Sertifikası",   institution: "Align Technology",       year: "2021"),
            ],
            languages: ["Türkçe", "İngilizce", "Almanca"],
            availableDays: ["Sal", "Çar", "Per", "Cum", "Cmt"],
        ),
        Doctor(
            name: "Dr. Burak Demir",
            title: "Uzman Diş Hekimi",
            specialty: "Endodonti & Restorasyon",
            tagline: "Kanal tedavisinde hassas el sanatı",
            bio: "Dr. Burak Demir, endodonti ve koruyucu diş hekimliği alanında uzmanlaşmış; kanal tedavisinden minimal invaziv restorasyonlara kadar geniş bir klinik yelpazede çalışmaktadır.",
            experience: "5 Yıl",
            patientCount: "900+",
            satisfactionRate: "%97",
            avatarInitials: "BD",
            expertise: [
                DoctorExpertise(title: "Endodonti",         icon: "cross.circle.fill"),
                DoctorExpertise(title: "Kanal Tedavisi",    icon: "waveform.path.ecg"),
                DoctorExpertise(title: "Onlay Restorasyon", icon: "puzzlepiece.fill"),
            ],
            education: [
                DoctorEducation(degree: "Diş Hekimliği Fakültesi", institution: "İstanbul Üniversitesi", year: "2017"),
                DoctorEducation(degree: "Endodonti Uzmanlığı",     institution: "Ege Üniversitesi",      year: "2022"),
            ],
            languages: ["Türkçe"],
            availableDays: ["Pzt", "Çar", "Per"],
        ),
    ]
}


//
//  DentalService.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import FirebaseFirestore
import Foundation
import SwiftUI

struct DentalService: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var icon: String
    var colorName: String
    var price: String
    var duration: String
    
    var color: Color {
        switch colorName {
        case "cyan":   return .cyan
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "red":    return .red
        case "blue":   return .blue
        case "green":  return .green
        case "pink":   return .pink
        default:       return .blue
        }
    }
    
    static let sampleData: [DentalService] = [
        DentalService(name: "Diş Temizliği",  description: "Profesyonel tartır ve leke temizliği",      icon: "sparkles",              colorName: "cyan",   price: "₺800",    duration: "45 dk"),
        DentalService(name: "Diş Beyazlatma", description: "Lazer ile profesyonel beyazlatma",           icon: "sun.max.fill",          colorName: "yellow", price: "₺2.500",  duration: "90 dk"),
        DentalService(name: "İmplant",        description: "Titanyum vida ile kalıcı diş implantı",      icon: "cross.circle.fill",     colorName: "purple", price: "₺8.000",  duration: "2 seans"),
        DentalService(name: "Ortodonti",      description: "Şeffaf plak ve metal tel seçenekleri",       icon: "mouth.fill",            colorName: "orange", price: "₺15.000", duration: "12-18 ay"),
        DentalService(name: "Kanal Tedavisi", description: "Ağrısız kanal dolgusu",                      icon: "waveform.path.ecg",     colorName: "red",    price: "₺1.800",  duration: "60 dk"),
        DentalService(name: "Diş Dolgusu",   description: "Kompozit ve seramik dolgu",                  icon: "paintbrush.fill",       colorName: "blue",   price: "₺600",    duration: "30 dk"),
        DentalService(name: "Diş Çekimi",    description: "Lokal anestezi ile ağrısız çekim",           icon: "scissors",              colorName: "green",  price: "₺400",    duration: "20 dk"),
        DentalService(name: "Pedodonti",     description: "Çocuklara özel diş tedavisi",                icon: "heart.fill",            colorName: "pink",   price: "₺500",    duration: "45 dk")
    ]
}

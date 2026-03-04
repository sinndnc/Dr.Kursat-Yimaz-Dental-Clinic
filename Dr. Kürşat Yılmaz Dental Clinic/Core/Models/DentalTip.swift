//
//  DentalTip.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import Foundation
import SwiftUI

struct DentalTip: Identifiable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var icon: String
    var category: String
    var color: Color
    
    static let sampleData: [DentalTip] = [
        DentalTip(title: "Doğru Fırçalama",    content: "Dişlerinizi günde 2 kez, en az 2 dakika boyunca fırçalayın. Diş etine 45 derece açıyla yaklaşın.", icon: "🪥", category: "Hijyen",    color: .blue),
        DentalTip(title: "Diş İpi Kullanımı",  content: "Diş ipi, fırçanın ulaşamadığı yüzeyleri temizler. Günde bir kez kullanın.",                        icon: "🧵", category: "Hijyen",    color: .green),
        DentalTip(title: "Şeker Tüketimi",     content: "Şekerli içecek ve yiyecekler tükettikten sonra ağzınızı su ile çalkalayın.",                       icon: "🍬", category: "Beslenme",  color: .orange),
        DentalTip(title: "Düzenli Kontrol",    content: "6 ayda bir diş hekiminizi ziyaret edin. Erken teşhis tedaviyi kolaylaştırır.",                     icon: "📅", category: "Kontrol",   color: .purple)
    ]
}

//
//  DentalService.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import FirebaseFirestore
import Foundation
import SwiftUI

struct DentalService: Identifiable ,Codable {
    let id = UUID()
    let category: ServiceCategory
    let title: String
    let subtitle: String
    let description: String
    let tags: [String]
    let badgeText: String?
    let sfSymbol: String
    let details: [ServiceDetail]
    
    var accentColor: Color {
        switch "colorName" {
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
}

struct ServiceDetail: Identifiable , Codable{
    let id = UUID()
    let heading: String
    let bullets: [String]
}

extension DentalService {
    static let all: [DentalService] = [
        // ESTETIK
        DentalService(
            category: .aesthetic,
            title: "Lamina Kaplama",
            subtitle: "Minimal-Prep E.max Laminalar",
            description: "Dişin ön yüzeyine yapıştırılan ultra-ince seramik tabakalar. Neredeyse hiç aşındırma yapılmadan doğal ışık geçirgenliği ve zamansız estetik elde edilir.",
            tags: ["E.max", "Minimal İnvaziv", "Dijital Tasarım"],
            badgeText: nil,
            sfSymbol: "seal.fill",
            details: [
                ServiceDetail(heading: "Kimler için uygun?", bullets: [
                    "Üst seviye, kalıcı estetik arayanlar",
                    "Renk ve form bozukluklarını uzun vadeli çözmek isteyenler"
                ]),
                ServiceDetail(heading: "Nasıl uygulanır?", bullets: [
                    "Minimal-prep E.max laminalar tercih edilir",
                    "3D taramalarla kişiye özel tasarlanır",
                    "Laboratuvar destekli üretim sonrası profesyonel yapıştırma"
                ]),
                ServiceDetail(heading: "Avantajları", bullets: [
                    "Doğal ışık geçirgenliği, zamansız estetik",
                    "Yüksek dayanıklılık",
                    "Uzun vadede stabil sonuçlar"
                ])
            ]
        ),
        DentalService(
            category: .aesthetic,
            title: "Kompozit Gülüş Tasarımı",
            subtitle: "Tek Seansta Dönüşüm",
            description: "Dişlere zarar vermeden form ve renk düzenlemeleri. 3D dijital planlama ile sonuç işlem öncesi öngörülür; kompozit materyal tabaka tabaka uygulanır.",
            tags: ["Tek Seans", "Konservatif", "Dijital Mock-up"],
            badgeText: nil,
            sfSymbol: "wand.and.stars",
            details: [
                ServiceDetail(heading: "Kimler için uygun?", bullets: [
                    "Sağlıklı diş yapısına sahip, küçük form veya renk bozuklukları olanlar",
                    "Hızlı ve bütçe dostu çözüm arayanlar"
                ]),
                ServiceDetail(heading: "Nasıl uygulanır?", bullets: [
                    "Dişler kesilmez, yalnızca yüzey hazırlığı yapılır",
                    "Dijital mock-up ile gülüş önceden planlanır",
                    "Kompozit materyal tek seansta şekillendirilir"
                ]),
                ServiceDetail(heading: "Avantajları", bullets: [
                    "Diş dokusu maksimum korunur",
                    "Hızlı sonuç: çoğunlukla tek seans",
                    "İstenirse lamina veya hibrit çözümlere dönüştürülebilir"
                ])
            ]
        ),
        DentalService(
            category: .aesthetic,
            title: "Klinikte 3D Üretim",
            subtitle: "Same Day Restorasyon",
            description: "Türkiye'de bir ilk. Özel 3D yazıcılarla diş restorasyonları çok daha hızlı ve kişiye özel üretilebilecek. Minimal invaziv prensipler, maksimum estetik.",
            tags: ["Yakında", "3D Yazıcı", "İnnovasyon"],
            badgeText: "Çok Yakında",
            sfSymbol: "cube.transparent.fill",
            details: [
                ServiceDetail(heading: "Ne sunacak?", bullets: [
                    "Aynı gün teslim restorasyon imkânı",
                    "Kişiye özel dijital üretim",
                    "Minimal invaziv prensipler ile maksimum estetik"
                ])
            ]
        ),

        // RESTORATIF
        DentalService(
            category: .restorative,
            title: "Onlay & Overlay Restorasyonlar",
            subtitle: "CAD/CAM Teknolojisi",
            description: "Dişin tamamını kaplamadan yalnızca hasarlı bölgeyi restore eden çözümler. Dijital tarama ve CAD/CAM teknolojisiyle kişiye özel üretilir.",
            tags: ["CAD/CAM", "Doğal Doku Koruma", "Dayanıklı"],
            badgeText: nil,
            sfSymbol: "puzzlepiece.fill",
            details: [
                ServiceDetail(heading: "Özellikler", bullets: [
                    "Dişin yalnızca hasarlı bölgesi restore edilir",
                    "Dijital tarama ile hassas ölçü alınır",
                    "CAD/CAM teknolojisiyle kişiye özel üretim"
                ])
            ]
        ),
        DentalService(
            category: .restorative,
            title: "İmplant & Protetik Çözümler",
            subtitle: "Straumann Implant Sistemi",
            description: "Eksik dişlerin yerine titanyum implantlar; üzerine porselen veya zirkonyum destekli protezler. Tüm süreç 3D planlama ile öngörülebilir şekilde hazırlanır.",
            tags: ["Straumann", "3D Planlama", "Zirkonyum"],
            badgeText: nil,
            sfSymbol: "bolt.shield.fill",
            details: [
                ServiceDetail(heading: "Süreç", bullets: [
                    "3D planlama ile implant pozisyonu belirlenir",
                    "Güven ve uzun ömür için Straumann implant kullanılır",
                    "Porselen veya zirkonyum protezlerle tamamlanır",
                    "Fonksiyon, estetik ve biyouyumluluk bir arada sağlanır"
                ])
            ]
        ),
        DentalService(
            category: .restorative,
            title: "Dolgu & Koruyucu Uygulamalar",
            subtitle: "Yüksek Kalite Kompozit",
            description: "Küçük çürükler minimal preparasyonla temizlenir, yüksek kalite kompozit dolgularla restore edilir. Fissür örtücüler ve florid desteğiyle uzun vadeli koruma.",
            tags: ["Kompozit Dolgu", "Fissür Örtücü", "Florid"],
            badgeText: nil,
            sfSymbol: "shield.lefthalf.filled",
            details: [
                ServiceDetail(heading: "Uygulamalar", bullets: [
                    "Minimal preparasyon ile çürük temizliği",
                    "Yüksek kalite kompozit dolgu restorasyonu",
                    "Fissür örtücü uygulamaları",
                    "Florid desteği ve düzenli kontrol protokolleri"
                ])
            ]
        ),
        DentalService(
            category: .restorative,
            title: "3D Tarama & Dijital Planlama",
            subtitle: "Öngörülebilir Tedavi",
            description: "Ağız içi yüksek çözünürlüklü taramalar ve dijital simülasyonlarla tedavi öngörülebilir hale gelir. Sonuç işlem başlamadan görülür.",
            tags: ["Dijital İz", "Simülasyon", "Kişiye Özel"],
            badgeText: nil,
            sfSymbol: "camera.metering.center.weighted",
            details: [
                ServiceDetail(heading: "Süreç", bullets: [
                    "Yüksek çözünürlüklü ağız içi tarama",
                    "Dijital simülasyon ile tedavi planlaması",
                    "Sonuç işlem öncesi hastaya gösterilir",
                    "Her adım kişiye özel planlanır"
                ])
            ]
        ),
        DentalService(
            category: .restorative,
            title: "EMS / GBT Diş Temizliği",
            subtitle: "Airflow EMS Teknolojisi",
            description: "Klasik diş taşından öte, biyofilmi hedefleyen diş-diş eti dostu temizlik yöntemi. EMS AirFlow cihazlarıyla minimal invaziv, güvenli ve konforlu sonuçlar.",
            tags: ["EMS AirFlow", "Biyofilm", "Konforlu"],
            badgeText: nil,
            sfSymbol: "wind",
            details: [
                ServiceDetail(heading: "Özellikler", bullets: [
                    "Biyofilm hedefli temizlik protokolü",
                    "EMS AirFlow cihazı ile uygulama",
                    "Diş ve diş eti dostu, minimal invaziv",
                    "Konforlu ve güvenli temizlik deneyimi"
                ])
            ]
        ),
        DentalService(
            category: .restorative,
            title: "Şeffaf Plak (Aligner) Tedavisi",
            subtitle: "Görünmez Ortodonti",
            description: "Dişlerdeki çapraşıklık, boşluk veya hizalama sorunları tel kullanılmadan, görünmez şeffaf plaklarla düzeltilir. Dijital planlama ile öngörülebilir ilerleme.",
            tags: ["Aligner", "Görünmez", "Dijital Planlama"],
            badgeText: nil,
            sfSymbol: "mouth.fill",
            details: [
                ServiceDetail(heading: "Tedavi Süreci", bullets: [
                    "Dijital planlama ile idealkonuma yol haritası",
                    "Plaklarla aşamalı diş hareketlendirmesi",
                    "Görünmez ve çıkarılabilir kullanım konforu",
                    "Estetikten ödün vermeden dengeli gülüş"
                ])
            ]
        ),
    ]
}

//struct DentalService: Identifiable, Codable {
//    @DocumentID var id: String?
//    var name: String
//    var description: String
//    var icon: String
//    var colorName: String
//    var price: String
//    var duration: String
//
//    var color: Color {
//        switch colorName {
//        case "cyan":   return .cyan
//        case "yellow": return .yellow
//        case "purple": return .purple
//        case "orange": return .orange
//        case "red":    return .red
//        case "blue":   return .blue
//        case "green":  return .green
//        case "pink":   return .pink
//        default:       return .blue
//        }
//    }
//
//    static let sampleData: [DentalService] = [
//        DentalService(name: "Diş Temizliği",  description: "Profesyonel tartır ve leke temizliği",      icon: "sparkles",              colorName: "cyan",   price: "₺800",    duration: "45 dk"),
//        DentalService(name: "Diş Beyazlatma", description: "Lazer ile profesyonel beyazlatma",           icon: "sun.max.fill",          colorName: "yellow", price: "₺2.500",  duration: "90 dk"),
//        DentalService(name: "İmplant",        description: "Titanyum vida ile kalıcı diş implantı",      icon: "cross.circle.fill",     colorName: "purple", price: "₺8.000",  duration: "2 seans"),
//        DentalService(name: "Ortodonti",      description: "Şeffaf plak ve metal tel seçenekleri",       icon: "mouth.fill",            colorName: "orange", price: "₺15.000", duration: "12-18 ay"),
//        DentalService(name: "Kanal Tedavisi", description: "Ağrısız kanal dolgusu",                      icon: "waveform.path.ecg",     colorName: "red",    price: "₺1.800",  duration: "60 dk"),
//        DentalService(name: "Diş Dolgusu",   description: "Kompozit ve seramik dolgu",                  icon: "paintbrush.fill",       colorName: "blue",   price: "₺600",    duration: "30 dk"),
//        DentalService(name: "Diş Çekimi",    description: "Lokal anestezi ile ağrısız çekim",           icon: "scissors",              colorName: "green",  price: "₺400",    duration: "20 dk"),
//        DentalService(name: "Pedodonti",     description: "Çocuklara özel diş tedavisi",                icon: "heart.fill",            colorName: "pink",   price: "₺500",    duration: "45 dk")
//    ]
//}

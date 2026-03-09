//
//  TechItemData.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Foundation

struct TechItemData{
    
    static let items: [TechItem] = [
        TechItem(name: "CAD/CAM",        description: "Dijital tarama ile hassas restorasyon",      icon: "cpu.fill",                       badge: nil),
        TechItem(name: "EMS AirFlow",    description: "Biyofilm hedefli konforlu temizlik",         icon: "wind",                           badge: nil),
        TechItem(name: "Straumann",      description: "Dünya standartlarında implant sistemi",      icon: "bolt.shield.fill",               badge: nil),
        TechItem(name: "3D Yazıcı",      description: "Aynı gün kişisel restorasyon üretimi",       icon: "cube.transparent.fill",          badge: "Yakında"),
    ]
    
}

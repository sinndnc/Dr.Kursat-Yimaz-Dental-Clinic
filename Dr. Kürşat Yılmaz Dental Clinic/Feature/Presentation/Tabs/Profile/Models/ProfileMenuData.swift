//
//  ProfileMenuData.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//


import SwiftUI

struct ProfileMenuData {
    
    static let menuSections: [ProfileMenuSection] = [
        ProfileMenuSection(
            title: "Hesap",
            items: [
                ProfileMenuItem(
                    title: "Kişisel Bilgiler",
                    route: .editProfile,
                    subtitle: "Ad, telefon, doğum tarihi",
                    icon: "person.fill",
                    color: Color(red: 0.82, green: 0.72, blue: 0.50),
                    trailingText: nil,
                    isDestructive: false,
                    hasChevron: true
                ),
                ProfileMenuItem(
                    title: "Sağlık Bilgileri",
                    route: .healthHistory,
                    subtitle: "Kan grubu, alerjiler, notlar",
                    icon: "cross.case.fill",
                    color: Color(red: 0.38, green: 0.78, blue: 0.50),
                    trailingText: nil,
                    isDestructive: false,
                    hasChevron: true
                ),
                ProfileMenuItem(
                    title: "Şifre & Güvenlik",
                    route: .editProfile,
                    subtitle: nil,
                    icon: "lock.fill",
                    color: Color(red: 0.30, green: 0.60, blue: 0.90),
                    trailingText: nil,
                    isDestructive: false,
                    hasChevron: true
                ),
            ]
        ),
        ProfileMenuSection(
            title: "Klinik",
            items: [
                ProfileMenuItem(
                    title: "Tedavi Geçmişim",
                    route: .healthHistory,
                    subtitle: nil,
                    icon: "clock.fill",
                    color: Color(red: 0.55, green: 0.45, blue: 0.85),
                    trailingText: "5 işlem",
                    isDestructive: false,
                    hasChevron: true
                ),
                ProfileMenuItem(
                    title: "Belgelerim",
                    route: .paymentMethods,
                    subtitle: "Röntgen, raporlar",
                    icon: "doc.fill",
                    color: Color(red: 0.90, green: 0.55, blue: 0.30),
                    trailingText: nil,
                    isDestructive: false,
                    hasChevron: true
                ),
                ProfileMenuItem(
                    title: "Fatura & Ödemeler",
                    route: .paymentMethods,
                    subtitle: nil,
                    icon: "creditcard.fill",
                    color: Color(red: 0.82, green: 0.72, blue: 0.50),
                    trailingText: nil,
                    isDestructive: false,
                    hasChevron: true
                ),
            ]
        ),
        ProfileMenuSection(
            title: "Uygulama",
            items: [
                ProfileMenuItem(
                    title: "Bildirimler",
                    route: .notifications,
                    subtitle: nil,
                    icon: "bell.fill",
                    color: Color(red: 0.25, green: 0.70, blue: 0.85),
                    trailingText: nil,
                    isDestructive: false,
                    hasChevron: true
                ),
                ProfileMenuItem(
                    title: "Dil",
                    route: .editProfile,
                    subtitle: nil,
                    icon: "globe",
                    color: Color(red: 0.40, green: 0.75, blue: 0.65),
                    trailingText: "Türkçe",
                    isDestructive: false,
                    hasChevron: true
                ),
                ProfileMenuItem(
                    title: "Tema",
                    route: .privacyPolicy,
                    subtitle: nil,
                    icon: "moon.fill",
                    color: Color(red: 0.55, green: 0.45, blue: 0.85),
                    trailingText: "Koyu",
                    isDestructive: false,
                    hasChevron: true
                ),
                ProfileMenuItem(
                    title: "Gizlilik Politikası",
                    route: .privacyPolicy,
                    subtitle: nil,
                    icon: "hand.raised.fill",
                    color: Color(red: 0.60, green: 0.58, blue: 0.55),
                    trailingText: nil,
                    isDestructive: false,
                    hasChevron: true
                ),
            ]
        ),
        ProfileMenuSection(
            title: "",
            items: [
                ProfileMenuItem(
                    title: "Çıkış Yap",
                    route: .logout,
                    subtitle: nil,
                    icon: "arrow.right.square.fill",
                    color: Color(red: 0.85, green: 0.35, blue: 0.35),
                    trailingText: nil,
                    isDestructive: true,
                    hasChevron: false
                ),
            ]
        ),
    ]
}

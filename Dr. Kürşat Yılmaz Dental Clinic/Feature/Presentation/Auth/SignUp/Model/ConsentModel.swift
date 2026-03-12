import Foundation
import UIKit

// MARK: - Rıza Kaydı Modeli
struct ConsentRecord: Codable {
    let id: UUID
    let userId: String
    let timestamp: Date
    let ipAddress: String?
    let appVersion: String
    let deviceModel: String
    let osVersion: String

    // Rıza kalemleri
    var identityDataConsent: Bool      // Kimlik verisi (ad, soyad, TC)
    var contactDataConsent: Bool       // İletişim verisi (tel, e-posta)
    var healthDataConsent: Bool        // Sağlık verisi (tanı, ilaç, reçete)

    // Rıza metni versiyonu — politika güncellenince sürümü artır
    let consentVersion: String

    init(
        userId: String,
        identityConsent: Bool,
        contactConsent: Bool,
        healthConsent: Bool
    ) {
        self.id = UUID()
        self.userId = userId
        self.timestamp = Date()
        self.ipAddress = nil // sunucu tarafında doldurulabilir
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        self.deviceModel = UIDevice.current.model
        self.osVersion = UIDevice.current.systemVersion
        self.identityDataConsent = identityConsent
        self.contactDataConsent = contactConsent
        self.healthDataConsent = healthConsent
        self.consentVersion = ConsentConfig.currentVersion
    }
}

enum ConsentConfig {
    static let currentVersion = "1.0.0"
    static let privacyPolicyURL = URL(string: "https://indigo-egret-2c6.notion.site/Privacy-Policy-32101f2ea2468070a5d2eb6284a292ae")!
    static let termsURL = URL(string: "https://indigo-egret-2c6.notion.site/Terms-of-Use-32101f2ea246801fa1f6e03d33130420?pvs=73")!
    static let kvkkURL = URL(string: "https://indigo-egret-2c6.notion.site/KVKK-Disclosure-Statement-32101f2ea24680839a2ddf82dcdce6c0?pvs=73")!
}

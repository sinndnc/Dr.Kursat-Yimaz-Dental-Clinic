import Foundation

/// Kullanıcının verdiği rızaları Keychain'e kaydeder ve sorgular.
final class ConsentManager {

    static let shared = ConsentManager()
    private init() {}

    private let keychainKey = "kvkk_consent_record"

    // MARK: - Kaydet
    /// Rızayı Keychain'e şifreli biçimde kaydeder.
    func saveConsent(_ record: ConsentRecord) {
        do {
            let data = try JSONEncoder().encode(record)
            let query: [String: Any] = [
                kSecClass as String:       kSecClassGenericPassword,
                kSecAttrAccount as String: keychainKey,
                kSecValueData as String:   data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            // Varsa güncelle, yoksa ekle
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("⚠️ Rıza kaydedilemedi: \(status)")
            } else {
                print("✅ Rıza başarıyla kaydedildi — \(record.timestamp)")
                // TODO: Aynı kaydı backend API'ye de gönderin (ispat için)
                // ConsentAPIService.shared.upload(record)
            }
        } catch {
            print("⚠️ JSON encode hatası: \(error)")
        }
    }

    // MARK: - Oku
    func loadConsent() -> ConsentRecord? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return try? JSONDecoder().decode(ConsentRecord.self, from: data)
    }

    // MARK: - Rıza Verildi mi?
    var hasValidConsent: Bool {
        guard let record = loadConsent() else { return false }
        // Politika versiyonu değiştiyse eski rızayı geçersiz say
        return record.consentVersion == ConsentConfig.currentVersion
    }

    var hasHealthConsent: Bool {
        return loadConsent()?.healthDataConsent == true
    }

    // MARK: - Rızayı Geri Çek (KVKK Madde 7)
    func revokeConsent() {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        SecItemDelete(query as CFDictionary)
        print("🗑️ Rıza geri çekildi.")
        // TODO: Backend'e de silme isteği gönderin
    }
}

//
//  AuthError.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//
import Foundation

enum AuthError: LocalizedError {
    case signInFailed(String)
    case registrationFailed(String)
    case signOutFailed(String)
    case passwordResetFailed(String)
    case userNotFound
    case patientProfileMissing
    case emailNotVerified
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .signInFailed(let msg):        return "Giriş başarısız: \(msg)"
        case .registrationFailed(let msg):  return "Kayıt başarısız: \(msg)"
        case .signOutFailed(let msg):       return "Çıkış başarısız: \(msg)"
        case .passwordResetFailed(let msg): return "Şifre sıfırlama başarısız: \(msg)"
        case .userNotFound:                 return "Kullanıcı bulunamadı."
        case .patientProfileMissing:        return "Hasta profili bulunamadı. Lütfen tekrar kayıt olun."
        case .emailNotVerified:             return "E-posta adresiniz doğrulanmamış. Lütfen gelen kutunuzu kontrol edin."
        case .unknown(let e):               return e.localizedDescription
        }
    }
}

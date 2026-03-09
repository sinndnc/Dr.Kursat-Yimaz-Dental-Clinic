//
//  AppDIConfiguration.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//
import FirebaseAuth
import FirebaseFirestore

class AppDIConfiguration {
    
    static let shared = AppDIConfiguration()
    
    static func configure() {
        let container = DIContainer.shared
        
        container.register(Firestore.self, scope: .singleton) { _ in
            Firestore.firestore()
        }
        container.register(Auth.self, scope: .singleton) { _ in
            Auth.auth()
        }
        
        container.register(AuthServiceProtocol.self, scope: .singleton) { c in
            AuthService(
                db:   c.resolve(Firestore.self),
                auth: c.resolve(Auth.self)
            )
        }
        
        container.register(FirestoreServiceProtocol.self, scope: .singleton) { c in
            FirestoreService(firestore: c.resolve(Firestore.self))
        }
    }
    
}

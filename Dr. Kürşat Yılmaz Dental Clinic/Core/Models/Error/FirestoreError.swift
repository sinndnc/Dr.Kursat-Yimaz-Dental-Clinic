//
//  FirestoreError.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation

enum FirestoreError: LocalizedError {
    case documentNotFound(String)
    case encodingFailed(Error)
    case decodingFailed(Error)
    case firestoreError(Error)
    case missingId

    var errorDescription: String? {
        switch self {
        case .documentNotFound(let id):  return "Document not found: \(id)"
        case .encodingFailed(let e):     return "Encoding failed: \(e.localizedDescription)"
        case .decodingFailed(let e):     return "Decoding failed: \(e.localizedDescription)"
        case .firestoreError(let e):     return "Firestore error: \(e.localizedDescription)"
        case .missingId:                 return "Document ID is missing."
        }
    }
}

//
//  FirestoreError.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation

enum FirestoreError: LocalizedError {
    case documentNotFound(id: String)
    case encodingFailed(underlying: Error)
    case decodingFailed(underlying: Error)
    case networkError(underlying: Error)
    case permissionDenied
    case unknown(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .documentNotFound(let id):
            return "Document with ID '\(id)' not found."
        case .encodingFailed(let error):
            return "Failed to encode document: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode document: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .permissionDenied:
            return "Permission denied. Check Firestore security rules."
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

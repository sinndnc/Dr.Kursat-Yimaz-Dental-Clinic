//
//  SupabaseStorageService.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/11/26.
//

import Foundation
import Storage
import UIKit
import Supabase

enum StorageBucket: String {
    case doctors    = "doctors"
    case clinics    = "clinics"
    case patients   = "patients"
    case procedures = "procedures"
}

enum StorageError: LocalizedError {
    case imageConversionFailed
    case uploadFailed(String)
    case deleteFailed(String)
    case urlGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:    return "Görsel dönüştürme başarısız"
        case .uploadFailed(let msg):    return "Yükleme hatası: \(msg)"
        case .deleteFailed(let msg):    return "Silme hatası: \(msg)"
        case .urlGenerationFailed:      return "URL oluşturulamadı"
        }
    }
}

protocol SupabaseStorageServiceProtocol{
    func uploadImage(_ image: UIImage,bucket: StorageBucket,folder: String,fileName: String?,quality: CGFloat) async throws -> String
    func uploadVideo(data: Data,bucket: StorageBucket,folder: String,fileName: String?) async throws -> String
    func getPublicURL(bucket: StorageBucket, path: String) -> URL?
    func getSignedURL(bucket: StorageBucket,path: String,expiresIn: Int) async throws -> URL
    func deleteFile(bucket: StorageBucket, path: String) async throws
    func listFiles(bucket: StorageBucket, folder: String) async throws -> [FileObject]
    func uploadProfilePhoto(patientID: String, image: UIImage) async throws -> String
}

actor SupabaseStorageService : SupabaseStorageServiceProtocol {
    private let baseURL: URL
    private let storage: SupabaseStorageClient
    
    init() {
        self.storage = SupabaseConflict.shared.client.storage
        self.baseURL = URL(string:SupabaseConflict.shared.baseURL)!
    }
    
    nonisolated func doctorPhotoURL(doctorId: String, index: Int = 0) -> URL? {
        let path = "\(doctorId)/photo_\(index).jpg"
        return getPublicURL(bucket: .doctors, path: path)
    }
    
    /// Tüm fotoğrafları dene, bulunanları döndür  (opsiyonel)
    func doctorPhotoURLs(doctorId: String, maxCount: Int = 5) async -> [URL] {
        var urls: [URL] = []
        for i in 0..<maxCount {
            let path = "\(doctorId)/photo_\(i).jpg"
            if let url = getPublicURL(bucket: .doctors, path: path) {
                urls.append(url)
            }
        }
        return urls
    }
    
    func profilePhotoURL(patientID: String, index: Int = 0) async throws -> URL? {
        let path = "\(patientID)/photo_\(index).jpg"
        return try await getSignedURL(bucket: .patients, path: path)
    }
    
    func uploadProfilePhoto(patientID: String, image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.imageConversionFailed
        }
        let path = "\(patientID)/photo_0.jpg"
        try await storage
            .from(StorageBucket.patients.rawValue)
            .upload(path, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
        return path
    }
    
    func deleteProfilePhoto(patientID: String) async throws {
        try await storage
            .from(StorageBucket.patients.rawValue)
            .remove(paths: ["\(patientID)/photo_0.jpg"])
    }
    
    func uploadImage(
        _ image: UIImage,
        bucket: StorageBucket,
        folder: String,
        fileName: String? = nil,
        quality: CGFloat = 0.8
    ) async throws -> String {
        
        guard let imageData = image.jpegData(compressionQuality: quality) else {
            throw StorageError.imageConversionFailed
        }
        
        let name = fileName ?? "\(UUID().uuidString).jpg"
        let path = "\(folder)/\(name)"
        
        try await storage
            .from(bucket.rawValue)
            .upload(
                path,
                data: imageData,
                options: FileOptions(contentType: "image/jpeg", upsert: true)
            )
        
        return path
    }
    
    // MARK: - Upload Video
    func uploadVideo(
        data: Data,
        bucket: StorageBucket,
        folder: String,
        fileName: String? = nil
    ) async throws -> String {
        
        let name = fileName ?? "\(UUID().uuidString).mp4"
        let path = "\(folder)/\(name)"
        
        try await storage
            .from(bucket.rawValue)
            .upload(
                path,
                data: data,
                options: FileOptions(contentType: "video/mp4", upsert: true)
            )
        
        return path
    }
    
    // MARK: - Get Public URL
    nonisolated func getPublicURL(bucket: StorageBucket, path: String) -> URL? {
        return URL(string: "\(baseURL)/\(bucket.rawValue)/\(path)")
    }
    
    func getSignedURL(
        bucket: StorageBucket,
        path: String,
        expiresIn: Int = 3600
    ) async throws -> URL {
        let response = try await storage
            .from(bucket.rawValue)
            .createSignedURL(path: path, expiresIn: expiresIn)
        
        return response
    }
    
    // MARK: - Delete File
    func deleteFile(bucket: StorageBucket, path: String) async throws {
        try await storage
            .from(bucket.rawValue)
            .remove(paths: [path])
    }
    
    // MARK: - List Files
    func listFiles(bucket: StorageBucket, folder: String) async throws -> [FileObject] {
        return try await storage
            .from(bucket.rawValue)
            .list(path: folder)
    }
}

import Foundation
import FirebaseFirestore
import Combine


typealias FirestoreID = String
typealias FirestoreCompletion<T> = Result<T, FirestoreError>

protocol FirestoreDocument: Codable, Identifiable, Sendable where ID == FirestoreID {
    
    static var collectionPath: String { get }
    
    nonisolated var id: FirestoreID { get set }
}


struct FirestoreQuery {
    public let field: String
    public let op: QueryOperator
    public let value: Any

    public enum QueryOperator {
        case isEqualTo
        case isNotEqualTo
        case isGreaterThan
        case isGreaterThanOrEqualTo
        case isLessThan
        case isLessThanOrEqualTo
        case arrayContains
        case `in`
    }

    public init(field: String, op: QueryOperator, value: Any) {
        self.field = field
        self.op = op
        self.value = value
    }
}


struct FirestorePage<T: FirestoreDocument> {
    public let items: [T]
    public let lastSnapshot: DocumentSnapshot?
    public var hasMore: Bool { lastSnapshot != nil && !items.isEmpty }
}


/// Firestore CRUD işlemlerinin tamamını kapsayan generic repository protokolü.
protocol FirestoreRepositoryProtocol<Model> {
    associatedtype Model: FirestoreDocument
    
    // MARK: Create / Update
    func create(_ model: Model) async throws -> Model
    func set(_ model: Model) async throws
    func update(id: FirestoreID, fields: [String: Any]) async throws
    
    // MARK: Read
    func fetch(id: FirestoreID) async throws -> Model
    func fetchAll() async throws -> [Model]
    func fetchPage(limit: Int, after cursor: DocumentSnapshot?) async throws -> FirestorePage<Model>
    func query(_ queries: [FirestoreQuery], orderBy field: String?, descending: Bool, limit: Int?) async throws -> [Model]
    
    // MARK: Delete
    func delete(id: FirestoreID) async throws
    
    // MARK: Realtime
    func observe(id: FirestoreID) -> AnyPublisher<Model, FirestoreError>
    func observeAll() -> AnyPublisher<[Model], FirestoreError>
}


/// `FirestoreRepositoryProtocol`'ün production-ready implementasyonu.
/// Her servis bu sınıftan miras alarak koleksiyona özel repository oluşturabilir.
class BaseFirestoreRepository<Model: FirestoreDocument>: FirestoreRepositoryProtocol {
    
    
    let db: Firestore
    let collection: CollectionReference
    private var listeners: [ListenerRegistration] = []
    
    init(db: Firestore = Firestore.firestore()) {
        self.db = db
        self.collection = db.collection(Model.collectionPath)
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    
    /// Yeni doküman oluşturur. ID yoksa Firestore otomatik üretir.
    @discardableResult
    func create(_ model: Model) async throws -> Model {
        var mutable = model
        let docRef = mutable.id.isEmpty ? collection.document() : collection.document(mutable.id)
        mutable.id = docRef.documentID
        try await encode(mutable, into: docRef)
        return mutable
    }
    
    /// Var olan veya yeni dokümanı tamamen yazar (merge: false).
    func set(_ model: Model) async throws {
        let docRef = collection.document(model.id)
        try await encode(model, into: docRef)
    }
    
    /// Belirli alanları atomik olarak günceller.
    func update(id: FirestoreID, fields: [String: Any]) async throws {
        do {
            try await collection.document(id).updateData(fields)
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    
    func fetch(id: FirestoreID) async throws -> Model {
        do {
            let snapshot = try await collection.document(id).getDocument()
            guard snapshot.exists else {
                throw FirestoreError.documentNotFound(id: id)
            }
            return try decode(snapshot)
        } catch let error as FirestoreError {
            throw error
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func fetchAll() async throws -> [Model] {
        do {
            let snapshot = try await collection.getDocuments()
            return try snapshot.documents.map { try decode($0) }
        } catch let error as FirestoreError {
            throw error
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func fetchPage(limit: Int, after cursor: DocumentSnapshot? = nil) async throws -> FirestorePage<Model> {
        do {
            var query: Query = collection.limit(to: limit)
            if let cursor { query = query.start(afterDocument: cursor) }
            let snapshot = try await query.getDocuments()
            let items = try snapshot.documents.map { try decode($0) }
            let lastSnapshot = snapshot.documents.count == limit ? snapshot.documents.last : nil
            return FirestorePage(items: items, lastSnapshot: lastSnapshot)
        } catch let error as FirestoreError {
            throw error
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func query(
        _ queries: [FirestoreQuery],
        orderBy field: String? = nil,
        descending: Bool = false,
        limit: Int? = nil
    ) async throws -> [Model] {
        do {
            var ref: Query = collection
            for q in queries { ref = apply(q, to: ref) }
            if let field { ref = ref.order(by: field, descending: descending) }
            if let limit { ref = ref.limit(to: limit) }
            let snapshot = try await ref.getDocuments()
            return try snapshot.documents.map { try decode($0) }
        } catch let error as FirestoreError {
            throw error
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    
    func delete(id: FirestoreID) async throws {
        do {
            try await collection.document(id).delete()
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    
    func observe(id: FirestoreID) -> AnyPublisher<Model, FirestoreError> {
        let subject = PassthroughSubject<Model, FirestoreError>()
        let listener = collection.document(id).addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error {
                subject.send(completion: .failure(self.mapFirestoreError(error)))
                return
            }
            guard let snapshot, snapshot.exists else {
                subject.send(completion: .failure(.documentNotFound(id: id)))
                return
            }
            do {
                let model = try self.decode(snapshot)
                subject.send(model)
            } catch {
                subject.send(completion: .failure(error as? FirestoreError ?? .unknown(underlying: error)))
            }
        }
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func observeAll() -> AnyPublisher<[Model], FirestoreError> {
        let subject = PassthroughSubject<[Model], FirestoreError>()
        let listener = collection.addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error {
                subject.send(completion: .failure(self.mapFirestoreError(error)))
                return
            }
            guard let snapshot else { return }
            do {
                let models = try snapshot.documents.map { try self.decode($0) }
                subject.send(models)
            } catch {
                subject.send(completion: .failure(error as? FirestoreError ?? .unknown(underlying: error)))
            }
        }
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    
    /// Birden fazla modeli tek seferde yazar (atomic batch write).
    public func batchCreate(_ models: [Model]) async throws {
        let batch = db.batch()
        try models.forEach { model in
            let docRef = model.id.isEmpty ? collection.document() : collection.document(model.id)
            let data = try Firestore.Encoder().encode(model)
            batch.setData(data, forDocument: docRef)
        }
        do {
            try await batch.commit()
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    public func batchDelete(ids: [FirestoreID]) async throws {
        let batch = db.batch()
        ids.forEach { batch.deleteDocument(collection.document($0)) }
        do {
            try await batch.commit()
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    
    private func encode(_ model: Model, into ref: DocumentReference) async throws {
        do {
            let data = try Firestore.Encoder().encode(model)
            try await ref.setData(data)
        } catch let error as FirestoreError {
            throw error
        } catch {
            throw FirestoreError.encodingFailed(underlying: error)
        }
    }
    
    private func decode(_ snapshot: DocumentSnapshot) throws -> Model {
        do {
            var model = try snapshot.data(as: Model.self)
            model.id = snapshot.documentID
            return model
        } catch {
            throw FirestoreError.decodingFailed(underlying: error)
        }
    }
    
    private func mapFirestoreError(_ error: Error) -> FirestoreError {
        let nsError = error as NSError
        return .unknown(underlying: error)
    }
    
    private func apply(_ query: FirestoreQuery, to ref: Query) -> Query {
        switch query.op {
        case .isEqualTo:            return ref.whereField(query.field, isEqualTo: query.value)
        case .isNotEqualTo:         return ref.whereField(query.field, isNotEqualTo: query.value)
        case .isGreaterThan:        return ref.whereField(query.field, isGreaterThan: query.value)
        case .isGreaterThanOrEqualTo: return ref.whereField(query.field, isGreaterThanOrEqualTo: query.value)
        case .isLessThan:           return ref.whereField(query.field, isLessThan: query.value)
        case .isLessThanOrEqualTo:  return ref.whereField(query.field, isLessThanOrEqualTo: query.value)
        case .arrayContains:        return ref.whereField(query.field, arrayContains: query.value)
        case .in:
            guard let arr = query.value as? [Any] else { return ref }
            return ref.whereField(query.field, in: arr)
        }
    }
}

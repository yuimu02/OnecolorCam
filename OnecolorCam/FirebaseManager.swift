//
//  FirebaseManager.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/08/27.
//

import FirebaseFirestore
import FirebaseStorage
import ColorExtensions

extension String: @retroactive LocalizedError {
    public var errorDescription: String? {
        self
    }
}

enum FirebaseManager {

    private static let db = Firestore.firestore()
    private static let storage = Storage.storage().reference()

    static func sendImage(image: UIImage, folderName: String) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            throw "imagedata error"
        }
        let fileName = UUID().uuidString + ".jpg"
        let imageRef = storage.child("\(folderName)/\(fileName)")
        let _ = try await imageRef.putDataAsync(imageData)
        let downloadUrl = try await imageRef.downloadURL()
        return downloadUrl
    }

    static func addItem(item: IMagepost, uid: String) throws {
        print(uid)
//        if isPublic == false{
            try db.collection("users").document(uid).collection("posts").addDocument(from: item)
//        } else {
//            try db.collection("publicPhotos").addDocument(from: item)
//        }
    }

    static func deleteItem(id: String, uid: String) throws {
        try db.collection("users").document(uid).collection("posts").document(id).delete()
    }

    static func updateItem(with item: IMagepost, uid: String) throws {
        try db.collection("users").document(uid).collection("posts").document(item.id!).setData(from: item)
    }

    static func getItem(id: String, uid: String) async throws -> IMagepost {
        return try await db.collection("users").document(uid).collection("posts").document(id).getDocument(as: IMagepost.self)
    }

    static func getAllMyItems(uid: String) async throws -> [IMagepost] {
        return try await db.collection("users").document(uid).collection("posts").getDocuments().documents.map { try $0.data(as: IMagepost.self) }
    }
    
    static func getAllPublicItems() async throws -> [IMagepost] {
        let snap = try await db.collectionGroup("posts").getDocuments()
        return try snap.documents
            .map { try $0.data(as: IMagepost.self) }
            .filter { $0.isPublic == true }
            .sorted { $0.created > $1.created }
    }
//    static func getAllPublicItems() async throws -> [IMagepost] {
//        let snap = try await db.collectionGroup("posts")
//            .whereField("isPublic", isEqualTo: true)   // 公開のみ
//            .order(by: "created", descending: true)   // 新しい順
//            .getDocuments()
//
//        return try snap.documents.map { try $0.data(as: IMagepost.self) }
//    }
    static func getAllMyPublicItems(uid: String) async throws -> [IMagepost] {
        let snap = try await db.collection("users")
            .document(uid)
            .collection("posts")
            .whereField("isPublic", isEqualTo: true)  // 公開のみ
            .order(by: "created", descending: true)   // 新しい順
            .getDocuments()
        
        return try snap.documents.map { try $0.data(as: IMagepost.self) }
    }
    
    static func addFriend(uid: String, friendUid: String) async throws {
        try await db.collection("users").document(uid).updateData([
            "friends": FieldValue.arrayUnion([friendUid])
        ])
    }
}

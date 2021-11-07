//
//  StorageManeger.swift
//  Messenger
//
//  Created by administrator on 06/11/2021.
//

import Foundation
import FirebaseStorage
import SwiftUI

final class StorageManager {
    
    static let shared = StorageManager()  // static property so we can get an instance of this storage manager
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        // "child("String")" the path of the image, images/zahra-gmail-com_profile_picture.png , "images" is the name of the folder in firebase, it can be named anything 
        storage.child("image/\(fileName)").putData(data, metadata: nil) {metadata, error in
            guard error == nil else {
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))  // the parameter of "failure" is "Error"
                return
            }
            self.storage.child("image/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDoemloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned \(urlString)")
                completion(.success(urlString))
            }
        }
        
    }
    public func downloadUrl(for path: String, completion: @escaping(Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDoemloadUrl))
                return
            }
            completion(.success(url))
        })
    }
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDoemloadUrl
    }
}

//
//  DatabaseManager.swift
//  Messenger
//
//  Created by administrator on 01/11/2021.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {  // "final" means it can't be subclassed
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference() // creating database reference
    
    static func safeEmail(emailAddress: String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail    }
}
// MARK: - account management
extension DatabaseManager {
    // Have a completion handler because the function to get data out of the database is                                                                                       asynchrounous so we need a completion block
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {    // will return true if the user email exist
       
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        // firebase allows to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in    //Observing a single event (query the database once) to not have different users with same the email
            guard snapshot.value as? String != nil else {   // snapshot has a "value" property that can be optional if it doesn't exist
                completion(false)  // String == nil, go and create the account
                return
            }
            completion(true) // String != nil, the email aleardy exist 
        }
        
    }
    
    public func insertUser(with user: ChatAppUser, completion: @escaping ((Bool) -> Void)) {
        let database = Database.database().reference()
        database.child(user.safeEmail).setValue(["first_name": user.firstName, "last_name": user.lastName]) {error, _ in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            // To add the user into an array of users, the array contain the "name" and "email"
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {   // usersCollection is an array of dictionary
                   // Appending the user to the users array
                    let newUser = ["name": user.firstName + " " + user.lastName, // To have the full name of the user
                                   "email": user.safeEmail]
                    usersCollection.append(newUser)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    completion(true)
                        
                    })
                }
                else {  // creating the users array if it doesn't exist. That is for the very first user
                    let newCollection: [[String: String]] = [
                        ["name": user.firstName + " " + user.lastName,
                         "email": user.safeEmail]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    completion(true)
                        
                    })
                }
            })
        }
        // user exist?
        database.child(user.safeEmail).observeSingleEvent(of: .value, with: { snapshot in  // Calling useExists function so that i 
            completion(true)
        }) { error in
            print(error.localizedDescription)
            completion(false)
        }
    }
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}
struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    var profilePictureFileName: String {
        //zahra-gmail-com_profile_picture.png <---  the structure of the image url
        return "\(safeEmail)_profile_picture.png"
    }
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
        
    }
}
    


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
           completion(true)
        }
        // user exist?
        database.child(user.safeEmail).observeSingleEvent(of: .value, with: { snapshot in  // Calling useExists function so that i 
            completion(true)
        }) { error in
            print(error.localizedDescription)
            completion(false)
        }
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
    


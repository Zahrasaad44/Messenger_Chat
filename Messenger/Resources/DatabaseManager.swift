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
// MARK: - Sending Messages / Conversations

extension DatabaseManager {
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let cachedSafeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(cachedSafeEmail)")
            ref.observeSingleEvent(of: .value, with: {snapshot in
                guard var userNode = snapshot.value as? [String: Any]  // Looking for the user (email)
                else {  // in case of the user isn't found
                    completion(false)
                    print("user is not found")
                    return
                }  // Once finding the user ..
                
                let messageDate = firstMessage.sentDate
                let dateString = ChatViewController.dateFormatter.string(from: messageDate)  // To convert the date from Date to String type
                
                var message = ""
                
                switch firstMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(_):
                    break
                case .video(_):
                    break
                case .location(_):
                    break
                case .emoji(_):
                    break
                case .audio(_):
                    break
                case .contact(_):
                    break
                case .linkPreview(_):
                    break
                case .custom(_):
                    break
                }
                
                let conversationId = "conversation_\(firstMessage.messageId)"
                
                let newConversationData: [String: Any] = [
                    "conversation_id": conversationId,
                    "other_user_email": otherUserEmail,
                    "name": name,
                    "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                    ]
                ]
                
                if var conversations = userNode["conversations"] as? [[String: Any]] { // "conversations" saved as an array of dictionary
                    
                    conversations.append(newConversationData)  // as the "conversations" exist (created in "if" line), we need to append "newConversationData"
                    
                    userNode["conversations"] = conversations // To update the "users" node in the firebase with the new conversations after appending
                    
                    ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        //Note to me: Keep in mind that this function is called inside "createNewConversation" function
                        self?.finishedCreatingConversation(conversationID: conversationId, name: name, firstMessage: firstMessage, completion: completion)
                    })

                }
                else {  // "else" in case the conversation array does not exist, it will create it
                    userNode["conversations"] = [newConversationData]
                    
                    ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        self?.finishedCreatingConversation(conversationID: conversationId, name: name, firstMessage: firstMessage, completion: completion)
                    })
                }
            
        })
    }
    
    private func finishedCreatingConversation(conversationID: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
      /*  {
            "id": String,
            "type": text, photo, video,
            "content": String,
            "date": Date(),
            "sender_email": String,
            "isRead": true/false
        }  */
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
           completion(false)
            return
        }
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId, //It is taken from the parameters of the function
            "type": firstMessage.kind.messageKindString,
            "name": name,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
         print("adding convo \(conversationID)")
        // Creating a child(node) of "conversationID" in the firebase
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    
    
    
    /// Fetches and returns all conversations for the user with passed email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {  //"completion" to check if the message is sent successfully
        
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
    


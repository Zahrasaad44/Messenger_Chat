//
//  ChatViewController.swift
//  Messenger
//
//  Created by administrator on 05/11/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind   // text, photo, video, location, emoji
    
}

extension MessageKind {
    var messageKindString: String {
        switch self {    // "switch self" because "MessageKind" itself is an enum
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    
    public var senderId: String
    public var displayName: String
    public var photoURL: String
    
}

class ChatViewController: MessagesViewController{

    public var isNewConversation = false
    public var otherUserEmail: String
    private var messages = [Message]()
    private var theSender: Sender? {  // it is optional because if the email doesn't exist in the cache of the UserDefaults it won't return a sender
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return nil}
        
       return Sender(senderId: email, displayName: "zahra", photoURL: "")
    }
    
    init(with email: String) {     // A constructor 
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
       

        view.backgroundColor = .gray
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()   // To show the kwyboard whenever opening a chat
        
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = theSender {
            return sender
        }
        fatalError("The Sender is nil, email should be cached")
        return Sender(senderId: "45", displayName: "", photoURL: "") // dummy sender in case the email isn't cached
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {   // handle the action when pressing "send" btn on the keyboard
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, // To not allow an empty message
              let theSender = self.theSender, let messageId = createMessageId() else {
                  return
              }
        
        print("Sending: \(text)")
        
        ///  Sending Messages
    
        if isNewConversation {
            let message = Message(sender: theSender, messageId: messageId, sentDate: Date(), kind: .text(text)) // "text" is the one that is in "inputBar" function
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: {/*[weak self]*/ sucess in
                if sucess {
                    print("message sent")
                } else {
                    print("failed to send")
                }
            })
        } else {
            
        }
        
        
    }
    
    private func createMessageId() -> String? {
        // To create the id, we need the date of the message, the other user email (otherUserEmail), senderEmail and, just in case, a randonInt
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newMessageIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("created message id: newMessageIdentifier")
        return newMessageIdentifier
        
    }
}

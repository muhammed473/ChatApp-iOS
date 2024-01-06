//
//  ChatViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 23.12.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView // Geliştiricilere sohbet ekranlarını hızlı bir şekilde oluşturma ve özelleştirme imkanı sağlar.

/* Şimdi 2 struct(yapı) kurucaz.Bunlar :
 
   1) İlk yapımız MESAJI TEMSİL EDECEK.
   2) Diğer yapımız ise GÖNDERENİ TEMSİL EDECEK.
 
*/

struct Message: MessageType {
    
    public var sender: MessageKit.SenderType // Gönderen türü.Yani her mesaj için bir gönderen var.
    
    public var messageId: String // Mesaj id'si
    
    public var sentDate: Date // Gönderilme Tarihi
    
    public var kind: MessageKit.MessageKind // Mesaj türü
    
 } // MessageType : Mesajı temsil eder. ( Mesaj tipi ) , Protocoldür.

extension MessageKind {
    var messageKindString : String {
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
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

struct Sender : SenderType{ // SenderType : Göndereni temsil eder.(Gönderenin tipi ), Protocoldür.
    
    public var photoURL : String // Bunu  manuel olarak BİZ  yazık.
    
    public var senderId: String // Gönderenin id'si(Kimliği)
    
    public var displayName: String // Gönderenin Ekran adı
    
} // SenderType : Göndereni temsil eder. ( Gönderici tipi), Protocoldür.


class ChatViewController: MessagesViewController { // MessagesViewController SCRİPTİNDEN MİRAS ALDIK DİKKAT ET !!!

    public static  let dateFormatter : DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        return formatter
    }()
    
    public let otherUserEmail : String
    public var isNewConversation = false // Yeni bir konuşma olup olmadığını belirlememiz için oluşturduk.
   
  
    private var messages = [Message]()
    
    private var selfSender : Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email")  as? String else {
            return nil // Bir eposta önbelleğimizde ve kullanıcı varsayılanlarında mevcut değilse göndereni DÖNDÜRMEYECEĞİZ.
        }
        
      return  Sender(photoURL: "",
               senderId: email,
               displayName: "Mika Dursun")
    }
    
     init(with email : String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        
        view.backgroundColor = .red
        
       // messagesCollectionView : Mesaj toplama görünümüni bize sağlar.
        
        messagesCollectionView.messagesDataSource = self      // Mesaj veri kaynağı
        messagesCollectionView.messagesLayoutDelegate = self  // Mesaj düzen temsilcisi
        messagesCollectionView.messagesDisplayDelegate = self // Mesaj görüntüleme temsilcisi
        messageInputBar.delegate = self
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageInputBar.inputTextView.becomeFirstResponder() 
    }
    
}


extension ChatViewController: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    
    func currentSender() -> MessageKit.SenderType { // Burda İlk olarak mevcut mesaj gönderenin kim olduğunu anlıyoruz.
        
        if let sender = selfSender{
            return sender
        }
        fatalError("Self sender(Gönderen) boş.Eposta ön belleğe alınmalıdır.")
        return Sender(photoURL: "", senderId: "123", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}


extension ChatViewController:InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) { // Gönder düğmesine bastı mı ? Bu metodun içindeki text : Bizim yazdığımız text'i temsil eder.
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, // Kullanıcının sadece boşluk içeren bir mesaj göndermesine  izin vermedik ve dedikki MESAJ BOŞ DEĞİLSE ve diğer kıstaslar..
               let selfSender = self.selfSender,
               let messageId = createMessageId()  else {
               return
        }
        
        print("Gönderilen mesaj : \(text)")
        
        // Mesaj gönder.
        
        if self.isNewConversation {
            
            let message  = Message(sender:selfSender , messageId: messageId, sentDate: Date(), kind: MessageKind.text(text))
            DatabaseManager2.shared.createNewConversation(with: self.otherUserEmail, firstMessage: message, completion:
            {
              (success) in
                
                if success {
                    print("Mesaj GÖNDERİLDİ.")
                } else {
                    print("Mesaj GÖNDERİLEMEDİ.")
                }
                
            })
            
        }  // Eğer yeni bir konuşmaysa BİRDEN FAZLA VERİTABANI İŞLEMLERİNİ BAĞLANTILI BİR ŞEKİLDE SIRASIYLA ŞİMDİ YAPICAZ :
        
        else {
            
        } // Eğer yeni bir konuşma değilse  Mevcut konuşma verilerine şimdi eklicez :
        
    }
    
    
    private func createMessageId() -> String?{
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager2.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier  = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("Oluşturulan MESAJ KİMLİĞİ : \(newIdentifier)")
        
        return newIdentifier
    } //  Mesaj kimliğinin  ve date,otherUserEmail,senderEmail,randomInt oluşturulması
    
    
}

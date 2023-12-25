//
//  ChatViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 23.12.2023.
//

import UIKit
import MessageKit

/* Şimdi 2 struct(yapı) kurucaz.Bunlar :
 
   1) İlk yapımız MESAJI TEMSİL EDECEK.
   2) Diğer yapımız ise GÖNDERENİ TEMSİL EDECEK.
 
*/

struct Message: MessageType {
    
    var sender: MessageKit.SenderType // Gönderen türü.Yani her mesaj için bir gönderen var.
    
    var messageId: String // Mesaj id'si
    
    var sentDate: Date // Gönderilme Tarihi
    
    var kind: MessageKit.MessageKind // Mesaj türü
    
 } // MessageType : Mesajı temsil eder. ( Mesaj tipi ) , Protocoldür.

struct Sender : SenderType{ // SenderType : Göndereni temsil eder.(Gönderenin tipi ), Protocoldür.
    
    var photoURL : String // Bunu  manuel olarak BİZ  yazık.
    
    var senderId: String // Gönderenin id'si(Kimliği)
    
    var displayName: String // Gönderenin Ekran adı
    
}


class ChatViewController: MessagesViewController { // MessagesViewController SCRİPTİNDEN MİRAS ALDIK DİKKAT ET !!!

  
    private var messages = [Message]()
    
    private let selfSender = Sender(photoURL: "",
                                    senderId: "1",
                                    displayName: "Mika Dursun")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: MessageKind.text("Merhaba Chat uygulamamızın İLK mesajı")))
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: MessageKind.text("Merhaba Chat uygulamamızın İKİNCİ mesajı,Merhaba Chat uygulamamızın İKİNCİ mesajı,Merhaba Chat uygulamamızın İKİNCİ mesajı")))
        
        
        view.backgroundColor = .red
        
       // messagesCollectionView : Mesaj toplama görünümüni bize sağlar.
        
        messagesCollectionView.messagesDataSource = self      // Mesaj veri kaynağı
        messagesCollectionView.messagesLayoutDelegate = self  // Mesaj düzen temsilcisi
        messagesCollectionView.messagesDisplayDelegate = self // Mesaj görüntüleme temsilcisi
    }
    
    
}

extension ChatViewController: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    
    func currentSender() -> MessageKit.SenderType { // Burda İlk olarak mevcut mesaj gönderenin kim olduğunu anlıyoruz.
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

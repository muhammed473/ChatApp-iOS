//
//  DatabaseManager.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager2 {
    
    static let shared = DatabaseManager2()
    
    private let database = Database.database().reference()
    
   /* public func test () { --> ConversationViewController 'a git. [ Database'i ufaktan anlaman için örnek yaptık. ]
          
        database.child("foo").setValue(["something":true])
        
    } */
    
    static func safeEmail(emailAddress:String) -> String {
        
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-") // replacingOccurrences : Olayların değiştirilmesi( Yani syntax'leri değiştirdik.)
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail

    }
    
}

struct ChatAppUser2 {
    
    let firstName : String
    let lastName : String
    let emailAddress : String

    
    var safeEmail : String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-") // replacingOccurrences : Olayların değiştirilmesi( Yani syntax'leri değiştirdik.)
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
   
    var profilePictureFileName : String{
        //mamiankara10-gmail-com_profile-picture.png
        return "\(safeEmail)_profile-picture.png"
    } // Bu yapı"computed property(hesaplanmış özellik)'tir.Her çağrıldığında YENİ değer hesaplamak için bir getter(alıcı) fonksiyonunu kullanır.
    
}


// MY MARK : HESAP YÖNETİMİ

extension DatabaseManager2 {
    
   
    
      /*  YANİ kullanıcının aynı mail adresinde 2inci bir hesap  OLUŞTURMAMASI İÇİN bu metotu yazdık.
          Aynı mail adresinden bir kullanıcı varsa true, yoksa false dönecek. (userExist = Kullanıcı var) */
    public func userExist(with email : String, completion : @escaping ((Bool) -> Void ) ) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-") // replacingOccurrences : Olayların değiştirilmesi( Yani syntax'leri değiştirdik.)
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: DataEventType.value, with: // database içinde tek bir olayı gözlemliyoruz şuan :
        {
          (snapshot) in
            
            guard  snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            print("")
            print("Böyle bir email adresi daha önceden sistemimize kaydedilmiştir.Lütfen farklı bir email adresiyle sistemimize kaydolun.")
            completion(true) // Yani kullanıcı kayıt olurken DAHA ÖNCEDEN KAYDOLDUĞUNU MAİL ADRESİNDEN ANLAMIŞ OLDUK ! ! !
            
            
        })
        
    }
    
    ///  Veri tabanına yeni kullanıcı ekler.
    public func insertUser(with user : ChatAppUser2,completion: @escaping(Bool) -> Void ) {  //   with : Bir anahtar kelime değildir - sadece harici bir parametre tanımlayıcısıdır.
     
        database.child(user.safeEmail).setValue( // Yani veritabanında aynı İSİMLİ MAİL ADRESLERİ OLAMAZ DEMİŞ OLDUK.
        [
            "first_name" : user.firstName,
            "last_name" : user.lastName
        ], withCompletionBlock: {
            
            (error , _ ) in // Burdaki _(Alt Çizgi) veritabanı(database) referansı beklediğini söylüyor ancak biz bunu KULLANMAYACAĞIMIZ için _(Alt Çizgi) koyduk.
            
            guard  error == nil else {
                print("Veritabanına kaydedilme olayı BAŞARISIZ !!")
                completion(false)
                return
            }
            
          
            
            /* Başlangıçta kullanıcı(users) klasörü oluşturulduktan sonra  KLASÖRÜMÜZÜN içinde Eğer HİÇBİR ŞEY KOLEKSİYON(SÖZLÜK,DİZİ) YOKSA KOLEKSİYON OLUŞTURUP
            kullanıcı koleksiyonumuzu(sözlüğümüzü,dizimize) eklicez */ // ŞİMDİ YAPACAĞIMIZ İŞLEMİN AÇIKLAMASI
            
            self.database.child("users").observeSingleEvent(of: .value) { // observeSingleEvent( Tek bir olayı gözlemlemek) : Veriler SADECE 1 KEZ ALINIR VE DAHA SONRA DEĞİŞİKLİKLERE TEPKİ VERMEZ.
                
                (snapshot) in // snapshot : users klasöründeki (?) verileri içerir.
                
                if var usersCollection = snapshot.value as? [[String:String]]{
                    // VAR OLAN Kullanıcı koleksiyonuna(sözlüğümüze,dizimize,usersCollection'a) ekle.
                    let newElement = 
                    [
                        "name" : user.firstName + " " + user.lastName,
                        "email" : user.safeEmail
                    ]
                    
                    usersCollection.append( newElement)
                    
                    self.database.child("users").setValue(usersCollection,withCompletionBlock:  {
                       
                        (error,_) in
                        
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
                
                else { // Koleksiyonu(Diziyi,Sözlüğü) oluştur.
                    
                    let newCollection : [[String:String]] =
                    [
                        [
                           "name" : user.firstName + "" + user.lastName,
                           "email" : user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection,withCompletionBlock:  {
                       
                        (error,_) in
                        
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
                
            } // Database'de users klasöründe tek bir olayı gözlemliyoruz.
            
           
            
        })
        
    }
    
    
    public func getAllUsers(completion : @escaping ( Result<[[String:String]],Error>) -> Void ) {
        
        database.child("users").observeSingleEvent(of: .value,with: {
            (snapshot) in
            
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
        
    }
    
    
    public enum DatabaseErrors : Error {
        
        case failedToFetch
        
    }
    
}


// MY MARK : MESAJ GÖNDERME İŞLEMİ VE KONUŞMALAR

extension DatabaseManager2{
    
    /*
     
     YAPACAĞIMIZ ANA MANTIK OLARAK 2 İŞLEM VARDIR.BUNLAR :
     
       1) Bir sohbeti kullanıcıların konuşma (conversation) koleksiyonuna koymak.
       2) Sonra 2 kez yeni girişi oluşturduğumuzda içindeki tüm mesajlarla bir rota sohbeti oluşturmak.

 1)  conversation =>
      [
           [
     
             "conversation_id veya sadece id" : "abcdef"
             "other_user_email " :
             "latest_messages(Son mesajlar)"  : =>
              [
                 "date" : Date(),
                 "latest_message" : "Son mesaj..",
                 "is_read" : true/false
              ]
     
           ],
     
      ]
     
 2)  "abcdef"
     {
     
        " messages " :
         [
           "id" : String,
           "type" : text,photo,video,
           "content" : String,
           "date" : Date(),
           "sender_email" : String,
           "isRead" : true/false"
     
         ]
     
     }
     
     */ // ÇOK ÖNEMLİ : DATABASE'DE KURACAĞIMIZ İŞLEM MANTIĞININ(ŞEMASI) AÇIKLANMASI
    
    /// Konuşmak istediğimiz diğer kullanıcının epostası ve gönderilen ilk mesajla yeni bir görüşme(konuşma) oluşturmanın bu metotta yapılması
    public func createNewConversation(with otherUserEmail :String,name:String, firstMessage : Message,completion : @escaping(Bool) ->Void) {
        
        // İlk başta  önbellekte   epostam var mı bundan emin olmam lazım.
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager2.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
       
        ref.observeSingleEvent(of: .value, with:
        {
          [weak self]  (snapshot) in
            
            guard var userNode = snapshot.value as? [String:Any] else {
                completion(false)
                print("Kullanıcı bulunamadı.(user not found)")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind{
                
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
            
            let newConversationData : [String:Any] =
              [
                "id" : conversationId,
                "other_user_email" : otherUserEmail,
                "name" : name,
                "latest_message" :
                    [
                        "date" : dateString,
                        "message" : message,
                        "is_read" : false // Varsayılan olarak ilk mesaj okunmaz o yüzden false'dur.
                    ]
              ]
            
            let recipient_ConversationData : [String:Any] = // Alıcı
              [
                "id" : conversationId,
                "other_user_email" : safeEmail,
                "name" : "Self Yani Kendisi",
                "latest_message" :
                    [
                        "date" : dateString,
                        "message" : message,
                        "is_read" : false // Varsayılan olarak ilk mesaj okunmaz o yüzden false'dur.
                    ]
              ]
            
            // Aşağıdaki kodlar ALICI KULLANICININ görüşmesini günceller(ayarlar).
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with:
            {
                
               [weak self]  (snapshot) in
                
                if var conversations = snapshot.value as? [[String:Any]] {
                    // Append
                    conversations.append(recipient_ConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationId)
                }
                else {
                    // Create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_ConversationData])
                }
                
            })
            
            // Aşağıdaki kodlar KONUŞAN KULLANICINI görüşmesini günceller.
            if var conversations = userNode["conversations"] as? [[String:Any]]  {
                
                // Şuan  konuşma dizisi(Conversation) mevcut.Ekleyebilirsin..
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock:
                {
                  [weak self] (error, _ ) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation( name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                })
                
            }// En üstteki ŞEMA'mıza göre yapmaya başladık..
            
            else{ //  // Konuşma dizisi(Conversation) dizisi(düğümü) mevcut değil.OLUŞTUR..
                
                userNode["conversations"] =
                [
                  newConversationData
                ]
             
                ref.setValue(userNode, withCompletionBlock:
                {
                  [weak self] (error, _ ) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation( name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                   
                })
                
            }
            
        })
    }
    
    
    private func finishCreatingConversation(name:String,conversationID:String,firstMessage:Message,completion :@escaping (Bool) -> Void ) {
    
       
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        var message = ""
        
        switch firstMessage.kind{
            
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
        
        guard var myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager2.safeEmail(emailAddress: myEmail)
        
        let collectionMessage : [String:Any] = [
        
            "id" : firstMessage.messageId,
            "type" : firstMessage.kind.messageKindString,
            "content" : message,
            "date" : dateString,
            "sender_email" : currentUserEmail,
            "is_read" : false,
            "name" : name
        ]
         
        
        let value : [String : Any] = [

           "messages" :
            [
             collectionMessage
            ]
            
        ]
        
        print("Görüşme eklendi.Bu da görüşmenin kimliği : \(conversationID)")
        
        database.child("\(conversationID)").setValue(value,withCompletionBlock: {
            
            (error , _ ) in
            
            guard error == nil else {
                completion(false)
                return
            }
             completion(true)
        })
        
 
    } // Görüşme oluşturmayı bitir.
    
    
    /// Kullanıcının epostayla ilettiği tüm konuşmaları getirir ve döndürür.
    public func getAllConversations(for email: String,completion : @escaping(Result<[Conversation],Error>) -> Void) {
    
        // database.child("\(email)/conversations") => Uygulamayı kullanan kişinin maili => conversations Düğümü
        database.child("\(email)/conversations").observe(.value, with:{
           
            (snapshot) in
            
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            /*
              - compactMap() metodu  bir dizi veya koleksiyon üzerinde işlem yapmak için kullanılan bir fonksiyondur.
              - İşlevin dönüş değeri optional bir tür olduğunda kullanışlıdır.
              - Bu metot her eleman için bir kapatma işlevini çağırır ve işlevin NİL OLMAYAN DEĞERLERİNİ BİR DİZİYE
                EKLER.
              - Bu metodun amacı dizi üzerindeki nil değerlerle başa çıkmak yani optionalleri temizlemek içindir.
             */ // .compactMap() metodunun açıklanması(ÇOK ÖNEMLİ)
            
            let conversations : [Conversation] = value.compactMap ({
                
                 (dictionary) in
                
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latest_Message = dictionary["latest_message"] as? [String:Any],
                      let isRead = latest_Message["is_read"] as? Bool,
                      let date = latest_Message["date"] as? String,
                      let message = latest_Message["message"] as? String
                else {
                 return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            
            })
            
            completion(.success(conversations))
            
        })
    
        
    }
    
    /// Belirli bir konuşmaya  ilişkin tüm mesajları döndürür.
    public func getAllMessagesForConversation(with id:String,completion : @escaping (Result<[Message],Error>) ->Void ) {
        
        // database.child("\(email)/conversations") => Uygulamayı kullanan kişinin maili => conversations Düğümü
        database.child("\(id)/messages").observe(.value, with:{
           
            (snapshot) in
            
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
         
            let messages : [Message] = value.compactMap ({
                
                 (dictionary) in
                
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString)
                else {
                    return nil
                }
               
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
              
            })
            
            completion(.success(messages))
            
        })
        
        
    }
    
    /// Bu fonksiyonda hedef konuşmayı belirleyip ve buna   Mesaj göndericez.
    public func sendMessage(to conversation: String,message:Message,completion : (Bool) -> Void){
        
    }
    
}





//
//  ChatViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 23.12.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView // Geliştiricilere sohbet ekranlarını hızlı bir şekilde oluşturma ve özelleştirme imkanı sağlar.
import SDWebImage
import AVFoundation
import AVKit

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

struct Media : MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}


class ChatViewController: MessagesViewController { // MessagesViewController SCRİPTİNDEN MİRAS ALDIK DİKKAT ET !!!

    public static  let dateFormatter : DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        return formatter
    }()
    
    public let otherUserEmail : String
    private let conversationId : String? // Listemizdeki bir konuşmaya tıkladığımızda bunun bir kimliği vardır.
    public var isNewConversation = false // Yeni bir konuşma olup olmadığını belirlememiz için oluşturduk.
   
  
    private var messages = [Message]()
    
    private var selfSender : Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email")  as? String else {
            return nil // Bir eposta önbelleğimizde ve kullanıcı varsayılanlarında mevcut değilse göndereni DÖNDÜRMEYECEĞİZ.
        }
        
        let safeEmail =  DatabaseManager2.safeEmail(emailAddress: email)
        
      return  Sender(photoURL: "",
               senderId: safeEmail,
               displayName: "Ben")
        
    }
    
   
    init(with email : String, id:String?) {
        self.conversationId = id
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
   
    }
    
    
    private func setupInputButton() {
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside{
          [weak self]  (_) in
            self?.presentInputActionSheet()
        } // Butona dokunduğumuzda olmasını istediğimiz işlemleri yaparız.
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
    }
    
    
    private func presentInputActionSheet(){
        
        let actionSheet = UIAlertController(title: "Medya Ekle", message: "Ne eklemek istersin ?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default , handler: {
            
            [weak self] (_) in
            self?.presentPhotoInputActionSheet()
        
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default , handler: {
            
          [weak self]  (_) in
            self?.presentVideoInputActionSheet()
        
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default , handler: {
            
           (_) in
            
        
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil ))
            
            
        present(actionSheet,animated: true)
        
    }
    
    
    private func presentPhotoInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Fotoğraf Ekle", message: "Nereden fotoğraf eklemek istiyorsunuz ?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default , handler: {
            
            [weak self] (_) in
           
            let picker = UIImagePickerController() // picker = Seçici
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true // Secicinin(picker'ın) düzenlemesine izin verildi.
            self?.present(picker, animated: true)
        
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default , handler: {
            
          [weak self]  (_) in
            
            let picker = UIImagePickerController() // picker = Seçici
            picker.sourceType = .photoLibrary
            //picker.mediaTypes = ["public.image"]
            picker.delegate = self
            picker.allowsEditing = true // Secicinin(picker'ın) düzenlemesine izin verildi.
            self?.present(picker, animated: true)
            
        }))
                
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:nil))
            
            
        present(actionSheet,animated: true)
        
    }
    
    
    private func presentVideoInputActionSheet() {
        
        let actionSheet = UIAlertController(title: "Video Ekle", message: "Nereden video eklemek istiyorsunuz ?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default , handler: {
            
            [weak self] (_) in
           
            let picker = UIImagePickerController() // picker = Seçici
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.allowsEditing = true // Secicinin(picker'ın) düzenlemesine izin verildi.
            self?.present(picker, animated: true)
        
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default , handler: {
            
          [weak self]  (_) in
            
            let picker = UIImagePickerController() // picker = Seçici
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"] // SADECE VİDEOLARI SEÇEÇEK ŞEKİLDE SINIRLADIK.
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true // Secicinin(picker'ın) düzenlemesine izin verildi.
            self?.present(picker, animated: true)
            
        }))
                
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:nil))
            
            
        present(actionSheet,animated: true)
        
    }
    
    
    private func listenForMessages(id:String,shoulScrollToBottom:Bool) {
        
        DatabaseManager2.shared.getAllMessagesForConversation(with: id, completion:{
            
          [weak self]  (result) in
            
            switch result {
                
            case  .success(let messages) :
                print("Başarılı bir şekilde mesaj alındı.")
                guard !messages.isEmpty else {
                    return
                }
                
                self?.messages = messages
                
                DispatchQueue.main.async {
                    
                    //  messagesCollectionView.reloadDataAndKeepOffset() = Kullanıcı ESKİ MESAJLARI OKURKEN
                    //  yeni bir mesaj geldiğinde AŞAĞI DOĞRU OTOMATİK OLARAK KAYILMASINI ENGELLER !!!
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shoulScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                    else{
                     
                       
                    }
                    
                    
                }
                                
            case  .failure(let error) :
                print("Mesaj almada başarısız olduk.\(error)")
                
            }
            
        })
                                                                
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageInputBar.inputTextView.becomeFirstResponder() 
        if let conversationId = conversationId {
            listenForMessages(id: conversationId,shoulScrollToBottom : true)
        }
    }
    
}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    } // Resim Secici(Picker) denetleyicisinin İPTAL ETMESİNİ SAĞLAR.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        picker.dismiss(animated: true,completion: nil)
        // Seçtikleri resmi orada çıkarmak istiyoruz :
        guard let messageId = createMessageId(),
        let conversationId = conversationId ,
        let name = self.title,
        let selfSender = self.selfSender else {
            return
        }
        
        if let image = info[.editedImage] as? UIImage,let imageData = image.pngData(){
            
            let fileName =  "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            // 1 ) Resimin yüklenmesinin aşağıda yapılması.
            
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion:
            {
              [weak self]  (result) in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                    
                case  .success(let urlString) :
                    // Şimdi FOTOĞRAF MESAJI GÖNDERMEYE HAZIRIZ..
                    print("FOTOĞRAF MESAJI YÜKLENDİ.")
                   
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus")  else {
                        return
                    }
                    
                    let media = Media(url: url,image: nil ,placeholderImage: placeholder, size: .zero )
                    let message  = Message(sender:selfSender , messageId: messageId, sentDate: Date(), kind: MessageKind.photo(media))
                    
                    DatabaseManager2.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion:
                    {
                       (success) in
                        
                        if success {
                            print("FOTOĞRAF MESAJI GÖNDERİLDİ.")
                        }
                        else{
                            print("FOTOĞRAF MESAJI GÖNDERİLEMEDİ !!!")
                        }
                        
                    })
                    
                case .failure(let error) :
                    print("FOTOĞRAF MESAJI  YÜKLENİRKEN HATA İLE KARŞILAŞTIK.\(error)")
                
                }
                
            })
        } // Fotoğraf göndermek
        
        else if let videoUrl = info[.mediaURL]  as? URL {
          
            let fileName =  "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion:
            {
              [weak self]  (result) in
                
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                    
                case  .success(let urlString) :
                    // Şimdi FOTOĞRAF MESAJI GÖNDERMEYE HAZIRIZ..
                    print("VİDEO MESAJI YÜKLENDİ.")
                   
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus")  else {
                        return
                    }
                    
                    let media = Media(url: url,image: nil ,placeholderImage: placeholder, size: .zero )
                    let message  = Message(sender:selfSender , messageId: messageId, sentDate: Date(), kind: MessageKind.video(media))
                    
                    DatabaseManager2.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion:
                    {
                       (success) in
                        
                        if success {
                            print("VİDEO MESAJI GÖNDERİLDİ.")
                        }
                        else{
                            print("VİDEO MESAJI GÖNDERİLEMEDİ !!!")
                        }
                        
                    })
                    
                case .failure(let error) :
                    print("VİDEO MESAJI  YÜKLENİRKEN HATA İLE KARŞILAŞTIK.\(error)")
                
                }
                
            })
             
            
        } // Video göndermek
        
      
        
        // 2 ) Resim yüklendikten sonra resimi göndericez.
        
    } // Bilgi içeren medyanın(fotograf,video...) toplanmasını bitirilmesidir.
}


extension ChatViewController: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    
    func currentSender() -> MessageKit.SenderType { // Burda İlk olarak mevcut mesaj gönderenin kim olduğunu anlıyoruz.
        
        if let sender = selfSender{
            return sender
        }
        fatalError("Self sender(Gönderen) boş.Eposta ön belleğe alınmalıdır.")
      
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        // MEDYA MESAJLARINDAN RESİM MESAJININ KENDİSİNİ GÖRÜNTÜLER.MESAJIN İNDEKS YOLUNU ve KOLEKSİYON GÖRÜNÜMÜNÜ GÖRÜRÜZ.
        guard let message = message as? Message else {
             return
        }
        
        switch message.kind {
         case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default :
            break
        }
        
    } // Medya Mesajlarından RESİM GÖRÜNÜMÜNÜ YAPILANDIRIR.
    
    
    
}


extension ChatViewController:MessageCellDelegate{
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard  let indexPath = messagesCollectionView.indexPath(for: cell) else{
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
         case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .video(let media):  // GÖNDERİLEN VİDEOYUYU AÇIP İZLEMEMİZİ SAĞLAR.
           guard let videoUrl = media.url else {
               return
           }
       
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc,animated: true)
            
        default :
            break
        }
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
        
        let message  = Message(sender:selfSender , messageId: messageId, sentDate: Date(), kind: MessageKind.text(text))
        
        if self.isNewConversation {
            
            DatabaseManager2.shared.createNewConversation(with: self.otherUserEmail,name: self.title ?? "User", firstMessage: message, completion:
            {
              [weak self] (success) in
                
                if success {
                    print("Mesaj GÖNDERİLDİ.")
                    self?.isNewConversation = false
                } else {
                    print("Mesaj GÖNDERİLEMEDİ.")
                }
                
            })
            
        }  // Eğer YENİ BİR KONUŞMAYSA BİRDEN FAZLA VERİTABANI İŞLEMLERİNİ BAĞLANTILI BİR ŞEKİLDE SIRASIYLA ŞİMDİ YAPICAZ :
        
        else {
            guard let conversationId = self.conversationId,let name = self.title else {
                return
            }
            
            DatabaseManager2.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion:
            {
                (success) in
                
                if success {
                    print("Mesaj GÖNDERİLDİ.")
                }
                else {
                    print("Mesaj GÖNDERİLEMEDİ.")
                }
            })
            
            
        } // Eğer YENİ BİR KONUŞMA DEĞİLSE   mevcut konuşma verilerine şimdi eklicez :
        
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
    } //  Mesaj kimliğinin  otherUserEmail,senderEmail,date'li ŞEKİLDE  OLUŞTURULMASI
    
    
}

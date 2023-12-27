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
        //mamiankara10-gmail-com_profile_picture.png
        return "\(safeEmail)_profile-picture.png"
    } // Bu yapı"computed property(hesaplanmış özellik)'tir.Her çağrıldığında YENİ değer hesaplamak için bir getter(alıcı) fonksiyonunu kullanır.
    
}


// MY MARK : HESAP YÖNETİMİ

extension DatabaseManager2 {
    
   
    
      /*  YANİ kullanıcının aynı mail adresinde 2inci bir hesap  OLUŞTURMAMASI İÇİN bu metotu yazdık.
          Aynı mail adresinden bir kullanıcı varsa true, yoksa false dönecek. (userExist = Kullanıcı var) */
    public func userExist(with email : String,
                          completion : @escaping ((Bool) -> Void ) ) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-") // replacingOccurrences : Olayların değiştirilmesi( Yani syntax'leri değiştirdik.)
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: DataEventType.value, with: // database içinde tek bir olayı gözlemliyoruz şuan :
        {
          (snapshot) in
            
            guard let foundEmail = snapshot.value as? String else { // Hoca şunu yazdı : guard snapshot.value as? String != nil else [ İkiside aynı işleve sahiptir ! ! ! ]
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
            completion(true)
        } )
        
    }
    
    
}






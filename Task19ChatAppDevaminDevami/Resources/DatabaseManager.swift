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
            
            /*
             
             USERS KLASÖRÜNE TIKLADIĞINDA KARŞINA ÇIKACAK OLAN KOLEKSİYONLARIN BİÇİMİ
             
             [
                   [
             
                     "name" :
                     "safe_email " :
             
                   ],
             
                   [
             
                     "name" :
                     "safe_email " :
             
                   ],
             
             ]
             
             */ // DATABASE'DEKİ  KLASÖR İÇİNDEKİ KOLEKSİYONUN GÖRÜNME ŞEKLİ
            
            
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






//
//  StorageManager.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 26.12.2023.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    // Şimdi şunları yapıcaz : Verilere(Data'lara BAYT alabilen bir İŞLEV EKLİCEZ ve yazılması gereken yere bir DOSYA ADI EKLİCEZ :
    
    /*
     
     /images/mamiankara10-gmail-com_profile-picture.png bunu şimdi  /images/fileName bu şekildede düşünebilirim.
     URL'e ihtiyacımızın olmamasının nedeni üstteki depolama nesnesini bu öğe için URL'sini KULLANABİLMEMİZDİR.Ancak zaten onu yüklüyoruz.URL'i ALIP CİHAZDA ÖNBELLEĞE ALIRIZ VE BÖYLECE
     FİREBASE STORAGE ( DEPOLAMA ALANINI ) SÜREKLİ OLARAK OKUMAK ZORUNDA KALMAYIZ !!!!!!
     
     */ // SAKIN SİLME ÇOK KRİTİK YAPILAR VE BİLGİLER VAR.
    
    
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void // UploadPictureCompletion = Resim yüklemeyi Tamamla
    
    /*
        
        Örnek : typealias(Tipik ad ) =
        
        Swift programlama dilinde, typealias kelimesi, mevcut bir veri tipine alternatif bir isim vermek için kullanılan bir yapıdır. Bu, kodunuzu daha okunabilir hale getirmek
        veya karmaşık veri tiplerini daha basitleştirmek amacıyla kullanılabilir. typealias kullanımı, özellikle uzun ve karmaşık veri tipleriyle çalışırken kodunuzu daha anlaşılır
        kılmak için kullanışlıdır.
        
        typealias Kilometer = Double
        let distance: Kilometer = 42.0
        
        Yani typealias kod yazarken DAHA ANLAŞILIR OLSUN DİYE VERİ TİPLERİNİ (STRİNG,DOUBLE... ) kodun içeriğine göre daha ANLAŞILIR KILMAK İÇİN İSİMSEL BAZDA DEĞİŞTİRMEYE YARAR.
        */ // typealias(Tipik ad ) Açıklaması
        
        
    /// ŞİMDİ Firebase Storage'a(Depolama Alanına) YÜKLÜYORUZ  ve  indirilecek URL 'i tamamlayı DÖNDÜRÜYORUZ.
    public func uploadProfilePicture(with data: Data,fileName : String,completion : @escaping UploadPictureCompletion ) {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion:
        {
            (metadata,error) in  // metadata : Bir türün veya nesnenin ÇALIŞMA ZAMANINDA tür bilgilerini(Int,float,string..) tutan veri anlamına gelir.
            
            guard error == nil else {
                // Failed
                print("Resim verilerini Firebase'e yükleyemedin.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            let reference = self.storage.child("images/\(fileName)").downloadURL {
                
                (url,error)in
                
                guard let url = url else {
                    print("İndireceğimiz(ihtiyacımız olan) url alınamadı.")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString // absoluteString = url'in TAM STRİNG yazısını alır.
                print("İndirmemiz gereken url'yi başarılı bir şekilde şimdi alabildik.")
                completion(.success(urlString))
            }
            
        })
        
    }
    
    
    public enum StorageErrors : Error {
        case failedToUpload // Yükleme başarısız oldu.
        case failedToGetDownloadUrl // İndireceğimiz(ihtiyacımız olan) url alınamadı.
    }
    
    
    public func downloadURL(for path: String,  completion : @escaping(Result<URL,Error>) -> Void ) {
        
        let reference = storage.child(path)
        
        reference.downloadURL (completion: {
            
              ( url, error ) in

            guard let url = url , error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
            
        })
        
    }
    
}

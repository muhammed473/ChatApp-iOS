//
//  ViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {
    
    
    // ConversationsViewController = Konuşmalar(Görüşmeler) Görüntüleme Denetleyicisi
    
    // Varsayılan ayarlara göre kullanıcının oturum açıp açmadığını kontrol edicez.Eğer oturum AÇTIYSA  ekranda kalacağız yok eğer oturum AÇMADIYSA oturum açma ekranını göstericez.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // DatabaseManager.shared.test()  // Database'i ufaktan anlaman için örnek yaptık.
        
    }
    
    override func viewDidAppear(_ animated: Bool) { // Ekran ( Görünüm ) göründükten HEMEN SONRA çalışır.
        super.viewDidAppear(animated)
        
        validateAuth()
        
    }
    
    private func validateAuth() { // Kimlik Doğrulama Metodu
        
        if FirebaseAuth.Auth.auth().currentUser == nil  {
            
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            present(nav, animated: false)
            
        }
        
    }
    
}


}


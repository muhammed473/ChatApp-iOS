//
//  ViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


struct Conversation {
    let id : String
    let name : String
    let otherUserEmail : String
    let latestMessage : LatestMessage
    
}

struct LatestMessage {
    let date : String
    let text : String
    let isRead : Bool
}

class ConversationsViewController: UIViewController {  // Konuşmalar(Görüşmeler) Görüntüleme Denetleyicisi
    
    
    // Varsayılan ayarlara göre kullanıcının oturum açıp açmadığını kontrol edicez.Eğer oturum AÇTIYSA  ekranda kalacağız yok eğer oturum AÇMADIYSA oturum açma ekranını göstericez ve diğeri işlemleri yapıcaz.
    
    private var conversations = [Conversation]()
    
    private let spinner = JGProgressHUD(style: .dark) // spinner = döndürücü
    
    private let mytableView : UITableView = {
       
        let table = UITableView()
        table.isHidden = true 
        /* Bunu ilk başta gizlememizin nedeni İLK ÖNCE MEVCUT OTURUM AÇMIŞ KULLANICININ KONUŞMALARINI GETİRMEMİZ VE EĞER HERHANGİ bir konuşmaları YOKSA TABLONUN BOŞ OLMASINI İSTEMİYORUZ.Ortada bir etiket gibi göstermek
           istiyoruz. Ekranın konuşma yok diyen kısmı bir resim görünümü gibi olabilir. Eğer konuşmaları VARSA TABLO GÖRÜNÜMÜNÜ GÖSTERİRİZ AKSİ HALDE ONU SAKLARIZ(GİZLERİZ).
         */
        table.register(ConversationMyTableViewCell.self, forCellReuseIdentifier: ConversationMyTableViewCell.identifer)
        return table
    }()
    
    
    private let noConversationsLabel : UILabel = { // noConversationsLabel = Konuşma yok etiketi
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = . systemFont(ofSize: 21,weight: .medium)
        label.isHidden = true // Yükleniyor kısmında bu etiketi göstermek istemediğimiz için bunu Sakladık( Gizledik )
        return label
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        
        print("Şuanda ConversationViewController scriptindeyiz.")
        // DatabaseManager.shared.test()  // Database'i ufaktan anlaman için örnek yaptık.
        view.backgroundColor = .yellow
        view.addSubview(mytableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        startListeningForConversations()
    }
    
    
    private func startListeningForConversations() {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("Konuşmaları göstermeye başla...")
        let safeEmail = DatabaseManager2.safeEmail(emailAddress: email)
        
        DatabaseManager2.shared.getAllConversations(for: safeEmail, completion: {
           [weak self] (result) in
            
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.mytableView.reloadData()
                }
                
            case .failure(let error):
                print("Database'deki konvoya ulaşılamadı : \(error)")
            }
            
        })
                                                        
    }
    
    
    @objc private func didTapComposeButton() { // ->
        
        let vc = NewConversationsViewController()
        vc.completion = {
            
             [weak self]  (result) in
            
          print("\(result)") // Seçilen kişinin bilgileri
            self?.createNewConversation(result: result)
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
        
    } // -> NewConversationsViewController
    
    
    private func createNewConversation(result : [String:String]) {
        
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        
        let vc = ChatViewController(with: email,id:nil) // Hangi kullanıcıyla sohbet ettiğimiz email 'le anladık...
        vc.isNewConversation = true
        vc.title  = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // viewDidLayoutSubviews = Görünüm denetleyicisine, görünümün alt görünümlerini EKLEDİKTEN HEMEN SONRA çalışır.
    override func viewDidLayoutSubviews() {
        
        mytableView.frame = view.bounds // Hücredeki Hello world yazısını bu  metot ve bu koddan SONRA GÖRDÜN O YÜZDEN DİKKAT ET !!!!!!!
       
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
    
    
    private func setupTableView() {
        mytableView.delegate = self
        mytableView.dataSource = self
        
        
    }
    
    
    private func  fetchConversations() {
        
        mytableView.isHidden = false
      
        
    }
    
}

extension ConversationsViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationMyTableViewCell.identifer, for: indexPath) as! ConversationMyTableViewCell
        cell.configure(with: model)
        cell.accessoryType = .disclosureIndicator // Hücrenin sağ tarafındaki aksesuarın SAĞA DOĞRU OK objesi olsun dedik.
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Tablo hücresini seçtiğimizde seçili durumdan çıkarmak ve kullanıcının etkileşime devam etmesine olanak tanımak için kullanılır.
        
        let model = conversations[indexPath.row]
        
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    } // Satır Yüksekliği
}





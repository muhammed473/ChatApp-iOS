//
//  NewConversationViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//

import UIKit
import JGProgressHUD

class NewConversationsViewController: UIViewController  {

    
    public var completion : (([String:String]) -> (Void))? // Bu completion DEĞİŞKENİN TİPİ BİR FONKSİYONDUR(CLOSURE).
 
    private let spinner  = JGProgressHUD(style: .dark)
    
    private var users  = [[String:String]]() // SÖZLÜK DİZİSİ
    private var hasFetched = false
    private var results = [[String:String]]()
    
    private let mySearchBar : UISearchBar = {
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Kullanıcıları ara..."
        return searchBar
    }()
    
    private let myTableView: UITableView = {
       
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
        
    }()
    
    private let noResultsLabel : UILabel = {
        
        let label = UILabel()
        label.isHidden = true
        label.text = "Sonuç yok."
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21,weight: .medium)
        return label
        
    }() // Kullanıcı YOKSA BUNU BELİRLTMEMİZİ SAĞLAYAN BİR ETİKETTİR.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(noResultsLabel)
        view.addSubview(myTableView)
        myTableView.delegate = self
        myTableView.dataSource = self
        mySearchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = mySearchBar // Bu kod sayesinde SearchBar'ımızın konumunu belirledik.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf)) // dismissSelf = Bu Script ve haliyle ekrandan çıkış yaparız.
        
        mySearchBar.becomeFirstResponder() // Bu kod sayesinde ViewDidLoad() Çağrıldığı anda arama çubuğundaki klavyeyi çağırdık.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        myTableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.widthss/4,
                                      y: (view.height-200)/2,
                                      width: view.widthss/2, height: 200)
    }
    
    
    @objc private func dismissSelf() {
        
        dismiss(animated: true,completion: nil)
    }

}



extension NewConversationsViewController: UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        self.searchUsers(query: text)
    }
    
    
    func searchUsers(query:String) {
        
        /*
           1) Temel olarak DİZİMİZİN FİREBASE SONUÇLARI OLUP OLMADIĞINI KONTROL EDİCEZ.
           2) Eğer kulanıcı ARANIYORSA ARAMA SONUCUNA GÖRE KULLANICILARI GETİR.
           3) Eğer kullanıcı ARANMIYORSA VAR OLAN KULLANICILARI GETİR.
           4) Son olarak KULLANICI ARAYÜZÜNÜ GÜNCELLE : Sonuçları GÖSTER, Eğer SONUÇ YOKSA SONUÇ YOK ETİKETİNİ
              GÖSTER.
        */ // ÖNEMLİ : Bu metotta şunları yapıcaz :
        
        if hasFetched {
            filterUsers(with: query)
        }
        
        else{ // Kullanıcı ARANMADIĞI için tüm kullanıcıların gösterilmesi
            DatabaseManager2.shared.getAllUsers(completion: {
               
                [weak self] (result) in
                
                switch result {
                    
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Kullanıcılar alınamadı.")
                    
                }
            })
            
        }
        
        
    }
    
    
    func filterUsers(with terim : String) {
        
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
        
        let results : [[String:String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased()  else {
                return false
            }
            // hasPrefix : Kullanıcıların isimlerinin girdiğimiz  HARF İLE başlayıp başlamadığını kontrol eder.
            return name.hasPrefix(terim.lowercased()) // İsmi Girdiğimiz HARFE UYAN KULLANICILARI BİZE GÖSTERİR !!!
          
        })
            
        self.results = results
        updateUI()
        
    }
    
    
    func updateUI() {
        
        if self.results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.myTableView.isHidden = true
        }
        
        else {
            self.noResultsLabel.isHidden = true
            self.myTableView.isHidden = false
            self.myTableView.reloadData()
        }
        
    }
    
}


extension NewConversationsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        // ["name] = name datasına benzer veri çıkar demiş olduk.
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myTableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = self.results[indexPath.row]
        
        dismiss(animated: true, completion: {
            [weak self] in
            self?.completion?(targetUserData)
        })
        
      
        
    } // KİŞİLER KONUŞMA BAŞLATICAK
    
}

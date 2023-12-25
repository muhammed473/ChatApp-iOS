//
//  NewConversationViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//

import UIKit
import JGProgressHUD

class NewConversationsViewController: UIViewController  {

    private let spinner  = JGProgressHUD()
    
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
        mySearchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = mySearchBar // Bu kod sayesinde SearchBar'ımızın konumunu belirledik.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf)) // dismissSelf = Bu Script ve haliyle ekrandan çıkış yaparız.
        
        mySearchBar.becomeFirstResponder() // Bu kod sayesinde ViewDidLoad() Çağrıldığı anda arama çubuğundaki klavyeyi çağırdık.
    }
    
    
    @objc private func dismissSelf() {
        
        dismiss(animated: true,completion: nil)
    }

}

extension NewConversationsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
    }
}

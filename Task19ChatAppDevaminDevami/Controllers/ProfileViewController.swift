//
//  ProfileViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//

import UIKit
import FirebaseAuth
import FacebookLogin 
import GoogleSignIn


class ProfileViewController: UIViewController {
    
    let vc = LoginViewController()
  //  @IBOutlet var tableView : UITableView!
    
    @IBOutlet weak var tableView2: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView2?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView2?.delegate = self
        tableView2?.dataSource = self
        
    }
    

    
}

extension ProfileViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) // Animasyonla dizin yolundaki bir satırın seçimini kaldırdık.
        
        let actionSheet = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                      style: .destructive,
                                      handler: {
           [weak self] (_) in
            
            guard let strongSelf = self else {
                return
            }
            
            // Şimdi FACEBOOK'TAN ÇIKIŞ YAPICAZ :
            FacebookLogin.LoginManager().logOut()
            
            // Şimdi GOOGLE ile GİRİŞTEN ÇIKIŞ YAPICAZ :
            GIDSignIn.sharedInstance.signOut()
            
            
            do{
                
              try  FirebaseAuth.Auth.auth().signOut() // Oturumu kapattık ve şimdi Oturum açma ekranına yönlendiriyoruz :
                
              
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                strongSelf.present(nav, animated: true)
                
            }
            catch{
                print("Oturum kapatılamadı.")
                
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: UIAlertAction.Style.cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
        
     
        
        
        
    }
    
    
    
}


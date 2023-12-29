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
    
    @IBOutlet weak var tableView2: UITableView!
    
    let vc = LoginViewController()
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView2.tableHeaderView = createTableHeader()
        tableView2?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView2?.delegate = self
        tableView2?.dataSource = self
      
        
        
    }
    
    func createTableHeader() -> UIView? {
        
        // Şimdi Daha önce UserDefault'a kaydettiğimiz kullanıcının mailini burda çıkartmamız(almamız) lazım.
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager2.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile-picture.png"
        
        let path = "images/" + filename
    
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.widthss, height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.widthss - 150) / 2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.widthss/2
        imageView.layer.masksToBounds = true // Bir görünümün içeriğini, görünümün sınırları içinde sığdırabilme özelliğinin ayarlanabilmesidir.Burdada sığdır demiş olduk.
        
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: {
           
           [weak self] (result) in
            
            switch result {
                
            case .success(let url) :
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("İhtiyacımız olan indirme url'sini alamadık :gdfgdgd \(error)")
            }
            
        })
        
       
        return headerView
        
    }
    
    func downloadImage(imageView: UIImageView,url : URL) {
        
        URLSession.shared.dataTask(with: url,completionHandler:  {
            
           (data,_,error) in
            
            guard let data = data, error == nil else{
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
            
        }).resume()
        
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


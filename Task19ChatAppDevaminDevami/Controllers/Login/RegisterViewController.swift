//
//  RegisterViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//


import UIKit
import FirebaseAuth
import JGProgressHUD // Yükleniyor imajını gösterme olayını bu kütüphaneyle yapıcaz.


class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView : UIScrollView = {
        
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true // True olarak ayarladığımızda alt görünümlerin görünümün sınırlarına göre KIRPILMASINI SAĞLAR.
        return scrollView
        
    }()
    
    private let imageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle") // Swift'in kendi resim'lerinden aldık.
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    private let firstNameField : UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none // Metnimizin OTOMATİK BÜYÜK HARF STİLİNİN OLMADIĞINI SÖYLEMİŞ OLDUK.
        field.autocorrectionType = .no // Metnin içerisinde yazacağımız yazıyı DÜZELTME STİLİ( Yani metnimizin yerine daha mantıklı bir metin yazma işlemi) OLMASIN NEYSE O OLSUN  DEMİŞ OLDUK.
        field.returnKeyType = .continue // Return tuşunun görünür başlığının DEVAM olduğunu belirtir.
        field.layer.cornerRadius = 13
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0)) // Text 'in içinde syntax'in nerden başlayacağını belirledik.
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField : UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none // Metnimizin OTOMATİK BÜYÜK HARF STİLİNİN OLMADIĞINI SÖYLEMİŞ OLDUK.
        field.autocorrectionType = .no // Metnin içerisinde yazacağımız yazıyı DÜZELTME STİLİ( Yani metnimizin yerine daha mantıklı bir metin yazma işlemi) OLMASIN NEYSE O OLSUN  DEMİŞ OLDUK.
        field.returnKeyType = .continue // Return tuşunun görünür başlığının DEVAM olduğunu belirtir.
        field.layer.cornerRadius = 13
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0)) // Text 'in içinde syntax'in nerden başlayacağını belirledik.
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField : UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none // Metnimizin OTOMATİK BÜYÜK HARF STİLİNİN OLMADIĞINI SÖYLEMİŞ OLDUK.
        field.autocorrectionType = .no // Metnin içerisinde yazacağımız yazıyı DÜZELTME STİLİ( Yani metnimizin yerine daha mantıklı bir metin yazma işlemi) OLMASIN NEYSE O OLSUN  DEMİŞ OLDUK.
        field.returnKeyType = .continue // Return tuşunun görünür başlığının DEVAM olduğunu belirtir.
        field.layer.cornerRadius = 13
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0)) // Text 'in içinde syntax'in nerden başlayacağını belirledik.
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField : UITextField = {
        
        let field = UITextField()
        field.autocapitalizationType = .none // Metnimizin OTOMATİK BÜYÜK HARF STİLİNİN OLMADIĞINI SÖYLEMİŞ OLDUK.
        field.autocorrectionType = .no // Metnin içerisinde yazacağımız yazıyı DÜZELTME STİLİ( Yani metnimizin yerine daha mantıklı bir metin yazma işlemi) OLMASIN NEYSE O OLSUN  DEMİŞ OLDUK.
        field.returnKeyType = .done // Return tuşunun görünür başlığının BİTTİ olduğunu belirtir.
        field.layer.cornerRadius = 13
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password.."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0)) // Text 'in içinde syntax'in nerden başlayacağını belirledik.
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerBotton : UIButton = {
        
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23,weight: .bold)
        return button
        
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Register"
        view.backgroundColor = .white
        
        /* navigationItem.rightBarButtonItem = UIBarButtonItem(
         title: "Register",
         style: .done,
         target: self,
         action: #selector(didTapRegister)) */
        
        registerBotton.addTarget(self,
                                 action: #selector(registerButtonTapped),
                                 for: UIControl.Event.touchUpInside)
        // UIControl.Event.touchUpInside :Butonun sınırları içinde tıkladığı zaman işlem yapar.Çok farklı tipte seçenekler vardır.SONRA BUNLARI ARAŞTIRABİLİRSİN.
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerBotton)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        
        imageView.isUserInteractionEnabled = true // Kullanıcı etkileşimi var.(true)
        scrollView.isScrollEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
    }
    
    
    @objc private func didTapChangeProfilePic(){
        
        // print("Resim değiştirildi. [ Change pic called. ] ")
        
        myPresentPhotoActionSheet()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /* viewDidLayoutSubviews() =  Görünüm denetleyicisine, görünümün alt görünümlerini EKLEDİKTEN HEMEN SONRA çalışır.
         ViewDidLoad()'dan hemen sonra çalışır. Çünkü düzen hesaplaması  uygulandığında gerçekleşir.
         Bir başka deyişle görünümde değişiklik olduğunda örneğin yeni bir görüntü elemanı eklendiğinde veya sınırlar değiştiğinde bu metot
         çağrılır.
         */
        
        scrollView.frame = view.bounds
        
        let size = scrollView.widthss/3 // -> widthss'i = Extension SCRİPTİNDE yazdık.
        
        imageView.frame = CGRect(x: (scrollView.widthss - size)/2, y: 25, width: size, height: size)
        imageView.layer.cornerRadius = imageView.widthss/2.0
        
        
        firstNameField.frame = CGRect(x: 30,
                                      y: imageView.bottom + 10,
                                      width: scrollView.widthss - 60,
                                      height: 52)
        lastNameField.frame = CGRect(x: 30,
                                     y: firstNameField.bottom + 10,
                                     width: scrollView.widthss - 60,
                                     height: 52)
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 10,
                                  width: scrollView.widthss - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.widthss - 60,
                                     height: 52)
        registerBotton.frame = CGRect (x: 30,
                                       y: passwordField.bottom + 10,
                                       width: scrollView.widthss - 60,
                                       height: 52)
    }
    
    
    @objc private  func registerButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        guard
            let firstName = firstNameField.text,
            let lastName = lastNameField.text,
            let myEmails = emailField.text,
            let myPassword = passwordField.text,
            !myEmails.isEmpty,
            !myPassword.isEmpty,
            myPassword.count >= 6,
            !firstName.isEmpty,
            !lastName.isEmpty
        else {
            alertUserLoginError(message:"Hata" )
            return
        }
        
        spinner.show(in: view) // Yükleniyor imajını(döndürücüyü, animasyon veya görüntü ) göster dedik. Mevcut görünümde göster demiş olduk.
        
        // BURDA OTURUM AÇMAYI YANİ FİREBASE GİRİŞİNİ UYGULUCAZ.
        
        DatabaseManager2.shared.userExist(with: myEmails) {
            [weak self]  (exists)  in
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                // kullanıcı zaten var.
                strongSelf.alertUserLoginError(message: "Bu eposta adresine sahip bir kullanıcı var.Lütfen başka bir eposta adresiyle kaydolun")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: myEmails , password: myPassword,completion:
                                                    {
                
                (aultResult,error)  in
                
                
                guard  aultResult != nil, error == nil else {
                    print("Error creating user.( Kullanıcı oluşturma hatası.)")
                    return
                }
                
                //  BURASI ÖNEMLİ DİKKAT ET ! ! !  ==>  Yani Authentication 'da(Kimlik doğrulamada) HESABI OLUŞTURURKEN VERİTABANI YÖNETİCİSİNİ ÇAĞIRARAK VERİTABANIMIZA KULLANICININ GİRDİĞİ  isim,soyisim ve email bilgilerini KAYDETTİK.
                DatabaseManager2.shared.insertUser(with: ChatAppUser2(firstName:firstName ,
                                                                      lastName: lastName,
                                                                      emailAddress: myEmails))
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil) //  Navigasyon kontrol cihazını GÖREVDEN ALDIM.
                
            } )
            
            
        }
        
        
    }
    
    
    func alertUserLoginError(message:String) {
        
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel,handler: nil))
        present(alert,animated: true)
    }
    
    
    /*   @objc private func didTapRegister() { // didTapRegister = KAYDOL düğmesine dokunduysam
     
     let vc = RegisterViewController()
     vc.title = "Create Account" // başlık kısmında Create Account (Hesap Oluştur) yazacak.
     navigationController?.pushViewController(vc, animated: true)
     
     
     } */
    
    
    
}



extension RegisterViewController: UITextFieldDelegate { // Metnin düzenlenmesini ve doğrulanmasını yönetmek için kullandığımız bir PROTOCOL
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Metin alanının dönüş düğmesi için varsayılan davranışı uygulaması gerekiyorsa TRUE, aksi takdirde FALSE DÖNER.
        
        if textField == emailField {
            
            passwordField.becomeFirstResponder() // passwordField'a  ilk müdaheleci(yanıtlayıcı) ol dedik.
        }
        else if textField == passwordField {
            registerButtonTapped() // Böylece kullanıcının devam etmek için açıkça Register DÜĞMESİNE BASMASINA GEREKMEDİ.
        }
        
        return true
    }
    
    
    
}



extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate { // Görüntü seçici denetleyici delegeleri
    
    
    func myPresentPhotoActionSheet(){
        
        // Eylem sayfamıza (Action Sheet'e) 3 düğme (button) eklicez.Bunlar : İptal buttonu, Fotograf Çek Butonu, Fotograf Seç Butonu
        
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "Nasıl bir resim seçmek istersiniz ? ",
                                            preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel Yani İptal",
                                            style: UIAlertAction.Style.cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo Yani Fotograf Çek",
                                            style: UIAlertAction.Style.default,
                                            handler: {
            [weak self] (_) in
            /* weak self ( Zayıf Öz ) : Buna ihtiyacımız var.Bir hafıza tutma döngüsü. Self isteğe bağlı(?) hale gelir ÇÜNKÜ ZAYIFTIR. Bu yüzden
             Kamera fonksiyonunu(presentCamera()) çağırabiliriz.
             */
            
            self?.presentCamera()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo Yani Fotograf Seç",
                                            style: UIAlertAction.Style.default,
                                            handler: {
            [weak self]  (_) in
            
            self?.presentPhotoPicker()
            
        }))
        
        present(actionSheet, animated: true)
        
    }
    
    func presentCamera() {
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true // Düzenlemeye izin verdik.Yani aslında kullanıcının fotografı çektikten sonra resmin kırpılmış bir karesini seçmesine izin verdik.
        present(vc,animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true // Düzenlemeye izin verdik.Yani aslında kullanıcının fotografı çektikten sonra resmin kırpılmış bir karesini seçmesine izin verdik.
        present(vc,animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Resim seçici kontrolcüsü ( Bilgi içeren medya toplamanın bitirilmesi ) ( Fotograf çektiğinde veya seçtiğinde bu metot çağrılır.
        
        //  ÖNEMLİ : Bu metotun parametrelerinde bulunan SÖZLÜĞÜN İÇİNDEN GÖRÜNTÜYÜ YAKALARIZ.
        //    print("Bilgi :\(info)") // Seçtiğimiz görüntünün bilgilerini yakaladık o yüzden bu kodu silme ! ! !.
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { // Edit yani kırptığım(düzenlendiğim) resmi aldım.
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { // Görüntü seçme işleminin iptal edilmesi
        
        picker.dismiss(animated: true,completion: nil)
    }
    
}






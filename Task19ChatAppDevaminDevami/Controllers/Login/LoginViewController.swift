//
//  LoginViewController.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//


import UIKit
import FacebookLogin
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import JGProgressHUD // Yükleniyor imajını gösterme olayını bu kütüphaneyle yapıcaz.



class LoginViewController: UIViewController{
  
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView : UIScrollView = {
        
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true // True olarak ayarladığımızda alt görünümlerin görünümün sınırlarına göre KIRPILMASINI SAĞLAR.
        return scrollView
        
    }()
    
    private let imageView : UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
        
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
    
    private let loginBotton : UIButton = {
        
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        if #available(iOS 13.0, *) {
            button.backgroundColor = .link
        } else {
            // Fallback on earlier versions
        }
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23,weight: .bold)
        return button
        
    }()
    
    private let facebookLoginButton : FBLoginButton = {
        
        let button = FBLoginButton()
        button.permissions = ["public_profile","email"] // Permission : İzin     public_profile : Kullanıcının adını ve soyadını içerir.
        
        return button
    }()
    
    private let googleSignInButton : GIDSignInButton = {
        
        let button = GIDSignInButton()
     /*   button.setTitle("Google SignIn", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23,weight: .bold) */
        return button
    }()
    

    private let googleSignOutButton : UIButton = {
        
        let button = UIButton()
        button.setTitle("Google SignOut",for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23,weight: .bold)
        return button
    }()
    
    private var loginObserver : NSObjectProtocol? // Giriş gözlemcisi
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       loginObserver = NotificationCenter.default.addObserver(
                                               forName: Notification.Name.didLogInNotification,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: { [weak self] (_) in // Kullanım bir geri arama olacak ve bu buradaki bildirime iletecek.
            
           guard let strongSelf = self else {
               return
           }
           
           strongSelf.navigationController?.dismiss(animated: true,completion: nil) // Güçlü benlik NAVİGASYONU İPTAL ETSİN DEDİK.
        })
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Register",
            style: .done,
            target: self,
            action: #selector(didTapRegister))
        
        loginBotton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: UIControl.Event.touchUpInside)
        // UIControl.Event.touchUpInside :Butonun sınırları içinde tıkladığı zaman işlem yapar.Çok farklı tipte seçenekler vardır.
        
        googleSignInButton.addTarget(self, action: #selector(myGoogleSignIn), for: UIControl.Event.touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookLoginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginBotton)
        
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleSignInButton)
        //  scrollView.addSubview(googleSignOutButton)
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /* viewDidLayoutSubviews() =  ViewDidLoad()'dan hemen sonra çalışır. Çünkü düzen hesaplaması  uygulandığında gerçekleşir.
         Görünüm denetleyicisine, görünümün alt görünümlerini EKLEDİKTEN HEMEN SONRA çalışır.
         Bir başka deyişle görünümde değişiklik olduğunda örneğin yeni bir görüntü elemanı eklendiğinde veya sınırlar değiştiğinde bu metot
         çağrılır.
         */
        
        scrollView.frame = view.bounds
        
        let size = scrollView.widthss/3 // -> widthss'i = Extension SCRİPTİNDE yazdık.
        imageView.frame = CGRect(x: (scrollView.widthss - size)/2, y: 25, width: size, height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.widthss - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.widthss - 60,
                                     height: 52)
        
        loginBotton.frame = CGRect (x: 30,
                                    y: passwordField.bottom + 10,
                                    width: scrollView.widthss - 60,
                                    height: 52)
        
        facebookLoginButton.frame = CGRect (x: 30,
                                            y: loginBotton.bottom + 10,
                                            width: scrollView.widthss - 60,
                                            height: 62)
        
        facebookLoginButton.frame.origin.y = loginBotton.bottom + 30
        
        googleSignInButton.frame = CGRect(x: 30,
                                          y: facebookLoginButton.bottom + 10,
                                          width: scrollView.widthss - 60,
                                          height: 62)
    }
    
    
    @objc private  func loginButtonTapped() {
        
        emailField.resignFirstResponder()     //  Eğer KLAVYE e posta alanına odaklanmışsa ilk cevap veren  olmaktan istifa et.
        passwordField.resignFirstResponder()  //  Eğer KLAVYE şifre alanına odaklanmışsa ilk cevap veren  olmaktan istifa et.
        //   YANİ LOGİN BUTONUNA TIKLAYACAĞIMIZ ESNADA KLAVYEYİ HEM E POSTA HEMDE ŞİFRE İÇİN KALDIRIR ÇÜNKÜ KALDIRMAZSAK LOGİN BUTONUNA EKRANDA TIKLAYAMAYABİLİRİZ.
        guard let myEmail =
                emailField.text, let myPassword = passwordField.text, !myEmail.isEmpty, !myPassword.isEmpty,myPassword.count >= 6
        else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view) // Yükleniyor imajını(döndürücüyü, animasyon veya görüntü ) göster dedik. Mevcut görünümde göster demiş olduk.
        
        // BURDA OTURUM AÇMAYI YANİ FİREBASE GİRİŞİNİ UYGULUCAZ.
        
        FirebaseAuth.Auth.auth().signIn(withEmail: myEmail, password: myPassword,completion: {
            
            [weak self] (authResult , error )  in
            
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss() // Kimlik doğrularken Yükleniyor imajını ( döndürücüyü ) kapattık.
            }
            
            
            guard let result = authResult, error == nil else{
                self?.alertUserLoginError()
                print("Böyle bir kullanıcı YOK LÜTFEN bu uygulamaya İLK ÖNCE KAYDOLUN.")
                return
            }
            
          //  let user = authResult?.user // Burayı KENDİ ÖZGÜR İRADENLE SİLDİN ve YERİNE ŞUNU YAZDIN :
            let user = result.user
            
            print("Oturum açan kullanıcının bilgileri : \(user)")
            print("Şimdi UYGULAMANIN İÇERİĞİNİ GÖSTEREN  BAŞKA BİR EKRANA GEÇEBİLİRSİN.")
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil) //  Navigasyon kontrol cihazını GÖREVDEN ALDIM.
            
        })
        
    }
    
    
    func alertUserLoginError() {
        
        let alert = UIAlertController(title: "Woops", message: "Please enter all correct information to log in ( Yani Oturum açmak için bilgilerinizi doğru girin.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel,handler: nil))
        present(alert,animated: true)
    }
    
    
    @objc private func didTapRegister() { // didTapRegister = KAYDOL düğmesine dokunduysam
        
        let vc = RegisterViewController()
        vc.title = "Create Account" // başlık kısmında Create Account (Hesap Oluştur) yazacak.
        navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    
    @objc private func myGoogleSignIn(){
        
        print("google butonuna tıklandı." )
        
      /* guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config */
        
        GIDSignIn.sharedInstance.signIn(withPresenting:self) {
        
       [unowned self]  (signInResult, error) in
        
             
        guard error == nil else { return }
            
            
        // Oturum açma başarılı olursa uygulamanın ana içerik Görünümünü görüntüleyin.
        
            guard  let user = signInResult?.user,let idToken = user.idToken?.tokenString
            else{
                return
            }
            
            print("Google ile oturum açıldı.İşte Google ile oturum açan kullanıcının bilgileri : \(user) ")
            
            guard let email = user.profile?.email,
                  let firstName = user.profile?.givenName, // givenName : Google ile giriş yapan kullanıcının adı
                  let lastName = user.profile?.familyName
            else {
                return
            }
                    
                    
            DatabaseManager2.shared.userExist(with: email,completion:  {
                
                (exists) in
                
                if !exists { // Eğer KULLANICI DATABASE'DE  MEVCUT DEĞİLSE EKLİCEZ..
                    DatabaseManager2.shared.insertUser(with: ChatAppUser2(firstName: firstName,
                                                                          lastName: lastName,
                                                                          emailAddress: email))
                }
            })
            
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
           
          Auth.auth().signIn(with: credential,completion: {
                
                (authresult, error) in

                guard authresult != nil, error == nil else {
                    print("Kullanıcı Google hesabıyla ( KİMLİĞİYLE )  giriş yapamadı.")
                    return
                }
                
            print("Kullanıcı GOOGLE HESABIYLA  ( KİMLİĞİYLE ) BAŞARILI BİR ŞEKİLDE GİRİŞ YAPTI.")
                // Google ile oturum ama İŞLEMİ BAŞARIYLA TAMAMLANDIĞI İÇİN  ŞİMDİDE GOOGLE  BİR BİLDİRİMDEN YARARLANMAK ZORUNDADIR.
                // O YÜZDEN ŞİMDİ ViewDidLoad()'A GİT ve burda => NotificationCenter'la ALAKALI KOD YAZDIK.Bu kodu kontrol et.
              
          NotificationCenter.default.post(name: .didLogInNotification, object: nil) // Giriş yapıldığının bilgisinin Bildirimini gönderdik.
              
            })
            
       
        }

        
    } // GOOGLE İLE GİRİŞ ENTEGRASYONU
    
 
    @IBAction func signinout( _ sender: Any) {
        
        GoogleSignIn.GIDSignIn.sharedInstance.signOut()
    }
    
    
}




extension LoginViewController: UITextFieldDelegate { // Metnin düzenlenmesini ve doğrulanmasını yönetmek için kullandığımız bir PROTOCOL
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Metin alanının dönüş düğmesi için varsayılan davranışı uygulaması gerekiyorsa TRUE, aksi takdirde FALSE DÖNER.
        
        if textField == emailField {
            
            passwordField.becomeFirstResponder() // passwordField'a  ilk yanıt(cevap) veren ol dedik.
        }
        else if textField == passwordField {
            loginButtonTapped() // Böylece kullanıcının devam etmek için açıkça Log In DÜĞMESİNE BASMASINA GEREKMEDİ.
        }
        
        return true
    }
    
}




extension LoginViewController: LoginButtonDelegate{  // Facebook ile giriş ENTEGRASYONU
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // Bu metot sayesinde Oturum açabildik mi açamadık mı bunu anlarız.
        
        let login : LoginManager = LoginManager()
        
        guard let token = result?.token?.tokenString else {
            print("KULLANICI FACEBOOK İLE GİRİŞ YAPAMADI ! ! !")
            login.logOut()
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "/me",             // Facebook ile oturum açmış kişinin email ve adının olduğu  bilgilerini ALDIK !!!!!!
                                                         parameters: ["fields" : "email,name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        let facebookRequest2 = GraphRequest(graphPath: "me", parameters: ["fields" : "email,name"], tokenString: token, version: nil, httpMethod: .get)
        
        
        facebookRequest.start(completion: {
            
            (_,result,error) in // _ = connection 'u temsil etti. Alt çizgiyi ( _ ) DEĞİŞKENİ ATILABİLİR OLAN DEĞİŞKENLER YERİNE KULLANILIR.
            
            guard let result = result as? [String:Any],
                  error == nil else {
                print("FACEBOOK GRAFİK İSTEKLERİNDE BAŞARISIZ OLDUK.")
                
                return
            }
            
            /* Eposta ve Adı bilgilerini result sözlüğünden alıcaz.Ayrıca şunuda bil eğer facebook ile giriş yapan kullanıcının adı ve mail bilgileri veritabanında yoksa EKLEME işlemini
             o zaman yaparız.
             Facebook ile devam etmek bir KAYIT MEKANİZMASI DEĞİLDİR.
             */
            print(result)
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("Facebook SUNUCUNDAN  KULLANICININ EPOSTA VE İSİM BİLGİSİ ALINAMADI.")
                return
            }
            
            let nameComponents = userName.components(separatedBy: " ") // boşluk ile ayırdık.
            guard nameComponents.count == 2 else {
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager2.shared.userExist(with: email,completion:
                                                {
                (exists) in
                
                if !exists { // Eğer bu emaile sahip kullanıcı veri tabanında YOKSA
                    DatabaseManager2.shared.insertUser(with: ChatAppUser2(firstName: firstName,
                                                                          lastName: lastName,
                                                                          emailAddress: email))
                }
            })
            
            
            // KİMLİK BİLGİSİ ALMAK İÇİN BU ERİŞİM JETONUNU(TOKEN'I) FİREBASE 'E VERMEMİZ GEREKİYOR.
            let credential = FacebookAuthProvider.credential(withAccessToken: token) // credential = Kimlik FacebookAuthProvider = Facebook Kimlik Doğrulama sağlayıcısı
            //  VE ŞİMDİ Kullanıcının OTURUM AÇMASI İÇİN GEREKLİ OLAN BU KAPALI KİMLİĞİMİZİ ŞİMDİ KULLANICAZ.Çünkü kimliği Firebase kimliği ile değiştirdik.
            FirebaseAuth.Auth.auth().signIn(with: credential,completion: { // Kullanıcı ŞUAN  FACEBOOK İLE OTURUM AÇIYOR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                [weak self]  (authResult, error) in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard  authResult != nil, error == nil else {
                    
                    if let error = error {
                        print("FACEBOOK KİMLİĞİYLE GİRİŞ BAŞARISIZ OLDU, ÇÜNKÜ ÇOK FAKTÖRLÜ KORUMA(Örneğin telefona 6 haneli  kod gelmesi) GEREKLİ OLABİLİR : \(error)")
                    }
                    return
                }
                
                print("BAŞARILI YANİ KULLANICI FACEBOOK İLE OTURUM AÇABİLDİ.")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil) // Şimdi giriş ekranını kapatıcaz.Bellek sızıntısına neden olmamak için güçlü benliği
                // kapatıyoruz.
            })
            
        } )
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) { // İşlem YAPMICAZ. ÇÜNKÜ :
        /*
         - Facebook'un perde arkasında yaptığı şey şu bir facebook kullanıcısının oturum açmış olduğunu algılar.Düğme bizim durumumuzda KAPATMAYI gösterecek şekilde
         OTOMATİK OLARAK GÜNCELLENECEKTİR.
         - Oturum açma görünümü denetleyicisini GÖSTERMEYECEĞİMİZ İÇİN geçerli değildir. BU NEDENLE HİÇBİR İŞLEM YAPMAYACAĞIZ.
         */
    }
    
    
    
} // FACEBOOK İLE GİRİŞ ENTEGRASYONU








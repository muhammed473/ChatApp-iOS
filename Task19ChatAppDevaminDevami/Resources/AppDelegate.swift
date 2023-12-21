//
//  AppDelegate.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//


import UIKit
import FirebaseCore
import GoogleSignIn

import FacebookLogin
import FacebookCore
import FirebaseAuth


    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
     
       
        
       func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions:  [UIApplication.LaunchOptionsKey: Any]?)  -> Bool {
            
            FirebaseApp.configure()
            
            ApplicationDelegate.shared.application(
                application,
                didFinishLaunchingWithOptions: launchOptions)
            
            /*
               guard let clientID = FirebaseApp.app()?.options.clientID else {
                   fatalError("No client Id found in firebase configuration,( Firebase yapılandırmasında kullanıcı kimliği bulunamadı.)")
               }
               let config = GIDConfiguration(clientID: clientID)
               GIDSignIn.sharedInstance.configuration = config
               
               guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, // Google Oturum açma akışını sunum görünümü denetleyicisine şimdi referans sunuyoruz.
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController else {
                   print("There is no root view controller.(Kök görünüm denetleyicisi yok.)")
                   return false
               }
               
               do{
                   let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) // Eş zamansız çağrıyoruz.
                   let user = userAuthentication.user
                   guard let idToken = user.idToken else {
                       print("İd tokeni alırken hata alındı.")
                       return false
                   }
                   
                   let accessToken = user.accessToken
                   let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                   let result = try await Auth.auth().signIn(with: credential)
                   let firebaseUser = result.user
                   print(" User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
                   return true
               }
               
               catch{
                   print(error.localizedDescription)
                   return false
               } */ // Firebase Youtube kanalındaki kişinin yazdığı kodlar
            
           guard let clientID = FirebaseApp.app()?.options.clientID else { return false }
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
           
           GIDSignIn.sharedInstance.restorePreviousSignIn { // Google'ı kullanarak zaten oturum açmış olan kullanıcıların oturum açma durumunu kontrol etmek için bu metodu kullandık.
                (user,error)  in
                
                if error != nil || user == nil {
                    // Uygulamanın oturumunun KAPALI durumunu gösterir.
                    print("Google oturumun KAPALI")
                }
                else{
                    // Uygulamanın oturumunun AÇIK durumunu gösterir.
                    print("Google oturumun AÇIK")
                }
            }
            
            
            return true
        }
        
     
       func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        ApplicationDelegate.shared.application( // Bu FACEBOOK ENTEGRASYONUNDA Facebook Dokumanından eklediğimiz KOD BLOĞUDUR.
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance.handle(url)
        
        
    }
        
        
        
      
        
    }
    



    




//
//  AppDelegate.swift
//  Task19ChatAppDevaminDevami
//
//  Created by muhammed dursun on 12.12.2023.
//

import UIKit
import FirebaseCore
import FacebookCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions:  [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            FirebaseApp.configure()
            
            ApplicationDelegate.shared.application(
                application,
                didFinishLaunchingWithOptions: launchOptions
            )
            
            GIDSignIn.sharedInstance.restorePreviousSignIn {
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
            
            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
            
            var handled : Bool
            handled = GIDSignIn.sharedInstance.handle(url)
            if handled {
                return true
            }
            
            // Diğer özel URL türlerini yönetin.
            
            return false // Bu uygulama tarafından işlenmezse false değerini döndür demiş olduk.
        }
    }
    
}


    




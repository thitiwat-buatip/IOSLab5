//
//  ViewController.swift
//  IOSLab5
//
//  Created by Thitiwat on 4/25/2560 BE.
//  Copyright © 2560 Thitiwat. All rights reserved.
//

import UIKit
import GoogleSignIn
import Google
import FBSDKLoginKit
import FirebaseCore
import FirebaseAuth
import Firebase
import FirebaseDatabase

class ViewController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate {

    var ref : FIRDatabaseReference?
    override func viewDidLoad() {
        super.viewDidLoad()
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError!)")
        ref = FIRDatabase.database().reference()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Error : \(String(describing: error))")
            }
            else if result?.isCancelled == true {
                print("User canceled")
            }
                
            else {
                print("Successfully")
                self.performSegue(withIdentifier: "login", sender: nil)
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.FirebaseAuth(credential)
            
            }
        }

    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
            // [END_EXCLUDE]
        } else {
            guard let authentication = user.authentication else { return }
            let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                              accessToken: authentication.accessToken)
            self.FirebaseAuth(credential)
        }
            
            performSegue(withIdentifier: "login", sender: nil)
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // [START_EXCLUDE]
            print("USERID : \(userId!)")
            print("FullName : \(fullName!)")
            print("GivenName : \(givenName!)")
            print("FamilyName : \(familyName!)")
            print("Email : \(email!)")
                        NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "Signed in user:\n\(fullName!)"])
            // [END_EXCLUDE]
    }
    
    
    func FirebaseAuth(_ credential : FIRAuthCredential){
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Error : \(String(describing: error))")
            }
            else {
                print("Successfully with Firebase")
                if let user = user {
                    let userData = ["UserID" : user.uid]
                    self.ref?.child("User").updateChildValues(userData)
                    UserDefaults.standard.set(user.uid, forKey: "userid")
                    
                }
            }
        })
    }
    
    func getIpFromHostname() {
        
        let host = CFHostCreateWithName(nil,"www.google.co.th" as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
            for case let theAddress as NSData in addresses {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    print("IP address : \(numAddress)")
                }
            }
        }
        
    }
    
}



//
//  LoginViewController.swift
//  Blockchain-Medical
//
//  Created by Matthew Carrington-Fair on 4/23/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firestore

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var login: RoundButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    //var iserror: Bool = false
    var errorString: String = ""
    
    override func viewDidLoad() {
        var linesize: CGFloat
        var offset: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            linesize = 1/3
            offset = 1.1
        }else{
            linesize = 1/2
            offset = 1.3
        }
        super.viewDidLoad()
        usernameView.center = CGPoint(x: self.view.center.x * offset, y: self.view.center.y * 1.25)
        let bottomLine1 = CALayer()
        bottomLine1.frame = CGRect(x: 0.0, y: 20, width: UIScreen.main.bounds.width * linesize, height: 1.0)
        bottomLine1.backgroundColor = UIColor.white.cgColor
        usernameView.borderStyle = UITextBorderStyle.none
        usernameView.layer.addSublayer(bottomLine1)
        passwordView.center = CGPoint(x: self.view.center.x * offset, y: self.view.center.y * 1.35)
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: 20, width: UIScreen.main.bounds.width * linesize, height: 1.0)
        bottomLine2.backgroundColor = UIColor.white.cgColor
        passwordView.borderStyle = UITextBorderStyle.none
        passwordView.layer.addSublayer(bottomLine2)
        login.center = CGPoint(x: self.view.center.x, y: self.view.center.y * 1.6)
        errorLabel.text = "Login username or password incorrect"
        errorLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y * 1.45)
        self.errorLabel.isHidden = true
        logo.center = CGPoint(x: self.view.center.x, y: self.view.center.y * 1/2)
    }

    @IBAction func loginAction() {
        if let email = usernameView.text, let pass = passwordView.text {
            Auth.auth().signIn(withEmail: email, password: pass, completion: {(currUser, error) in
                if let u = currUser {
                    //self.errorLabel.isHidden = true
                    print(u)
                    let db = Firestore.firestore()
                    db.collection("users").document(u.uid).getDocument {
                        (document, error) in
                        if document?.data()["type"] as! String == "clinician" {
                            self.performSegue(withIdentifier: "pickPatient", sender: nil)
                        } else {
                           user = u.uid
                           self.performSegue(withIdentifier: "goToHome", sender: nil)
                        }
                        userName = document?.data()["name"] as! String
                        print(userName)
                    }
                }
                else {
                    self.errorLabel.isHidden = false
                    //self.iserror = true;
                    self.errorString = self.usernameView.text!
                    print("No user")
                    return
                }
                })
                
        }

//       let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
//        appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
    }
    
    @IBAction func emptyUser(_ sender: Any) {
        if usernameView.text != errorString {
            self.errorLabel.isHidden = true
        }
    }

    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

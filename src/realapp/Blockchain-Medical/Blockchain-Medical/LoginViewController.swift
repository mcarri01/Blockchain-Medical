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
    override func viewDidLoad() {
        var linesize: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            linesize = 1/3
        }else{
            linesize = 1/2
        }
        super.viewDidLoad()
        usernameView.center = CGPoint(x: self.view.center.x * 3/4, y: self.view.center.y * 1.25)
        let bottomLine1 = CALayer()
        bottomLine1.frame = CGRect(x: 0.0, y: 20, width: UIScreen.main.bounds.width * linesize, height: 1.0)
        bottomLine1.backgroundColor = UIColor.white.cgColor
        usernameView.borderStyle = UITextBorderStyle.none
        usernameView.layer.addSublayer(bottomLine1)
        passwordView.center = CGPoint(x: self.view.center.x * 3/4, y: self.view.center.y * 1.35)
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: 20, width: UIScreen.main.bounds.width * linesize, height: 1.0)
        bottomLine2.backgroundColor = UIColor.white.cgColor
        passwordView.borderStyle = UITextBorderStyle.none
        passwordView.layer.addSublayer(bottomLine2)
        login.center = CGPoint(x: self.view.center.x, y: self.view.center.y * 1.6)
        //login.cornerRadius = login.frame.size.width * 1/2 
        //let border = CALayer()
        //let width = CGFloat(2.0)
        
        //border.borderColor  = UIColor.darkGray.cgColor
        //border.frame = CGRect(x: 0, y: usernameView.frame.size.height - width, width: usernameView.frame.size.width, height: usernameView.frame.size.height)
        
        //border.borderWidth = width
        //usernameView.layer.addSublayer(border)
        //passwordView.layer.addSublayer(border)
        // Do any additional setup after loading the view.
    }

    @IBAction func loginAction() {
        if let email = usernameView.text, let pass = passwordView.text {
            Auth.auth().signIn(withEmail: email, password: pass, completion: {(currUser, error) in
                if let u = currUser {
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
                    }
                }
                else {
                    print("No user")
                    return
                }
                })
                
        }
//       let appDelegateTemp = UIApplication.shared.delegate as? AppDelegate
//        appDelegateTemp?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
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

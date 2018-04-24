//
//  LoginViewController.swift
//  Blockchain-Medical
//
//  Created by Matthew Carrington-Fair on 4/23/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor  = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: usernameView.frame.size.height - width, width: usernameView.frame.size.width, height: usernameView.frame.size.height)
        
        border.borderWidth = width
        usernameView.layer.addSublayer(border)
        passwordView.layer.addSublayer(border)
        // Do any additional setup after loading the view.
    }

    @IBAction func loginAction() {
        if let email = usernameView.text, let pass = passwordView.text {
            Auth.auth().signIn(withEmail: email, password: pass, completion: {(user, error) in
                if let u = user {
                    print(u)
                   self.performSegue(withIdentifier: "goToHome", sender: nil)
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? VitalViewController {
//            vc.user = usernameView.text!
//        }
//    }
    
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

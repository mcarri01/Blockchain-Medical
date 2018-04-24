//
//  SettingsViewController.swift
//  Blockchain-Medical
//
//  Created by Matthew Carrington-Fair on 4/24/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import Firestore
import FirebaseAuth

class SettingsViewController: UIViewController {

    @IBAction func logoutAction() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
        performSegue(withIdentifier: "logout", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

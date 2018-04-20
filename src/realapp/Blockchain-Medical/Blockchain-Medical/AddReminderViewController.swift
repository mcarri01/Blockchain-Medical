//
//  AddReminderViewController.swift
//  Blockchain-Medical
//
//  Created by Ben Francis on 4/19/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import Firestore

class AddReminderViewController: UIViewController {

    @IBOutlet weak var input: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func saveReminder(_ sender: UIBarButtonItem) {
        let db = Firestore.firestore()
        db.collection("reminders").addDocument(data:
        ["title": input.text]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added successfully")
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? FirstViewController {
//            let db = Firestore.firestore()
//            db.collection("reminders").addDocument(data:
//            ["title": input.text]) { err in
//                if let err = err {
//                    print("Error adding document: \(err)")
//                } else {
//                    print("Document added successfully")
//                }
//            }
//            vc.reminders.append(input.text!)
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

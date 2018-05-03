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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tableTitle: UILabel!
    @IBOutlet weak var settingTable: UITableView!
    @IBOutlet weak var slider: UISwitch!
    
    var permissions: [(clinician: String, permission : Bool)] = []
    
    @IBAction func logoutAction() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
        isClinician = false
        user = ""
        userName = ""
        performSegue(withIdentifier: "logout", sender: nil)
    }
    
    var clinicians = [(name: String, id: String)]()
    
    private func loadList() {
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).getDocument {
            (document, error) in
            if let document = document, document.exists {
                
                let list = document.data()["clinicians"] as! NSArray
                for elem in list {
                    db.collection("users").document(elem as! String).getDocument { (doc, error) in
                        if let doc = doc, document.exists {
                            let data = doc.data()
                            self.clinicians.append((name: data["name"] as! String, id: elem as! String))
                            self.settingTable.reloadData()
                        }
                        else {
                            print("Error fetching documents: \(String(describing: error))")
                            return
                        }
                    }
                }
                let p =  document.data()["permissions"] as! NSArray
                print(p)
                for entry in p {
                    let e  = entry as! [String:Bool]
                    for (key, val) in e {
                        self.permissions.append((clinician: key, permission: val))
                    }
                }
                
            }
            else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
        }
        
    }
    
   //let clinicians = ["Tom", "Emma", "Ben"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = userName
        if isClinician == false {
            tableTitle.text = "Clinician Permision"
            settingTable.delegate = self
            settingTable.dataSource = self
            loadList()
           
        } else{
            tableTitle.isHidden = true
            settingTable.isHidden = true
            
        }
        
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clinicians.count
    }
    // patient has a list of clinicians [active, not active, active]
    // clinician has a list of patients [not active, active, active]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clinicianCell", for: indexPath)
        cell.textLabel?.text = clinicians[indexPath.row].name
        let id = clinicians[indexPath.row].id
        let pList = permissions.filter { $0.0 == id}
        if pList[0].permission {

            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
  

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        var checked = false
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        }else{
            checked = true
            cell?.accessoryType = .checkmark
        }
        permissions[indexPath.row].permission = checked
        let patientData: [String: Any] = [
            "name": userName,
            "type": "patient",
            "clinicians": clinicians.map{$0.1},
            "permissions": permissions.map{[$0.clinician : $0.permission]}]
        let db = Firestore.firestore()
        _ = db.collection("users").document(user).setData(patientData)
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

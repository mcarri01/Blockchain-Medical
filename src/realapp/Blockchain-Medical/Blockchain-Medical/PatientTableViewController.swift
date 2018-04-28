//
//  PatientTableViewController.swift
//  Blockchain-Medical
//
//  Created by Matthew Carrington-Fair on 4/27/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import Firestore
import FirebaseAuth

class PatientTableViewController: UITableViewController{
    

    @IBOutlet var memberTable: UITableView!
    var patients = [(name: String, id: String)]()
    
    private func loadList() {
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser?.uid as! String).getDocument {
            (document, error) in
            if let document = document, document.exists {
                
                let list = document.data()["patients"] as! NSArray
                for elem in list {
                    db.collection("users").document(elem as! String).getDocument { (doc, error) in
                        if let doc = doc, document.exists {
                            let data = doc.data()
                            self.patients.append((name: data["name"] as! String, id: elem as! String))
                            self.memberTable.reloadData()
                        }
                        else {
                            print("Error fetching documents: \(String(describing: error))")
                            return
                        }
                    }
                }
            }
            else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return patients.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientCell", for: indexPath)
        cell.textLabel?.text = patients[indexPath.row].name
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "goToHome", sender: cell)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        user = patients.filter{ $0.0 == cell.textLabel?.text as! String }[0].id
        print(user)
        isClinician = true
    }
    
}


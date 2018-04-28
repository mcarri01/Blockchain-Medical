//
//  TableViewController.swift
//  Blockchain-Medical
//
//  Created by Matthew Carrington-Fair on 4/16/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import Firestore
import FirebaseAuth

class ClinicianViewController: UITableViewController{

    let typeSwap: [String: String] = ["clinician": "patients", "patient": "clinicians"]
    @IBOutlet var memberTable: UITableView!
    var members = [(name: String, id: String)]()
    
    private func loadList() {
        let db = Firestore.firestore()
        
        db.collection("users").document(user).getDocument {
            (document, error) in
            if let document = document, document.exists {
                let type = document.data()["type"] as! String
                let list = document.data()[self.typeSwap[type]!] as! NSArray
                for elem in list {
                    db.collection("users").document(elem as! String).getDocument { (doc, error) in
                        if let doc = doc, document.exists {
                            let data = doc.data()
                            self.members.append((name: data["name"] as! String, id: elem as! String))
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
        return members.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clinicianCell", for: indexPath)
        cell.textLabel?.text = members[indexPath.row].name
        

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "chat", sender: cell)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let senderCell = sender as! UITableViewCell
        if let vc = segue.destination as? MessagesViewController {
            vc.title = senderCell.textLabel?.text
            vc.receiverId = members.filter{ $0.0 == senderCell.textLabel?.text}[0].id
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}

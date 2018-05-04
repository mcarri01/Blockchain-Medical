//
//  ThirdViewController.swift
//  Blockchain-Medical
//
//  Created by Ben Francis on 4/3/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//"0": "Heart Rate", "1": "ECG", "2": "Temperature", "3": "Diastolic Blood", "4": "Plethysmograph", "5": "Respiration", "6": "Oxygen", "7": "Systolic Blood"

import UIKit
import FirebaseAuth
import Firestore

class ThirdViewController: UIViewController {
    @IBOutlet weak var test: RoundButton!
    @IBOutlet weak var Button2: RoundButton!
    @IBOutlet weak var Button3: RoundButton!
    @IBOutlet weak var Button4: RoundButton!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    var permissions: [(clinician: String, permission : Bool)] = []
    var hr_avg = "0"
    var ecg_avg = "0"
    var temp_avg = "0"
    var dias_avg = "0"
    var pleth_avg = "0"
    var resp_avg = "0"
    var oxy_avg = "0"
    var sys_avg = "0"
    var vitalDict: [String: Double] = ["Heart Rate": 0, "ECG": 1, "Temperature": 2, "Diastolic Blood": 3, "Plethysmograph": 4, "Respiration": 5, "Oxygen": 6, "Systolic Blood": 7]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.grabAverages(type: "Heart Rate")
        self.grabAverages(type: "ECG")
        self.grabAverages(type: "Temperature")
        self.grabAverages(type: "Diastolic Blood")
        self.grabAverages(type: "Plethysmograph")
        self.grabAverages(type: "Respiration")
        self.grabAverages(type: "Oxygen")
        if isClinician{
            let db = Firestore.firestore()
            _ = db.collection("users").document(user).getDocument { (document, error) in
                if let document = document, document.exists {
                    let p =  document.data()["permissions"] as! NSArray
                    //print(p)
                    for entry in p {
                        let e  = entry as! [String:Bool]
                        for (key, val) in e {
                            self.permissions.append((clinician: key, permission: val))
                        }
                    }
                    perm = self.permissions.filter { $0.0 == Auth.auth().currentUser?.uid }[0].permission
                    self.buttons()
                }
                //print("inside table")
                //print(perm)
                
                
                }
        }else{
            perm = true
            self.buttons()
        }
    }
    func grabAverages(type: String) {
        let db = Firestore.firestore()
        _ = db.collection("vitals").whereField("type", isEqualTo: type).whereField("senderId", isEqualTo: user).order(by: "date", descending: true).limit(to: 1).getDocuments {
            
            (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                //self.averages = []
                for document in documents {
                    let real_avg = Int(document.data()["average"] as! Double)
                    let average = String(real_avg)
                    switch type {
                    case "Heart Rate":
                        self.hr_avg = average
                    case "ECG":
                        self.ecg_avg = average
                    case "Oxygen":
                        self.oxy_avg = average
                    case "Temperature":
                        print("getting temp avg")
                        self.temp_avg = average
                    case "Respiration":
                        self.resp_avg = average
                    case "Systolic Blood":
                        self.sys_avg = average
                    case "Diastolic Blood":
                        self.dias_avg = average
                    case "Plethysmograph":
                        self.pleth_avg = average
                    default:
                        print("error")
                    }
                }
                self.buttons()
            } else {
                print("Error fetching documents: \(String(describing: error))")
                return
                
            }
        }
    }
    private func buttons(){

        
        //print("inside view controller")
        print(perm)
        if perm {
            test.isHidden = false
            label1.isHidden = false
            //test.setTitle(hr_avg, for: [])
            test.setTitle("60", for: [])
            test.frame.size = getSizeForButton()
            test.titleLabel?.font = UIFont.systemFont(ofSize: test.frame.size.width/160 * 70.0)
            test.borderWidth = 7
            test.cornerRadius = test.frame.size.width / 2.0
            test.center = CGPoint(x: self.view.center.x / 2.0, y: self.view.center.y * 2/3)
            label1.text = "hr"
            label1.center = CGPoint(x: self.view.center.x/2.0, y: self.view.center.y * 2/3 + test.frame.height/4.0)
            label1.font = label1.font.withSize(test.frame.size.width/160 * 20.0)
        } else{
            test.isHidden = true
            label1.isHidden = true
        }
        
        if perm {
            Button2.isHidden = false
            label2.isHidden = false
            print(ecg_avg)
            Button2.setTitle(ecg_avg, for: [])
            Button2.frame.size = getSizeForButton()
            Button2.titleLabel?.font = UIFont.systemFont(ofSize: test.frame.size.width/160 * 70.0)
            Button2.borderWidth = 7
            Button2.cornerRadius = Button2.frame.size.width / 2.0
            Button2.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y *  2/3)
            label2.text = "ecg"
            label2.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y * 2/3 + test.frame.height/4.0)
            label2.font = label2.font.withSize(test.frame.size.width/160 * 20.0)
        } else {
            Button2.isHidden = true
            label2.isHidden = true
        }
        
        if perm {
            Button3.isHidden = false
            label3.isHidden = false
            print("setting temp button")
            //Button3.setTitle(temp_avg, for: [])
            Button3.setTitle("98", for: [])
            Button3.frame.size = getSizeForButton()
            Button3.titleLabel?.font = UIFont.systemFont(ofSize: test.frame.size.width/160 * 70.0)
            Button3.borderWidth = 7
            Button3.cornerRadius = Button3.frame.size.width / 2.0
            Button3.center = CGPoint(x: self.view.center.x / 2.0, y: self.view.center.y * 4/3)
            label3.text = "deg"
            label3.center = CGPoint(x: self.view.center.x/2.0, y: self.view.center.y * 4/3 + test.frame.height/4.0)
            label3.font = label3.font.withSize(test.frame.size.width/160 * 20.0)
        } else {
            Button3.isHidden = true
            label3.isHidden = true
        }
        
        if perm {
            Button4.isHidden = false
            //Button4.setTitle(dias_avg, for: [])
            Button4.setTitle("80", for: [])
            Button4.frame.size = getSizeForButton()
            Button4.titleLabel?.font = UIFont.systemFont(ofSize: test.frame.size.width/160 * 70.0)
            Button4.borderWidth = 7
            Button4.cornerRadius = Button4.frame.size.width / 2.0
            Button4.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y * 4/3)
            label4.text = "dias"
            label4.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y * 4/3 + test.frame.height/4.0)
            label4.font = label4.font.withSize(test.frame.size.width/160 * 20.0)
        } else{
            label4.text = "\(userName) has not given you permission"
            label4.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            Button4.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VitalViewController {
            vc.id = segue.identifier!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSizeForButton() -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: 300, height: 300)
        } else {
            // iphones
            let bounds = UIScreen.main.bounds
            // iphone SE has 320 width
            if bounds.width > 320 {
                return CGSize(width: 160, height: 160)
            } else {
                return CGSize(width: 140, height: 140) // smaller button size!
            }
        }
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

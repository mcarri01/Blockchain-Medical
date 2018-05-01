//
//  FourthViewController.swift
//  Blockchain-Medical
//
//  Created by Diana Whealan on 4/7/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import Firestore
import FirebaseAuth

class FourthViewController: UIViewController{
    
    @IBOutlet weak var Button5: RoundButton!
    @IBOutlet weak var Button6: RoundButton!
    @IBOutlet weak var Button7: RoundButton!
    @IBOutlet weak var Button8: RoundButton!
    
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    //@IBOutlet weak var label7: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Button5.frame.size = getSizeForButton()
        Button5.setTitle("42", for: [])
        Button5.titleLabel?.font = UIFont.systemFont(ofSize: Button5.frame.size.width/160 * 70.0)
        //Button5.frame.size = getSizeForButton()
        Button5.borderWidth = 7
        Button5.cornerRadius = Button5.frame.size.width / 2.0
        Button5.center = CGPoint(x: self.view.center.x / 2.0, y: self.view.center.y * 2/3)
        label5.text = "pleth"
        label5.center = CGPoint(x: self.view.center.x/2.0, y: self.view.center.y * 2/3 + Button5.frame.height/4.0)
        label5.font = label5.font.withSize(Button5.frame.size.width/160 * 20.0)
        
        Button6.setTitle("532", for: [])
        Button6.frame.size = getSizeForButton()
        Button6.titleLabel?.font = UIFont.systemFont(ofSize: Button5.frame.size.width/160 * 70.0)
        Button6.borderWidth = 7
        Button6.cornerRadius = Button6.frame.size.width / 2.0
        Button6.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y *  2/3)
        label6.text = "resp"
        label6.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y * 2/3 + Button5.frame.height/4.0)
        label6.font = label6.font.withSize(Button5.frame.size.width/160 * 20.0)
        
        Button7.setTitle("12", for: [])
        Button7.frame.size = getSizeForButton()
        Button7.titleLabel?.font = UIFont.systemFont(ofSize: Button5.frame.size.width/160 * 70.0)
        Button7.borderWidth = 7
        Button7.cornerRadius = Button7.frame.size.width / 2.0
        Button7.center = CGPoint(x: self.view.center.x / 2.0, y: self.view.center.y * 4/3)
        label7.text = "SP02"
        label7.center = CGPoint(x: self.view.center.x/2.0, y: self.view.center.y * 4/3 + Button5.frame.height/4.0)
        label7.font = label7.font.withSize(Button5.frame.size.width/160 * 20.0)
        
        Button8.setTitle("5", for: [])
        Button8.frame.size = getSizeForButton()
        Button8.titleLabel?.font = UIFont.systemFont(ofSize: Button5.frame.size.width/160 * 70.0)
        Button8.borderWidth = 7
        Button8.cornerRadius = Button8.frame.size.width / 2.0
        Button8.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y * 4/3)
        label8.text = "sys"
        label8.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y * 4/3 + Button5.frame.height/4.0)
        label8.font = label8.font.withSize(Button5.frame.size.width/160 * 20.0)
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
}

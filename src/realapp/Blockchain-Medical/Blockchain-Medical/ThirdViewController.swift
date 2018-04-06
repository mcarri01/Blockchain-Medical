//
//  ThirdViewController.swift
//  Blockchain-Medical
//
//  Created by Ben Francis on 4/3/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    @IBOutlet weak var test: RoundButton!
    @IBOutlet weak var Button2: RoundButton!
    @IBOutlet weak var Button3: RoundButton!
    @IBOutlet weak var Button4: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test.setTitle("hello", for: [])
        test.frame.size = getSizeForButton()
        
        test.borderWidth = 2
        test.cornerRadius = test.frame.size.width / 2.0
        test.center = CGPoint(x: self.view.center.x / 2.0, y: self.view.center.y / 2.0)
        
        Button2.setTitle("hello", for: [])
        Button2.frame.size = getSizeForButton()
        Button2.cornerRadius = Button2.frame.size.width / 2.0
        Button2.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y / 2.0)
        
        Button3.setTitle("hello", for: [])
        Button3.frame.size = getSizeForButton()
        Button3.cornerRadius = Button3.frame.size.width / 2.0
        Button3.center = CGPoint(x: self.view.center.x / 2.0, y: self.view.center.y * 1.5)
        
        Button4.setTitle("hello", for: [])
        Button4.frame.size = getSizeForButton()
        Button4.cornerRadius = Button4.frame.size.width / 2.0
        Button4.center = CGPoint(x: self.view.center.x * 1.5, y: self.view.center.y * 1.5)
        // Do any additional setup after loading the view.
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
                return CGSize(width: 80, height: 80)
            } else {
                return CGSize(width: 50, height: 50) // smaller button size!
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

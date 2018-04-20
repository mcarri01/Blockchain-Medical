//
//  FirstViewController.swift
//  Blockchain-Medical
//
//  Created by Ben Francis on 4/3/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import CVCalendar
import Firestore

class FirstViewController: UIViewController , CVCalendarViewDelegate, CVCalendarMenuViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var reminders: [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        cell.textLabel?.text = reminders[indexPath.row]
        return cell
    }
    
    
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    private var currentCalendar: Calendar?
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var remindersTable: UITableView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    
    @IBOutlet weak var calendarView: CVCalendarView!
    
    override func awakeFromNib() {
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "us_US")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Schedule"
        if let currentCalendar = currentCalendar {
            dateLabel.text = CVDate(date: Date(), calendar: currentCalendar).globalDescription
        }
        let db = Firestore.firestore()
        _ = db.collection("reminders").addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.reminders = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.reminders.append(data["title"] as! String)
                }
                print(self.reminders)
            }
            self.remindersTable.reloadData()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func previousMonth() {
        calendarView.loadPreviousView()
    }
    @IBAction func nextMonth() {
        calendarView.loadNextView()
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        if dateLabel.text != date.globalDescription {//&& self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = dateLabel.textColor
            updatedMonthLabel.font = dateLabel.font
            updatedMonthLabel.textAlignment = .center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.dateLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            updatedMonthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                //self.animationFinished = false
                self.dateLabel.transform = CGAffineTransform(translationX: 0, y: -offset)
                self.dateLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
                self.dateLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransform.identity
                
            }) { _ in
                
               // self.animationFinished = true
                self.dateLabel.frame = updatedMonthLabel.frame
                self.dateLabel.text = updatedMonthLabel.text
                self.dateLabel.transform = CGAffineTransform.identity
                self.dateLabel.alpha = 1
                updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.dateLabel)
        }
    }

    
}


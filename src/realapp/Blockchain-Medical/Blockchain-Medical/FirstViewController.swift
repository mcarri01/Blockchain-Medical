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
import FirebaseAuth

class FirstViewController: UIViewController , CVCalendarViewDelegate, CVCalendarMenuViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let user = Auth.auth().currentUser!.uid
    var reminders: [(title : String, notes: String, date : Date)] = []
    var dailyReminders: [(title : String, notes: String, date : Date)] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        cell.textLabel?.text = dailyReminders[indexPath.row].title
        cell.detailTextLabel?.text = dateFormatter.string(from: dailyReminders[indexPath.row].date) + "\t" + dailyReminders[indexPath.row].notes
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
        let timeZoneBias = 0//-300 // (UTC-05:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "en_US")
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
        _ = db.collection("reminders").whereField("userID", isEqualTo: user).addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.reminders = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.reminders.append((data["title"] as! String, data["notes"] as! String, data["date"] as! Date))
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
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        dailyReminders = []
        for reminder in reminders {
            if (currentCalendar?.isDate(reminder.date, equalTo: dayView.date.convertedDate()! - 4 * 3600, toGranularity: .day))! {
                dailyReminders.append(reminder)
            }
        }
        remindersTable?.reloadData()
    }
}
    



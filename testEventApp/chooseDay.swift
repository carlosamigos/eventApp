//
//  newEvent.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 27/09/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Firebase

class chooseDay: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var durationPicker: UIPickerView!
    var inCreationEvent: InCreationEvent?
    
    var pickerData: Array<String> = ["Today","Tomorrow"]
    var weekdays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var durations = ["15 min", "30 min", "45 min", "1 hour", "1.5 hours", "2 hours", "2.5 hours", "3 hours", "3.5 hours", "4 hours", "5 hours", "6 hours", "7 hours", "8 hours", "9 hours", "10 hours"]
    var minuteDurations = [15, 30, 45, 60, 90, 120, 150, 180, 210, 240, 300, 360, 420, 480, 540, 600]
    var todaysWeekday: String = ""
    var durationChosen = 15
    var panGestureRecognizer: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        durationPicker.dataSource = self
        durationPicker.delegate = self
        fixDayPickerData()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggablePanGestureAction))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    @IBAction func nextButtonPressed(_ sender: AnyObject) {
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateWeekdays() -> [String]{
        var returnList = [String]()
        let hoursToAddInSeconds: TimeInterval = 24 * 60 * 60 //one day
        var date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = NSLocale.current
        for i in 0...6{
            let convertedDate = dateFormatter.string(from: date as Date).localizedCapitalized
            returnList.append(convertedDate)
            date = date.addingTimeInterval(hoursToAddInSeconds)
        }
        return returnList
    }

    
    func fixDayPickerData(){
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.dateFormat = "EEEE"
        //convertedDate is the weekday
        let convertedDate = dateFormatter.string(from: currentDate as Date).localizedCapitalized
        self.todaysWeekday = convertedDate
        if !self.weekdays.contains(convertedDate){
            self.weekdays = updateWeekdays()
        }
        
        //TODO: FIX TO WORK FOR ALL LANGUAGES
        let indexOfWeekday = self.weekdays.index(of: convertedDate)
        let n = (indexOfWeekday?.toIntMax())!
        
        for i in 2...6 {
            let Index = (i+n)%7
            let day = weekdays[Int(Index)]
            self.pickerData.append(day)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let weekday = self.nextButton.titleLabel?.text
        let date = getDateFromWeekday(weekday: weekday!)
        inCreationEvent?.date = date
        inCreationEvent?.weekDay = weekday
        inCreationEvent?.duration = self.durationChosen
        let secondVC: invitePeopleViewController = segue.destination as! invitePeopleViewController
        secondVC.inCreationEvent = self.inCreationEvent
    }
    
    func getDateFromWeekday(weekday: String) -> Date {
        // use self.weekdays
        var daysForward: Int = 0
        if weekday == "Next" || weekday == "Today" {
            daysForward = 0
        } else if weekday == "Tomorrow" {
            daysForward = 1
        } else {
            let indexOfCurrentDate = self.weekdays.index(of: weekday)
            let indexOfEventDate = self.weekdays.index(of: self.todaysWeekday)
            daysForward = ((indexOfCurrentDate!-indexOfEventDate!)+7)%7
        }
        let currentDate = NSDate()
        let dayComponenet = NSDateComponents()
        dayComponenet.day = daysForward
        let theCalendar = NSCalendar.current
        let nextDate = theCalendar.date(byAdding: dayComponenet as DateComponents, to: currentDate as Date)
        return nextDate!
    }
    
//MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1){
            return self.pickerData.count
        }else if (pickerView.tag == 2){
            return self.durations.count
        }else {
            return 0
        }
        
    }

    //MARK: Delegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        if (pickerView.tag == 1){
            return pickerData[row]
        }else if (pickerView.tag == 2){
            return self.durations[row]
        }else {
            return ""
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if (pickerView.tag == 1){
            let attributedString = NSAttributedString(string: pickerData[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
            return attributedString
        }else if (pickerView.tag == 2){
            let attributedString = NSAttributedString(string: durations[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
            return attributedString
        }else {
            let attributedString = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName : UIColor.white])
            return attributedString
        }
        
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1){
            nextButton.setTitle(pickerData[row], for: UIControlState.normal)
        }else if (pickerView.tag == 2){
            self.durationChosen = minuteDurations[row]
        }else {
            return 
        }
        
        
    }
    
    
    
    
    
    func draggablePanGestureAction(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        view.frame.origin = CGPoint(x: 0, y: max(translation.y, 0) )
        if(translation.y > UIScreen.main.bounds.height * constants.gestureConstants.getureRemoveThreshold){
            view.removeGestureRecognizer(self.panGestureRecognizer)
            backBtnPressed(self)
        } else {
            let velocity = gesture.velocity(in: view)
            if gesture.state == .ended{
                if velocity.y >= constants.gestureConstants.gestureRemoveViewSpeed {
                    view.removeGestureRecognizer(self.panGestureRecognizer)
                    backBtnPressed(self)
                }
                else{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin = CGPoint(x: 0, y: 0)
                    })
                }
            }
        }
    }
    
    
    

}

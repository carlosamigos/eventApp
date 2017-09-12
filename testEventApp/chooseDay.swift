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
    
    var pickerData: Array<String> = ["Today","Tomorrow"]
    var weekdays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var todaysWeekday: String = ""
    var eventTitle: String = ""
    
    
    
     let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        fixPickerData()
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

    
    func fixPickerData(){
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
        let secondVC: timeSelector = segue.destination as! timeSelector
        if let weekday = self.nextButton.titleLabel?.text {
            let dato = getDateFromWeekday(weekday: weekday)
            secondVC.dateFromChooseDay = dato
            secondVC.titleFromPrevView = self.eventTitle
            secondVC.weekday = weekday
        }
        
    }
    
    func getDateFromWeekday(weekday: String) -> Date {
        // use self.weekdays
        print(weekday)
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
        return self.pickerData.count
    }

    //MARK: Delegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: pickerData[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nextButton.setTitle(pickerData[row], for: UIControlState.normal)
    }
    
    
    
    

}

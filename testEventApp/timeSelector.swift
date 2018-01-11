//
//  timeSelector.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 01/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Foundation



class timeSelector: UIViewController {
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    var dateFromChooseDay: Date = Date()
    var titleFromPrevView: String = ""
    var weekday: String = ""
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 5
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggablePanGestureAction))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondVC: locationSelector = segue.destination as! locationSelector
        secondVC.dateFromChooseDay = self.dateFromChooseDay
        secondVC.titleFromPrevView = self.titleFromPrevView
        timePicker.datePickerMode = UIDatePickerMode.time
        let dateFormatter = DateFormatter()
        let desc = timePicker.date.description as NSString
        if  desc.contains("am") || desc.contains("AM") || desc.contains("pm") || desc.contains("PM"){
            dateFormatter.dateFormat = "h:mm a"
            let newDate = dateFormatter.date(from: desc as String)
            dateFormatter.dateFormat = "HH:mm"
            let selectedDate = dateFormatter.string(from: newDate!)
            secondVC.hourMin = selectedDate
        }
        else {
            dateFormatter.dateFormat = "HH:mm"
            let selectedDate = dateFormatter.string(from: timePicker.date)
            secondVC.hourMin = selectedDate
        }
        secondVC.weekday = self.weekday
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }

    @IBAction func nextBtnPressed(_ sender: AnyObject) {
    }
   
    @IBAction func timeChanged(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        let desc = timePicker.date.description as NSString
        if  desc.contains("am") || desc.contains("AM") || desc.contains("pm") || desc.contains("PM"){
            dateFormatter.dateFormat = "h:mm a"
            let selectedDate = dateFormatter.string(from: timePicker.date)
            self.nextBtn.setTitle(selectedDate, for: UIControlState.normal)
            
        }
        else {
            dateFormatter.dateFormat = "HH:mm"
            let selectedDate = dateFormatter.string(from: timePicker.date)
            self.nextBtn.setTitle(selectedDate, for: UIControlState.normal)
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

//
//  ViewController.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-11.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - Variables and Properties
    @IBOutlet weak var headerDateLabel: UILabel!
    @IBOutlet weak var weekView: UIStackView!
    @IBOutlet weak var divider: UIView!
    
    //MARK: - Class Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeader()
        setupWeekView()
        setupDivider()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreActions(touch:)))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
    }
    
    @objc func showMoreActions(touch: UITapGestureRecognizer){
        print(touch.location(in: view))
    }

    private func setupHeader(){
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let formattedDate = formatter.string(from: Date())
        headerDateLabel.text = formattedDate
    }
    
    private func setupDivider(){
        divider.layer.shadowOpacity = 0.4
        divider.layer.shadowOffset = CGSize(width: 0, height: 2)
        divider.layer.shadowRadius = 1
        divider.layer.shadowColor = UIColor(named: "PrimaryPurpleColor")?.cgColor
    }
    
    private func setupWeekView(){
        let dates = getWeek()
        let today = getDay(date: Date())
        for i in 0...weekView.subviews.count-1{
            let dateStackContainer = weekView.subviews[i]
            guard let dateStack = dateStackContainer.subviews.first as? UIStackView else {return}
            
            weekView.frame = CGRect(origin: weekView.frame.origin, size: CGSize(width: weekView.frame.width, height: dateStack.frame.width))
            
            dateStack.frame = CGRect(origin: dateStack.frame.origin, size: CGSize(width: dateStack.frame.width, height: dateStack.frame.width))
            
            if dates[i] == today{
                // Highlight day of week
                if let dayOfWeekLabel = dateStack.subviews.first as? UILabel{
                    dayOfWeekLabel.textColor = UIColor(named: "PrimaryBlackColor")
                }
                
                // Create background mask
//                let origin = weekView.convert(dateStack.frame.origin, to: view)
//                let origin = dateStack.bounds.origin
//                var dimen : CGFloat?
//                if dateStack.bounds.height >= dateStack.bounds.width {
//                    dimen = dateStack.bounds.height
//                }else{
//                    dimen = dateStack.bounds.width
//                }
//                let backgroundMask = UIView(frame: CGRect(x: 0.0, y: 0.0, width: dimen!, height: dimen!))
//                backgroundMask.layer.cornerRadius = dimen! / 2
//                backgroundMask.backgroundColor = UIColor(named: "SecondaryPurpleColor")
//                view.insertSubview(backgroundMask, belowSubview: weekView)
//                backgroundMask.center = weekView.convert(dateStack.center, to: view)
                dateStackContainer.backgroundColor = UIColor(named: "SecondaryPurpleColor")
                dateStackContainer.layer.cornerRadius = dateStackContainer.frame.width / 2
            }
            
            // Update the date label
            if let dateLabel = dateStack.subviews.last as? UILabel{
                dateLabel.text = dates[i]
            }
        }
    }
    
    private func getWeek() -> [String]{
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        let fullDates = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
            .compactMap { calendar.date(byAdding: .day, value: $0-dayOfWeek, to: today) }
        let dates = fullDates.map { date in
            getDay(date: date)
        }
        return dates
    }
    
    private func getDay(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

}

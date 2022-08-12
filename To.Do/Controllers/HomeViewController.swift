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
            
            if dates[i] == today{
                // Highlight day of week
                if let dayOfWeekLabel = dateStack.subviews.first as? UILabel{
                    dayOfWeekLabel.textColor = UIColor(named: "PrimaryBlackColor")
                }
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

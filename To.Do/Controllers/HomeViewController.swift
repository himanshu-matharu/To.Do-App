//
//  ViewController.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-11.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - Variables and Properties
    enum Section {
        case todo(items: [Todo])
        case done(items: [Todo])
    }
    
    @IBOutlet weak var headerDateLabel: UILabel!
    @IBOutlet weak var weekView: UIStackView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var newTodoTrigger: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let DUMMY_TODOS = [
        Todo(id: 0, text: "Meet Ann", isDone: false, highPriority: false, reminder: "8:00 PM"),
        Todo(id: 1, text: "Buy the book", isDone: false, highPriority: false, reminder: nil),
        Todo(id: 2, text: "Call mom", isDone: false, highPriority: false, reminder: nil),
        Todo(id: 3, text: "Make an appointment", isDone: false, highPriority: true, reminder: "11:00 AM"),
        Todo(id: 4, text: "Visit the University campus", isDone: true, highPriority: false, reminder: nil),
        Todo(id: 5, text: "Buy fruits", isDone: true, highPriority: true, reminder: "3:00 PM")
    ]
    
    private var tableDataSource = [Section]()
    
    //MARK: - Class Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeader()
        setupWeekView()
        setupDivider()
        setupNewToDoTrigger()
        setupTableView()
        
    }

    private func setupHeader(){
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let formattedDate = formatter.string(from: Date())
        headerDateLabel.text = formattedDate
    }
    
    private func setupDivider(){
        divider.layer.shadowOpacity = 0.8
        divider.layer.shadowOffset = CGSize(width: 0, height: 2)
        divider.layer.shadowRadius = 1
        divider.layer.shadowColor = UIColor(named: "PrimaryPurpleColor")?.cgColor
    }
    
    private func setupNewToDoTrigger(){
        newTodoTrigger.layer.borderColor = UIColor(named: "PrimaryPurpleColor")?.cgColor
        newTodoTrigger.layer.borderWidth = 1
        newTodoTrigger.layer.shadowOpacity = 0.4
        newTodoTrigger.layer.shadowOffset = CGSize(width: 0, height: 2)
        newTodoTrigger.layer.shadowRadius = 4
        newTodoTrigger.layer.shadowColor = UIColor(named: "PrimaryGrayColor")?.cgColor
        newTodoTrigger.layer.cornerRadius = 5
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
    
    private func setupTableView(){
        tableDataSource = createDataSource()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.todoCellNibName, bundle: nil), forCellReuseIdentifier: K.todoCellIdentifier)
        tableView.register(UINib(nibName: K.todoDoneCellNibName, bundle: nil), forCellReuseIdentifier: K.todoDoneCellIdentifier)
        tableView.sectionHeaderTopPadding = 0
    }

}

//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        tableDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableDataSource[section] {
        case .todo(let items): return items.count
        case .done(let items): return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = tableDataSource[indexPath.section]
        
        switch section{
        case .todo(let items):
            let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellIdentifier,for: indexPath) as? TodoCell
            let item = items[indexPath.row]
            cell?.todoText.text = item.text
            if item.reminder != nil {
                cell?.reminderText.isHidden = false
                cell?.reminderIndicator.isHidden = false
                cell?.reminderText.text = item.reminder
            }else{
                cell?.reminderIndicator.isHidden = true
                cell?.reminderText.isHidden = true
            }
            cell?.priorityIndicator.isHidden = !item.highPriority
            return cell ?? UITableViewCell()
        case .done(let items):
            let cell = tableView.dequeueReusableCell(withIdentifier: K.todoDoneCellIdentifier, for: indexPath) as? TodoDoneCell
            let item = items[indexPath.row]
            cell?.todoText.text = item.text
            return cell ?? UITableViewCell()
        }
    }
}

//MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 20
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        if section == 0{
            return header
        }else{
            return nil
        }
    }
}

//MARK: - Util Functions
private extension HomeViewController{
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
    
    private func createDataSource() -> [Section]{
        let todoInDummy = DUMMY_TODOS.filter { todo in
            !todo.isDone
        }
        let doneInDummy = DUMMY_TODOS.filter { todo in
            todo.isDone
        }
        
        let todoItems = Section.todo(items: todoInDummy)
        let doneItems = Section.done(items: doneInDummy)
        
        return [todoItems,doneItems]
    }
}

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
    @IBOutlet weak var newTodoTrigger: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableContainer: UIView!
    
    private var dataStore = DataStore()
    
    //MARK: - Class Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeader()
        setupWeekView()
        setupDivider()
        setupNewToDoTrigger()
        setupTableView()
        
        dataStore.delegate = self
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
        divider.layer.shadowColor = UIColor(named: "PrimaryGrayColor")?.cgColor
    }
    
    private func setupNewToDoTrigger(){
        newTodoTrigger.layer.borderColor = UIColor(named: "PrimaryPurpleColor")?.cgColor
        newTodoTrigger.layer.borderWidth = 1
        newTodoTrigger.layer.shadowOpacity = 0.4
        newTodoTrigger.layer.shadowOffset = CGSize(width: 0, height: 2)
        newTodoTrigger.layer.shadowRadius = 4
        newTodoTrigger.layer.shadowColor = UIColor(named: "PrimaryGrayColor")?.cgColor
        newTodoTrigger.layer.cornerRadius = 5
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToNewTodo))
        newTodoTrigger.isUserInteractionEnabled = true
        newTodoTrigger.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupWeekView(){
        let dates = getWeek()
        let today = Date().toString(format: "d")
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.todoCellNibName, bundle: nil), forCellReuseIdentifier: K.todoCellIdentifier)
        tableView.register(UINib(nibName: K.todoDoneCellNibName, bundle: nil), forCellReuseIdentifier: K.todoDoneCellIdentifier)
        tableView.sectionHeaderTopPadding = 0
        
        checkEmptyTableView()
    }
    
    @objc private func goToNewTodo(){
        self.performSegue(withIdentifier: K.newTodoSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.newTodoSegue {
            let destination = segue.destination as! NewTodoViewController
            if let sender = sender as? HomeViewController{
                destination.dataStore = sender.dataStore
            }else{
                guard let sender = sender as? IndexPath,
                      let tableDataSource = dataStore.tableDataSource
                else {return}
                let section = tableDataSource[sender.section]
                switch section{
                case .todo(let items):
                    let itemToEdit = items[sender.row]
                    destination.itemToEdit = itemToEdit
                    destination.section = section
                    destination.index = sender.row
                    destination.dataStore = self.dataStore
                case .done(_):
                    break
                }
            }
        }
    }
    
    private func checkEmptyTableView(){
        let count = dataStore.getTotalDataCount()
        if count == 0{
            self.tableView.isHidden = true
            self.emptyTableContainer.isHidden = false
        }else{
            self.tableView.isHidden = false
            self.emptyTableContainer.isHidden = true
        }
    }

}

//MARK: - Util Methods
private extension HomeViewController{
    private func getWeek() -> [String]{
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        let fullDates = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
            .compactMap { calendar.date(byAdding: .day, value: $0-dayOfWeek, to: today) }
        let dates = fullDates.map { date in
            date.toString(format: "d")
        }
        return dates
    }
}

//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let tableDataSource = dataStore.tableDataSource else {return 0}
        return tableDataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableDataSource = dataStore.tableDataSource else {return 0}
        switch tableDataSource[section] {
        case .todo(let items):
            return items.count
        case .done(let items):
            return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableDataSource = dataStore.tableDataSource else {return UITableViewCell()}
        let section = tableDataSource[indexPath.section]
        let dayStartToday = Calendar.current.startOfDay(for: Date())
        let dayEndToday = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
        
        switch section{
        case .todo(let items):
            let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellIdentifier,for: indexPath) as? TodoCell
            let item = items[indexPath.row]
            cell?.todoText.text = item.text
            
            if Calendar.current.isDateInToday(item.dueBy!) && (item.dueBy != dayEndToday) {
                cell?.dueByText.isHidden = false
                cell?.dueByText.text = item.dueBy!.toString(format: "HH:mm")
            }else{
                cell?.dueByText.isHidden = true
            }
            
            cell?.priorityIndicator.isHidden = !item.highPriority
            cell?.priorityIndicator.backgroundColor = UIColor(named: "PrimaryGreenColor")
            
            if item.dueBy! < dayStartToday {
                cell?.priorityIndicator.isHidden = false
                cell?.priorityIndicator.backgroundColor = UIColor(named: "PrimaryRedColor")
            }
            
            let tap = CustomTableViewCellTapGestureRecognizer(target: self, action: #selector(toggleTodo(_:)))
            tap.section = section
            tap.indexPath = indexPath
            cell?.toggleView.isUserInteractionEnabled = true
            cell?.toggleView.addGestureRecognizer(tap)
            
            cell?.clipsToBounds = false
            cell?.contentView.clipsToBounds = false
            
            return cell ?? UITableViewCell()
        case .done(let items):
            let cell = tableView.dequeueReusableCell(withIdentifier: K.todoDoneCellIdentifier, for: indexPath) as? TodoDoneCell
            let item = items[indexPath.row]
            cell?.todoText.text = item.text
            
            let tap = CustomTableViewCellTapGestureRecognizer(target: self, action: #selector(toggleTodo(_:)))
            tap.section = section
            tap.indexPath = indexPath
            cell?.toggleView.isUserInteractionEnabled = true
            cell?.toggleView.addGestureRecognizer(tap)
            
            return cell ?? UITableViewCell()
        }
    }
    
    @objc func toggleTodo(_ sender: CustomTableViewCellTapGestureRecognizer){
        guard let section = sender.section,
              let indexPath = sender.indexPath
        else {return}
        switch section {
        case .todo(_):
            guard let cellTapped = tableView.cellForRow(at: indexPath) as? TodoCell else {return}
            cellTapped.container.showPressAnimation {
                self.dataStore.toggleTodo(section: section, index: indexPath.row)
            }
        case .done(_):
            guard let cellTapped = tableView.cellForRow(at: indexPath) as? TodoDoneCell else {return}
            cellTapped.container.showPressAnimation {
                self.dataStore.toggleTodo(section: section, index: indexPath.row)
            }
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let tableDataSource = dataStore.tableDataSource else {return nil}
        
        let trash = UIContextualAction(style: .destructive, title: "") { action, view, completionHandler in
            completionHandler(true)
            let section = tableDataSource[indexPath.section]
            switch section {
            case.todo(_):
                self.dataStore.deleteTodo(section: section, index: indexPath.row)
            case.done(_):
                self.dataStore.deleteTodo(section: section, index: indexPath.row)
            }
            self.dataStore.refreshTableDataSource()
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.checkEmptyTableView()
        }
        trash.backgroundColor = UIColor(named: "BackgroundColor")
        trash.image = UIImage(named: "Trash")
        
        let edit = UIContextualAction(style: .normal, title: "") { action, view, completionHandler in
            completionHandler(true)
            self.performSegue(withIdentifier: K.newTodoSegue, sender: indexPath)
        }
        edit.backgroundColor = UIColor(named:"BackgroundColor")
        edit.image = UIImage(named: "Pencil")
        
        let section = tableDataSource[indexPath.section]
        switch section{
        case .todo(_):
            return UISwipeActionsConfiguration(actions: [trash, edit])
        case .done(_):
            return UISwipeActionsConfiguration(actions: [trash])
        }
    }
}

//MARK: - DataStoreDelegate
extension HomeViewController: DataStoreDelegate{
    func didUpdateTableViewDataSource() {
        self.tableView.reloadData()
        self.checkEmptyTableView()
    }
}

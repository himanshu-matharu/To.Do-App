//
//  NewTodoViewController.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-13.
//

import UIKit

class NewTodoViewController: UIViewController{
    
    //MARK: -  Variables and Properties
    @IBOutlet weak var dismissBtn: UIImageView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var prioritySwitch: UISwitch!
    @IBOutlet weak var dueByDatePicker: UIDatePicker!
    @IBOutlet weak var headerLabel: UILabel!
    
    var dataStore: DataStore?
    var itemToEdit: Todo?
    var section: Section?
    var index: Int?
    
    //MARK: - Class methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDismissButton()
        setupNewTodoTextField()
        setupDatePicker()
        setupPrioritySwitch()
        setupTapToDismissKeyboard()
        setupHeaderLabel()
        setupHeaderLabel()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveTodo()
    }
    
    private func setupHeaderLabel(){
        guard let _ = itemToEdit else {
            return
        }
        headerLabel.text = "Edit Todo"
    }
    
    private func setupTapToDismissKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    private func setupDatePicker(){
        if let itemToEdit = itemToEdit {
            dueByDatePicker.date = itemToEdit.dueBy!
        }else{
            let dayEndDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())
            dueByDatePicker.date = dayEndDate ?? Date()
        }
    }
    
    private func setupPrioritySwitch(){
        guard let itemToEdit = itemToEdit else {
            return
        }
        prioritySwitch.setOn(itemToEdit.highPriority, animated: false)
    }
    
    private func setupDismissButton(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        dismissBtn.isUserInteractionEnabled = true
        dismissBtn.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupNewTodoTextField(){
        todoTextField.layer.borderColor = UIColor(named: "PrimaryPurpleColor")?.cgColor
        todoTextField.layer.borderWidth = 1
        todoTextField.layer.shadowOpacity = 0.4
        todoTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        todoTextField.layer.shadowRadius = 4
        todoTextField.layer.shadowColor = UIColor(named: "PrimaryGrayColor")?.cgColor
        todoTextField.layer.cornerRadius = 5
        
        todoTextField.delegate = self
        
        guard let itemToEdit = itemToEdit else {
            return
        }
        todoTextField.text = itemToEdit.text
    }
    
    private func saveTodo(){
        guard let dataStore = dataStore else {
            return
        }
        
        let todoText = todoTextField.text
        if todoText == "" || todoText == nil {
            return
        }
        let dueByDate = dueByDatePicker.date
        let highPriority = prioritySwitch.isOn
        
        if let itemToEdit = itemToEdit {
            guard let index = index else {
                return
            }
            guard let section = section else {
                return
            }
            dataStore.updateTodo(itemToUpdate: itemToEdit, text: todoText!, highPriority: highPriority, dueBy: dueByDate, section: section, indexToUpdate: index)
        }else{
            dataStore.saveNewTodo(text: todoText!, highPriority: highPriority, dueBy: dueByDate)
        }
        
        self.dismissVC()
    }
    
    @objc private func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc private func dismissVC(){
        self.dismiss(animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension NewTodoViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
}

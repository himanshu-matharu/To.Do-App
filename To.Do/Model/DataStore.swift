//
//  DataManager.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-14.
//

import Foundation
import CoreData

protocol DataStoreDelegate {
    func didUpdateTableViewDataSource()
}

class DataStore {
    
    //MARK: - Variables and Properties
    let endToday = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
    let startToday = Calendar.current.startOfDay(for: Date())
    
    var tableDataSource: [Section]?
    
    var todoCurrentPriority: [Todo] = []
    var todoCurrentNormal: [Todo] = []
    var todoPastPriority: [Todo] = []
    var todoPastNormal: [Todo] = []
    var done: [Todo] = []
    
    var delegate: DataStoreDelegate?
 
    //MARK: - Class Methods
    init(){
        self.initLists()
        tableDataSource = self.createTableDataSource()
    }
    
    private func initLists(){
        // Fetch data
        let request : NSFetchRequest<Todo> = Todo.fetchRequest()
        let donePredicate = NSPredicate(format: "isDone == %@", NSNumber(value: false))
        let doneDateStartPredicate = NSPredicate(format: "doneOn >= %@", startToday as NSDate)
        let doneDateEndPredicate = NSPredicate(format: "doneOn <= %@", endToday as NSDate)
        let doneDatePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [doneDateStartPredicate, doneDateEndPredicate])
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [donePredicate, doneDatePredicate])
        request.predicate = predicate
        guard let todos = DataManager.shared.loadItems(request: request) else {return}
        
        // Sort Data
        self.done = todos.filter({ todo in
            todo.isDone == true
        }).sorted(by: { itemA, itemB in
            itemA.doneOn! < itemB.doneOn!
        })
        
        let todoList = todos.filter { todo in
            todo.isDone == false
        }.sorted { itemA, itemB in
            itemA.dueBy! < itemB.dueBy!
        }
        
        self.todoCurrentPriority = todoList.filter({ todo in
            (todo.highPriority == true) && (todo.dueBy! >= startToday)
        })
        
        self.todoCurrentNormal = todoList.filter({ todo in
            (todo.highPriority == false) && (todo.dueBy! >= startToday)
        })
        
        self.todoPastPriority = todoList.filter({ todo in
            (todo.highPriority == true) && (todo.dueBy! < startToday)
        })
        
        self.todoPastNormal = todoList.filter({ todo in
            (todo.highPriority == false) && (todo.dueBy! < startToday)
        })
    }
    
    private func createTableDataSource() -> [Section]{
        let combinedTodo = self.todoCurrentPriority + self.todoCurrentNormal + self.todoPastPriority + self.todoPastNormal
        let todoItems = Section.todo(items: combinedTodo)
        let doneItems = Section.done(items: self.done)
        
        return [todoItems,doneItems]
    }
    
    func saveNewTodo(text:String, highPriority:Bool, dueBy:Date){
        let newItem = DataManager.shared.saveNewItem(text: text, highPriority: highPriority, dueBy: dueBy)
        self.saveItemInTodoLists(item: newItem)
        self.refreshTableDataSource()
        delegate?.didUpdateTableViewDataSource()
    }
    
    func deleteTodo(section: Section,index:Int){
        switch section {
        case .todo(let items):
            let item = items[index]
            var indexOfItem = index
            if indexOfItem < self.todoCurrentPriority.count {
                self.todoCurrentPriority.remove(at: indexOfItem)
                DataManager.shared.deleteItem(item: item)
                break
            }
            indexOfItem = indexOfItem - self.todoCurrentPriority.count
            if indexOfItem < self.todoCurrentNormal.count {
                self.todoCurrentNormal.remove(at: indexOfItem)
                DataManager.shared.deleteItem(item: item)
                break
            }
            indexOfItem = indexOfItem - self.todoCurrentNormal.count
            if indexOfItem < self.todoPastPriority.count {
                self.todoPastPriority.remove(at: indexOfItem)
                DataManager.shared.deleteItem(item: item)
                break
            }
            indexOfItem = indexOfItem - self.todoPastPriority.count
            if indexOfItem < self.todoPastNormal.count {
                self.todoPastNormal.remove(at: indexOfItem)
                DataManager.shared.deleteItem(item: item)
                break
            }
            
        case .done(let items):
            let item = items[index]
            self.done.remove(at: index)
            DataManager.shared.deleteItem(item: item)
        }
        
        self.refreshTableDataSource()
    }
    
    func toggleTodo(section: Section, index: Int){
        switch section {
        case .todo(let items):
            let item = items[index]
            item.setValue(true, forKey: "isDone")
            item.setValue(Date(), forKey: "doneOn")
            var indexOfItem = index
            if indexOfItem < self.todoCurrentPriority.count {
                self.todoCurrentPriority.remove(at: indexOfItem)
                self.done.append(item)
                DataManager.shared.saveContext()
                break
            }
            indexOfItem = indexOfItem - self.todoCurrentPriority.count
            if indexOfItem < self.todoCurrentNormal.count {
                self.todoCurrentNormal.remove(at: indexOfItem)
                self.done.append(item)
                DataManager.shared.saveContext()
                break
            }
            indexOfItem = indexOfItem - self.todoCurrentNormal.count
            if indexOfItem < self.todoPastPriority.count {
                self.todoPastPriority.remove(at: indexOfItem)
                self.done.append(item)
                DataManager.shared.saveContext()
                break
            }
            indexOfItem = indexOfItem - self.todoPastPriority.count
            if indexOfItem < self.todoPastNormal.count {
                self.todoPastNormal.remove(at: indexOfItem)
                self.done.append(item)
                DataManager.shared.saveContext()
                break
            }
            
        case .done(let items):
            let item = items[index]
            item.setValue(false, forKey: "isDone")
            item.setValue(nil, forKey: "doneOn")
            self.done.remove(at: index)
            self.saveItemInTodoLists(item: item)
            DataManager.shared.saveContext()
        }
        
        self.refreshTableDataSource()
        delegate?.didUpdateTableViewDataSource()
    }
    
    func updateTodo(itemToUpdate:Todo, text: String, highPriority: Bool, dueBy: Date, section: Section, indexToUpdate: Int){
        itemToUpdate.setValue(text, forKey: "text")
        itemToUpdate.setValue(highPriority, forKey: "highPriority")
        itemToUpdate.setValue(dueBy, forKey: "dueBy")
        DataManager.shared.saveContext()
        
        var indexOfItem = indexToUpdate
        if indexOfItem < self.todoCurrentPriority.count {
            self.todoCurrentPriority.remove(at: indexOfItem)
        }else{
            indexOfItem = indexOfItem - self.todoCurrentPriority.count
            if indexOfItem < self.todoCurrentNormal.count {
                self.todoCurrentNormal.remove(at: indexOfItem)
            }else{
                indexOfItem = indexOfItem - self.todoCurrentNormal.count
                if indexOfItem < self.todoPastPriority.count {
                    self.todoPastPriority.remove(at: indexOfItem)
                }else{
                    indexOfItem = indexOfItem - self.todoPastPriority.count
                    if indexOfItem < self.todoPastNormal.count {
                        self.todoPastNormal.remove(at: indexOfItem)
                    }
                }
            }
        }
        
        
        saveItemInTodoLists(item: itemToUpdate)
        self.refreshTableDataSource()
        delegate?.didUpdateTableViewDataSource()
    }
    
    func saveItemInTodoLists(item:Todo){
        if item.highPriority {
            if item.dueBy! >= self.startToday {
                let insertionIndex = self.todoCurrentPriority.insertionIndexOf(item) { $0.dueBy! < $1.dueBy! }
                self.todoCurrentPriority.insert(item, at: insertionIndex)
            }else{
                let insertionIndex = self.todoPastPriority.insertionIndexOf(item) { $0.dueBy! < $1.dueBy! }
                self.todoPastPriority.insert(item, at: insertionIndex)
            }
        }else{
            if item.dueBy! >= self.startToday {
                let insertionIndex = self.todoCurrentNormal.insertionIndexOf(item) { $0.dueBy! < $1.dueBy! }
                self.todoCurrentNormal.insert(item, at: insertionIndex)
            }else{
                let insertionIndex = self.todoPastNormal.insertionIndexOf(item) { $0.dueBy! < $1.dueBy! }
                self.todoPastNormal.insert(item, at: insertionIndex)
            }
        }
    }
    
    func refreshTableDataSource(){
        self.tableDataSource = createTableDataSource()
    }
    
}

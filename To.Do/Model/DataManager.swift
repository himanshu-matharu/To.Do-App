//
//  DataManager.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-14.
//

import UIKit
import CoreData

class DataManager{
    
    //MARK: - Variables and Properties
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let shared = DataManager()
    
    //MARK: - Class Methods
    func saveNewItem(text:String, highPriority:Bool, dueBy:Date) -> Todo {
        let newItem = Todo(context: self.context)
        newItem.text = text
        newItem.dueBy = dueBy
        newItem.highPriority = highPriority
        newItem.isDone = false
        self.saveContext()
        return newItem
    }
    
    func loadItems(request: NSFetchRequest<Todo> = Todo.fetchRequest()) -> [Todo]?{
        do{
            let todos = try self.context.fetch(request)
            return todos
        }catch{
            print("Error fetching data from context \(error)")
            return nil
        }
    }
    
    func deleteItem(item: Todo){
        context.delete(item)
        self.saveContext()
    }
    
    func saveContext(){
        do{
            try self.context.save()
        }catch{
            print("Error saving context \(error)")
        }
    }
    
}

//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Helen Stepaniuk on 02.07.2020.
//  Copyright © 2020 Helen Stepaniuk. All rights reserved.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {
    
    var toDos: [ToDo] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet{
            loadToDos()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItem", for: indexPath)
        
        cell.textLabel?.text = toDos[indexPath.row].title
        
        cell.accessoryType = toDos[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toDos[indexPath.row].done = !toDos[indexPath.row].done
        
        saveToDos()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveToDos() {
        do {
            try context.save()
        } catch {
            print("Error saving ToDo \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadToDos(with request: NSFetchRequest<ToDo> = ToDo.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            toDos = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - Add new ToDos
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alertVC = UIAlertController(title: "Add new ToDo", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newToDo = ToDo(context: self.context)
            newToDo.title = textField.text
            newToDo.done = false
            newToDo.parentCategory = self.selectedCategory
            
            self.toDos.append(newToDo)
            self.saveToDos()
        }
        
        alertVC.addTextField { (alertTF) in
            alertTF.placeholder = "Type something..."
            textField = alertTF
        }
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
}

extension ToDoTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadToDos(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadToDos()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

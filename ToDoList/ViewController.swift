

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var task:[ToDoTask] = []
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.reloadData()
        fetchTasks()
        saveCoreDataToJSON()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addTask))
        //core data location
        if let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            print("Core Data Store Location: \(storeURL)")
        }
    }
    func saveCoreDataToJSON() {
        let fetchRequest: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()
        guard let tasks = try? context.fetch(fetchRequest) else { return }
        
        let jsonArray = tasks.map { ["taskname": $0.taskname ?? "", "status": $0.status] }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted) else { return }
        
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do { try jsonData.write(to: documentsURL.appendingPathComponent("ToDoList.json"))
                print("JSON saved at:", documentsURL)
            } catch { print("Error saving JSON:", error) }
        }
    }
    
    func fetchTasks() {
        let fetchRequest: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()
        do {
            task = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
    @objc func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter task title", preferredStyle: .alert)
        alert.addTextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            self.createTask(title: title)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    func createTask(title: String) {
        let newTask = ToDoTask(context: context)
        newTask.taskname = title
        newTask.status = false
        saveTasks()
    }
    func saveTasks() {
        do {
            try context.save()
            fetchTasks()
        } catch {
            print("Error saving tasks: \(error)")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return task.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        
        let todo = task[indexPath.row]
        cell.tittle.text = todo.taskname
        cell.status.text = todo.status ? "Completed" : "Pending"
        
        // Set the initial colors here
        if todo.status {
            cell.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            cell.status.textColor = .systemGreen
        } else {
            cell.backgroundColor = .white
            cell.status.textColor = .darkGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle the status
        task[indexPath.row].status = !task[indexPath.row].status
        saveTasks()
        if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
            UIView.transition(with: cell, duration: 0.3, options: .transitionCrossDissolve, animations: {
                if self.task[indexPath.row].status {
                    cell.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                    cell.status.textColor = .systemGreen
                } else {
                    cell.backgroundColor = .white
                    cell.status.textColor = .darkGray
                }
            })
        }
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(task[indexPath.row])
            saveTasks()
        }
    }

}


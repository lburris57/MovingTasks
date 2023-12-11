//
//  Task.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import Foundation
import SwiftData

@Model
class Task
{
    @Attribute(.unique) 
    var taskId : String? = UUID().uuidString
    
    var taskTitle: String? = Constants.EMPTY_STRING
    var taskDescription: String? = Constants.EMPTY_STRING
    var comment: String? = Constants.EMPTY_STRING
    var isCompleted: Bool? = false
    var category: String? = CategoryEnum.miscellaneous.title
    var priority: String? = PriorityEnum.medium.title
    var createdDate: Date? = Date.now
    var completedDate: Date? = nil
    
    var project: Project?

    var wrappedTaskTitle: String
    {
        taskTitle ?? "Unknown task title"
    }
    
    var wrappedTaskDescription: String
    {
        taskDescription ?? "Unknown task description"
    }
    
    var wrappedComment: String
    {
        comment ?? "Unknown comment"
    }
    
    var wrappedIsCompleted: String
    {
        let value = isCompleted  ?? false
        
        if value == true
        {
            return "Complete"
        }
        else
        {
            return "Incomplete"
        }
    }
    
    var wrappedCategory: String
    {
        category ?? CategoryEnum.miscellaneous.title
    }
    
    var wrappedPriority: String
    {
        priority ?? PriorityEnum.medium.title
    }
    
    var wrappedCreatedDate: String
    {
        createdDate?.formatted(date: .abbreviated, time: .omitted) ?? Date.now.formatted(date: .abbreviated, time: .omitted)
    }
    
    init(taskTitle: String? = Constants.EMPTY_STRING,
            taskDescription: String? = Constants.EMPTY_STRING,
            comment: String? = Constants.EMPTY_STRING,
            isCompleted: Bool? = false,
            category: String? = CategoryEnum.miscellaneous.title,
            priority: String? = PriorityEnum.medium.title,
            createdDate: Date? = Date.now)
    {
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
        self.comment = comment
        self.isCompleted = isCompleted
        self.category = category
        self.priority = priority
        self.createdDate = createdDate
    }
    
    static func sampleData() -> [Task]
    {
        let task1 = Task(taskTitle: "Repair Faucet", taskDescription: "Repair Kitchen Faucet", comment: "Faucet keeps dripping water", category: CategoryEnum.repair.title)
        let task2 = Task(taskTitle: "Milk", taskDescription: "Buy Milk", comment: "We need milk", category: CategoryEnum.miscellaneous.title)
        let task3 = Task(taskTitle: "Gas", taskDescription: "Fill up gas tank in car", comment: "Car needs gas", category: CategoryEnum.miscellaneous.title)
        
        var tasks: [Task] = []
        
        tasks.append(task1)
        tasks.append(task2)
        tasks.append(task3)
        
        return tasks
    }
}

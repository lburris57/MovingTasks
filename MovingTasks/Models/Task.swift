//
//  Task.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import Foundation
import SwiftData

@Model
class Task: Identifiable, Hashable
{
    var taskId : String = UUID().uuidString
    
    var taskTitle: String = Constants.EMPTY_STRING
    var taskDescription: String = Constants.EMPTY_STRING
    var comment: String = Constants.EMPTY_STRING
    var location: String = Constants.EMPTY_STRING
    var isCompleted: Bool = false
    var category: String = CategoryEnum.miscellaneous.title
    var priority: String = PriorityEnum.medium.title
    var createdDate: String = Date.now.formatted(date: .abbreviated, time: .shortened)
    var completedDate: String = Constants.EMPTY_STRING
    
    @Relationship(deleteRule: .cascade)
    var taskItems: [TaskItem]? = [TaskItem]()
    
    var project: Project?
    
    var wrappedIsCompleted: String
    {
        isCompleted ? Constants.COMPLETE : Constants.INCOMPLETE
    }
    
    var taskItemsArray: [TaskItem]
    {
        taskItems ?? []
    }
    
    init(taskTitle: String = Constants.EMPTY_STRING,
            taskDescription: String = Constants.EMPTY_STRING,
            comment: String = Constants.EMPTY_STRING,
            location: String = LocationEnum.thirdFloor.title,
            isCompleted: Bool = false,
            category: String = CategoryEnum.miscellaneous.title,
            priority: String = PriorityEnum.medium.title,
            createdDate: String = Date.now.formatted(date: .abbreviated, time: .shortened))
    {
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
        self.comment = comment
        self.location = location
        self.isCompleted = isCompleted
        self.category = category
        self.priority = priority
        self.createdDate = createdDate
    }
    
    static func sampleData() -> [Task]
    {
        let task1 = Task(taskTitle: "Repair Faucet", taskDescription: "Repair Kitchen Faucet", comment: "Faucet keeps dripping water", location: LocationEnum.kitchen.title, category: CategoryEnum.repair.title)
        
        let task2 = Task(taskTitle: "Milk", taskDescription: "Buy Milk", comment: "We need milk", category: CategoryEnum.miscellaneous.title)
        
        let task3 = Task(taskTitle: "Gas", taskDescription: "Fill up gas tank in car", comment: "Car needs gas", category: CategoryEnum.miscellaneous.title)
        
        var tasks: [Task] = []
        
        tasks.append(task1)
        tasks.append(task2)
        tasks.append(task3)
        
        return tasks
    }
}

//
//  Project.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import Foundation
import SwiftData

@Model
class Project: Identifiable
{
    var projectId : String = UUID().uuidString
    
    var projectTitle: String = Constants.EMPTY_STRING
    var projectDescription: String = Constants.EMPTY_STRING
    var comment: String = Constants.EMPTY_STRING
    var location: String = Constants.EMPTY_STRING
    var isCompleted: Bool = false
    var createdDate: String = Date.now.formatted(date: .abbreviated, time: .omitted)
    var completedDate: String = Constants.EMPTY_STRING
    
    @Relationship(inverse: \Task.project)
    var tasks: [Task]? = []
    
    var tasksArray: [Task]
    {
        tasks ?? []
    }
    
    init(
            projectTitle: String = Constants.EMPTY_STRING,
            projectDescription: String = Constants.EMPTY_STRING,
            comment: String = Constants.EMPTY_STRING,
            location: String = Constants.EMPTY_STRING,
            isCompleted: Bool = false,
            createdDate: String = Date.now.formatted(date: .abbreviated, time: .omitted),
            completedDate: String = Constants.EMPTY_STRING,
            tasks: [Task]? = [])
    {
        self.projectId = projectId
        self.projectTitle = projectTitle
        self.projectDescription = projectDescription
        self.comment = comment
        self.location = location
        self.isCompleted = isCompleted
        self.createdDate = createdDate
        self.completedDate = completedDate
        self.tasks = tasks
    }
}

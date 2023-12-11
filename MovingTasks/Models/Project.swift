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
    @Attribute(.unique)
    var projectId : String? = UUID().uuidString
    
    var projectTitle: String? = Constants.EMPTY_STRING
    var projectDescription: String? = Constants.EMPTY_STRING
    var comment: String? = Constants.EMPTY_STRING
    var isCompleted: Bool? = false
    var createdDate: Date? = Date.now
    var completedDate: Date? = nil
    
    @Relationship(inverse: \Task.project)
    var tasks: [Task]? = []
    
    var tasksArray: [Task]
    {
        tasks ?? []
    }
    
    var wrappedProjectTitle: String
    {
        projectTitle ?? "Unknown project title"
    }
    
    var wrappedProjectDescription: String
    {
        projectDescription ?? "Unknown project description"
    }
    
    var wrappedComment: String
    {
        comment ?? "Unknown comment"
    }
    
    init(
            projectTitle: String? = Constants.EMPTY_STRING,
            projectDescription: String? = Constants.EMPTY_STRING,
            comment: String? = Constants.EMPTY_STRING,
            isCompleted: Bool? = false,
            createdDate: Date? = Date.now,
            completedDate: Date? = nil,
            tasks: [Task]? = [])
    {
        self.projectId = projectId
        self.projectTitle = projectTitle
        self.projectDescription = projectDescription
        self.comment = comment
        self.isCompleted = isCompleted
        self.createdDate = createdDate
        self.completedDate = completedDate
        self.tasks = tasks
    }
}

//
//  Category.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import Foundation
import SwiftData

@Model
final class Category: Identifiable
{
    @Attribute(.unique) var categoryId: String? = UUID().uuidString
    @Attribute(.unique) var title: String? = Constants.EMPTY_STRING
    
    var tasks: [Task]? = []
    
    var taskArray: [Task]
    {
        tasks ?? []
    }
    
    init(title: String,
            tasks: [Task] = [])
    {
        self.title = title
        self.tasks = tasks
    }
}

extension Category
{
    static var defaults: [Category]
    {
        [
            .init(title: "Cleaning"),
            .init(title: "Packing"),
            .init(title: "Painting"),
            .init(title: "Removal"),
            .init(title: "Repair"),
            .init(title: "Replacement"),
            .init(title: "Storage")
        ]
    }
}

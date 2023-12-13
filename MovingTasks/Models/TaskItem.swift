//
//  TaskItem.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/12/23.
//
import Foundation
import SwiftData

@Model
class TaskItem:  Identifiable, Hashable
{
    var taskItemId : String = UUID().uuidString
    
    var itemTitle: String = Constants.EMPTY_STRING
    var itemDescription: String = Constants.EMPTY_STRING
    var comment: String = Constants.EMPTY_STRING
    var wasPurchased: Bool = false
    var quantity: Int = 0
    var purchasedPrice: Double = 0.0
    
    var task: Task?
    
    var createdDate: String = Date.now.formatted(date: .abbreviated, time: .shortened)
    
    init(itemTitle: String, itemDescription: String, comment: String)
    {
        self.itemTitle = itemTitle
        self.itemDescription = itemDescription
        self.comment = comment
    }
}

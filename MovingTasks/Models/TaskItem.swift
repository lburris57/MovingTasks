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
    var quantity: String = "1"
    var purchasedPrice: String = 10.0.formatted(.currency(code: "USD"))
    var purchaseDate: Date = Date.now
    
    var task: Task?
    
    var createdDate: String = Date.now.formatted(date: .abbreviated, time: .shortened)
    
    var wrappedWasPurchased: String
    {
        wasPurchased ? "Yes" : "No"
    }
    
    init(itemTitle: String, itemDescription: String, comment: String)
    {
        self.itemTitle = itemTitle
        self.itemDescription = itemDescription
        self.comment = comment
    }
}

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
    var url: String = Constants.NOT_APPLICABLE
    var quantity: String = Constants.ZERO_STRING
    var purchasedPrice: String = Constants.ZERO.formatted(.currency(code: Constants.US_DOLLARS_CODE))
    var purchaseDate: Date = Date.now
    var createdDate: String = Date.now.formatted(date: .abbreviated, time: .shortened)
    
    var task: Task?
    
    init(taskItemId: String, itemTitle: String, itemDescription: String, comment: String, wasPurchased: Bool, url: String, quantity: String, purchasedPrice: String, purchaseDate: Date, createdDate: String, task: Task? = nil, wrappedWasPurchased: String, totalPrice: Decimal, totalPriceString: String, formattedTotalPriceString: String)
    {
        self.taskItemId = taskItemId
        self.itemTitle = itemTitle
        self.itemDescription = itemDescription
        self.comment = comment
        self.wasPurchased = wasPurchased
        self.url = url
        self.quantity = quantity
        self.purchasedPrice = purchasedPrice
        self.purchaseDate = purchaseDate
        self.createdDate = createdDate
    }
    
    init(itemTitle: String, itemDescription: String, comment: String)
    {
        self.itemTitle = itemTitle
        self.itemDescription = itemDescription
        self.comment = comment
    }
    
    var wrappedWasPurchased: String
    {
        wasPurchased ? Constants.YES : Constants.NO
    }
    
    var totalPrice: Decimal
    {
        guard let decimalQuantity = Decimal(string: quantity) else { return Constants.ZERO_DECIMAL}
        
        guard let decimalPurchasedPrice = Decimal(string: purchasedPrice) else { return Constants.ZERO_DECIMAL }
        
        return decimalQuantity * decimalPurchasedPrice
    }
    
    var totalPriceString: String
    {
        guard let decimalQuantity = Decimal(string: quantity) else { return Constants.ZERO_CURRENCY}
        
        guard let decimalPurchasedPrice =
                Decimal(string: purchasedPrice.replacingOccurrences(of: Constants.DOLLAR_SIGN, with: Constants.EMPTY_STRING))
                else { return Constants.ZERO_CURRENCY }
        
        return ("\(decimalQuantity * decimalPurchasedPrice)")
    }
    
    var formattedTotalPriceString: String
    {
        guard let decimalQuantity = Decimal(string: quantity) else { return Constants.ZERO_CURRENCY}
        
        guard let decimalPurchasedPrice =
                Decimal(string: purchasedPrice.replacingOccurrences(of: Constants.DOLLAR_SIGN, with: Constants.EMPTY_STRING))
                else { return Constants.ZERO_CURRENCY }
        
        return (decimalQuantity * decimalPurchasedPrice).formatted(.currency(code: "USD"))
    }
}

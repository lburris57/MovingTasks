//
//  TaskItemTests.swift
//  MovingTasksTests
//
//  Unit tests for TaskItem model and calculations
//
@testable import MovingTasks
import Foundation
import SwiftData
import Testing

// MARK: - TaskItem Model Tests

@Suite("TaskItem Model Tests")
@MainActor
struct TaskItemTests {
    var modelContainer: ModelContainer
    var modelContext: ModelContext
    
    init() async throws {
        (modelContainer, modelContext) = try TestHelpers.createTestContainer()
    }
    
    // MARK: - Initialization Tests
    
    @Test("TaskItem initializes with required fields")
    func taskItemInitialization() {
        let item = TaskItem(
            itemTitle: "Paint Brush",
            itemDescription: "2 inch brush",
            comment: "For trim work"
        )
        
        #expect(item.itemTitle == "Paint Brush")
        #expect(item.itemDescription == "2 inch brush")
        #expect(item.comment == "For trim work")
    }
    
    @Test("TaskItem initializes with default values")
    func taskItemDefaultValues() {
        let item = TestHelpers.createTestTaskItem()
        
        #expect(item.quantity == "1")
        #expect(item.purchasedPrice == "$0.00")
        #expect(!item.wasPurchased)
        #expect(item.url == "")
    }
    
    @Test("TaskItem can be created with empty strings")
    func taskItemWithEmptyStrings() {
        let item = TaskItem(
            itemTitle: "",
            itemDescription: "",
            comment: ""
        )
        
        #expect(item.itemTitle == "")
        #expect(item.itemDescription == "")
        #expect(item.comment == "")
    }
    
    // MARK: - Property Tests
    
    @Test("TaskItem quantity can be set")
    func itemQuantity() {
        let item = TestHelpers.createTestTaskItem()
        item.quantity = "5"
        
        #expect(item.quantity == "5")
    }
    
    @Test("TaskItem price can be set")
    func itemPrice() {
        let item = TestHelpers.createTestTaskItem()
        item.purchasedPrice = "$25.99"
        
        #expect(item.purchasedPrice == "$25.99")
    }
    
    @Test("TaskItem URL can be set")
    func itemURL() {
        let item = TestHelpers.createTestTaskItem()
        item.url = "https://www.example.com/product"
        
        #expect(item.url == "https://www.example.com/product")
    }
    
    @Test("TaskItem purchased status can be toggled")
    func itemPurchasedToggle() {
        let item = TestHelpers.createTestTaskItem()
        
        #expect(!item.wasPurchased)
        
        item.wasPurchased = true
        #expect(item.wasPurchased)
        
        item.wasPurchased = false
        #expect(!item.wasPurchased)
    }
    
    // MARK: - Price Calculation Tests
    
    @Test("TotalPrice calculation with quantity 1")
    func totalPriceWithQuantityOne() {
        let item = TestHelpers.createPricedItem(quantity: "1", price: "$10.00")
        
        #expect(item.totalPrice == Decimal(10.00))
    }
    
    @Test("TotalPrice calculation with quantity > 1")
    func totalPriceWithMultipleQuantity() {
        let item = TestHelpers.createPricedItem(quantity: "3", price: "$15.00")
        
        // 3 * $15.00 = $45.00
        #expect(item.totalPrice == Decimal(45.00))
    }
    
    @Test("TotalPrice with decimal prices")
    func totalPriceWithDecimalPrices() {
        let item = TestHelpers.createPricedItem(quantity: "2", price: "$9.99")
        
        // 2 * $9.99 = $19.98
        #expect(item.totalPrice == Decimal(string: "19.98"))
    }
    
    @Test("TotalPrice with complex decimal calculations")
    func totalPriceComplexDecimals() {
        let item = TestHelpers.createPricedItem(quantity: "7", price: "$3.47")
        
        // 7 * $3.47 = $24.29
        #expect(item.totalPrice == Decimal(string: "24.29"))
    }
    
    @Test("TotalPrice handles zero quantity")
    func totalPriceZeroQuantity() {
        let item = TestHelpers.createPricedItem(quantity: "0", price: "$10.00")
        
        #expect(item.totalPrice == Decimal.zero)
    }
    
    @Test("TotalPrice handles zero price")
    func totalPriceZeroPrice() {
        let item = TestHelpers.createPricedItem(quantity: "5", price: "$0.00")
        
        #expect(item.totalPrice == Decimal.zero)
    }
    
    @Test("TotalPrice with invalid quantity returns zero")
    func totalPriceInvalidQuantity() {
        let item = TestHelpers.createTestTaskItem()
        item.quantity = "invalid"
        item.purchasedPrice = "$10.00"
        
        #expect(item.totalPrice == Decimal.zero)
    }
    
    @Test("TotalPrice with invalid price returns zero")
    func totalPriceInvalidPrice() {
        let item = TestHelpers.createTestTaskItem()
        item.quantity = "2"
        item.purchasedPrice = "invalid"
        
        #expect(item.totalPrice == Decimal.zero)
    }
    
    @Test("TotalPrice with various values",
          arguments: TestConstants.samplePrices)
    func totalPriceVariousValues(quantity: String, price: String, expected: Decimal) {
        let item = TestHelpers.createPricedItem(quantity: quantity, price: price)
        
        #expect(item.totalPrice == expected)
    }
    
    // MARK: - String Formatting Tests
    
    @Test("TotalPriceString formats correctly")
    func totalPriceStringFormat() {
        let item = TestHelpers.createPricedItem(quantity: "2", price: "$10.00")
        
        // Should return "20.00" or "20.0" (without dollar sign)
        let priceString = item.totalPriceString
        let decimal = Decimal(string: priceString)
        
        #expect(decimal == Decimal(20.00))
    }
    
    @Test("FormattedTotalPriceString includes currency symbol")
    func formattedTotalPriceString() {
        let item = TestHelpers.createPricedItem(quantity: "3", price: "$5.00")
        
        let formatted = item.formattedTotalPriceString
        
        // Should be "$15.00"
        #expect(formatted.contains("$"))
        #expect(formatted.contains("15"))
    }
    
    @Test("WrappedWasPurchased returns correct string")
    func wrappedPurchasedStatus() {
        let item = TestHelpers.createTestTaskItem()
        
        item.wasPurchased = false
        #expect(item.wrappedWasPurchased == "No")
        
        item.wasPurchased = true
        #expect(item.wrappedWasPurchased == "Yes")
    }
    
    // MARK: - Relationship Tests
    
    @Test("TaskItem can be associated with a task")
    func itemTaskRelationship() {
        let task = TestHelpers.createTestTask()
        let item = TestHelpers.createTestTaskItem()
        
        item.task = task
        
        #expect(item.task === task)
        #expect(task.taskItemsArray.contains(item))
    }
    
    @Test("TaskItem task relationship can be changed")
    func itemTaskRelationshipChange() {
        let task1 = TestHelpers.createTestTask(title: "Task 1")
        let task2 = TestHelpers.createTestTask(title: "Task 2")
        let item = TestHelpers.createTestTaskItem()
        
        // Initially assign to task1
        item.task = task1
        #expect(task1.taskItemsArray.contains(item))
        #expect(task2.taskItemsArray.isEmpty)
        
        // Reassign to task2
        item.task = task2
        #expect(task2.taskItemsArray.contains(item))
        // Note: task1 should no longer contain item (automatic relationship management)
    }
    
    @Test("TaskItem with no task association")
    func itemWithoutTask() {
        let item = TestHelpers.createTestTaskItem()
        
        #expect(item.task == nil)
    }
    
    // MARK: - Persistence Tests
    
    @Test("TaskItem can be inserted into context")
    func insertTaskItem() throws {
        let item = TestHelpers.createTestTaskItem(itemTitle: "Test Item")
        
        modelContext.insert(item)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<TaskItem>()
        let items = try modelContext.fetch(descriptor)
        
        #expect(items.count == 1)
        #expect(items.first?.itemTitle == "Test Item")
    }
    
    @Test("Multiple task items can be inserted")
    func insertMultipleTaskItems() throws {
        let items = (1...5).map { index in
            TestHelpers.createTestTaskItem(itemTitle: "Item \(index)")
        }
        
        items.forEach { modelContext.insert($0) }
        try modelContext.save()
        
        let descriptor = FetchDescriptor<TaskItem>()
        let fetchedItems = try modelContext.fetch(descriptor)
        
        #expect(fetchedItems.count == 5)
    }
    
    @Test("TaskItem can be updated")
    func updateTaskItem() throws {
        let item = TestHelpers.createTestTaskItem(itemTitle: "Original")
        modelContext.insert(item)
        try modelContext.save()
        
        item.itemTitle = "Updated"
        item.quantity = "10"
        item.purchasedPrice = "$99.99"
        try modelContext.save()
        
        let descriptor = FetchDescriptor<TaskItem>()
        let items = try modelContext.fetch(descriptor)
        
        #expect(items.first?.itemTitle == "Updated")
        #expect(items.first?.quantity == "10")
        #expect(items.first?.purchasedPrice == "$99.99")
    }
    
    @Test("TaskItem can be deleted")
    func deleteTaskItem() throws {
        let item = TestHelpers.createTestTaskItem()
        modelContext.insert(item)
        try modelContext.save()
        
        modelContext.delete(item)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<TaskItem>()
        let items = try modelContext.fetch(descriptor)
        
        #expect(items.isEmpty)
    }
    
    // MARK: - Update Method Tests
    
    @Test("UpdatePurchasedPrice updates price")
    func updatePurchasedPriceMethod() {
        let item = TestHelpers.createTestTaskItem()
        
        item.updatePurchasedPrice("$50.00")
        
        #expect(item.purchasedPrice == "$50.00")
    }
    
    @Test("UpdatePurchasedPrice auto-marks as purchased with valid price")
    func updatePurchasedPriceAutoCheck() {
        let item = TestHelpers.createTestTaskItem()
        
        #expect(!item.wasPurchased)
        
        item.updatePurchasedPrice("$25.00")
        
        #expect(item.wasPurchased)
        #expect(item.purchasedPrice == "$25.00")
    }
    
    @Test("UpdatePurchasedPrice with zero does not auto-check")
    func updatePurchasedPriceZero() {
        let item = TestHelpers.createTestTaskItem()
        
        item.updatePurchasedPrice("$0.00")
        
        #expect(!item.wasPurchased)
    }
    
    @Test("UpdatePurchasedPrice with invalid string does not auto-check")
    func updatePurchasedPriceInvalid() {
        let item = TestHelpers.createTestTaskItem()
        
        item.updatePurchasedPrice("invalid")
        
        #expect(!item.wasPurchased)
    }
    
    // MARK: - Edge Cases
    
    @Test("TaskItem with very large quantity")
    func itemWithLargeQuantity() {
        let item = TestHelpers.createPricedItem(quantity: "1000", price: "$2.50")
        
        // 1000 * $2.50 = $2500.00
        #expect(item.totalPrice == Decimal(2500.00))
    }
    
    @Test("TaskItem with very small price")
    func itemWithSmallPrice() {
        let item = TestHelpers.createPricedItem(quantity: "100", price: "$0.01")
        
        // 100 * $0.01 = $1.00
        #expect(item.totalPrice == Decimal(1.00))
    }
    
    @Test("TaskItem with fractional quantity")
    func itemWithFractionalQuantity() {
        let item = TestHelpers.createPricedItem(quantity: "2.5", price: "$10.00")
        
        // 2.5 * $10.00 = $25.00
        #expect(item.totalPrice == Decimal(25.00))
    }
    
    @Test("TaskItem price calculation precision")
    func itemPriceCalculationPrecision() {
        let item = TestHelpers.createPricedItem(quantity: "3", price: "$3.33")
        
        // 3 * $3.33 = $9.99 (not $10.00 due to rounding)
        #expect(item.totalPrice == Decimal(string: "9.99"))
    }
}

// MARK: - TaskItem Business Logic Tests

@Suite("TaskItem Business Logic Tests")
@MainActor
struct TaskItemBusinessLogicTests {
    
    @Test("Multiple items total calculation")
    func multipleItemsTotal() {
        let item1 = TestHelpers.createPricedItem(quantity: "2", price: "$10.00")
        let item2 = TestHelpers.createPricedItem(quantity: "3", price: "$5.00")
        let item3 = TestHelpers.createPricedItem(quantity: "1", price: "$25.50")
        
        let total = [item1, item2, item3].reduce(Decimal.zero) { $0 + $1.totalPrice }
        
        // (2*$10) + (3*$5) + (1*$25.50) = $20 + $15 + $25.50 = $60.50
        #expect(total == Decimal(string: "60.50"))
    }
    
    @Test("Purchased items filtering")
    func purchasedItemsFiltering() {
        let item1 = TestHelpers.createTestTaskItem(wasPurchased: true)
        let item2 = TestHelpers.createTestTaskItem(wasPurchased: false)
        let item3 = TestHelpers.createTestTaskItem(wasPurchased: true)
        let item4 = TestHelpers.createTestTaskItem(wasPurchased: false)
        
        let allItems = [item1, item2, item3, item4]
        let purchased = allItems.filter { $0.wasPurchased }
        let notPurchased = allItems.filter { !$0.wasPurchased }
        
        #expect(purchased.count == 2)
        #expect(notPurchased.count == 2)
    }
    
    @Test("Items sorted by price")
    func itemsSortedByPrice() {
        let item1 = TestHelpers.createPricedItem(title: "Cheap", quantity: "1", price: "$5.00")
        let item2 = TestHelpers.createPricedItem(title: "Expensive", quantity: "1", price: "$50.00")
        let item3 = TestHelpers.createPricedItem(title: "Medium", quantity: "1", price: "$25.00")
        
        let items = [item1, item2, item3]
        let sorted = items.sorted { $0.totalPrice < $1.totalPrice }
        
        #expect(sorted[0].itemTitle == "Cheap")
        #expect(sorted[1].itemTitle == "Medium")
        #expect(sorted[2].itemTitle == "Expensive")
    }
    
    @Test("Shopping list workflow")
    func shoppingListWorkflow() {
        let item = TestHelpers.createTestTaskItem(itemTitle: "Paint")
        
        // Initially: not purchased, no price
        #expect(!item.wasPurchased)
        #expect(item.purchasedPrice == "$0.00")
        
        // Set quantity and price
        item.quantity = "2"
        item.updatePurchasedPrice("$25.99")
        
        // Should auto-mark as purchased
        #expect(item.wasPurchased)
        #expect(item.totalPrice == Decimal(string: "51.98"))
        
        // Mark as not purchased (user changed mind)
        item.wasPurchased = false
        #expect(!item.wasPurchased)
        // Price should still be there
        #expect(item.purchasedPrice == "$25.99")
    }
}

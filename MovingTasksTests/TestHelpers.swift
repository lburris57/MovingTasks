//
//  TestHelpers.swift
//  MovingTasksTests
//
//  Shared test utilities and helper methods
//
@testable import MovingTasks
import SwiftData
import SwiftUI
import Testing

// MARK: - Test Helpers

/// Shared utilities for creating test data and managing test contexts
@MainActor
struct TestHelpers {
    
    // MARK: - Model Container Creation
    
    /// Creates an in-memory model container for testing
    /// - Returns: A tuple containing the ModelContainer and ModelContext
    static func createTestContainer() throws -> (ModelContainer, ModelContext) {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Task.self, TaskItem.self, configurations: config)
        let context = ModelContext(container)
        return (container, context)
    }
    
    // MARK: - Task Creation
    
    /// Creates a test task with customizable properties
    static func createTestTask(
        title: String = "Test Task",
        description: String = "Test Description",
        comment: String = "Test Comment",
        category: String = "Kitchen",
        location: String = "Inside",
        priority: String = "High",
        isCompleted: Bool = false,
        completedDate: String = ""
    ) -> Task {
        let task = Task(taskTitle: title, taskDescription: description, comment: comment)
        task.category = category
        task.location = location
        task.priority = priority
        task.isCompleted = isCompleted
        task.completedDate = completedDate
        return task
    }
    
    /// Creates multiple test tasks with sequential titles
    static func createMultipleTasks(count: Int, category: String = "Kitchen") -> [Task] {
        (1...count).map { index in
            createTestTask(
                title: "Task \(index)",
                description: "Description \(index)",
                category: category,
                priority: index % 3 == 0 ? "High" : index % 2 == 0 ? "Medium" : "Low"
            )
        }
    }
    
    // MARK: - TaskItem Creation
    
    /// Creates a test task item with customizable properties
    static func createTestTaskItem(
        itemTitle: String = "Test Item",
        itemDescription: String = "Test Description",
        comment: String = "Test Comment",
        quantity: String = "1",
        price: String = "$0.00",
        wasPurchased: Bool = false,
        url: String = ""
    ) -> TaskItem {
        let item = TaskItem(itemTitle: itemTitle, itemDescription: itemDescription, comment: comment)
        item.quantity = quantity
        item.purchasedPrice = price
        item.wasPurchased = wasPurchased
        item.url = url
        return item
    }
    
    /// Creates a task item with specific quantity and price for calculation tests
    static func createPricedItem(
        title: String = "Item",
        quantity: String,
        price: String
    ) -> TaskItem {
        let item = TaskItem(itemTitle: title, itemDescription: "Description", comment: "")
        item.quantity = quantity
        item.purchasedPrice = price
        return item
    }
    
    /// Creates multiple task items for a given task
    static func createItemsForTask(
        task: Task,
        count: Int,
        basePrice: Decimal = 10.00
    ) -> [TaskItem] {
        (1...count).map { index in
            let item = createTestTaskItem(
                itemTitle: "Item \(index)",
                quantity: "\(index)",
                price: "$\(basePrice * Decimal(index))"
            )
            item.task = task
            return item
        }
    }
    
    // MARK: - Sample Data Sets
    
    /// Creates a complete sample data set for integration testing
    static func createSampleDataSet(in context: ModelContext) throws {
        // Kitchen tasks
        let kitchenTask1 = createTestTask(
            title: "Clean Kitchen",
            description: "Deep clean all surfaces",
            category: "Cleaning",
            location: "Kitchen",
            priority: "High"
        )
        
        let kitchenItem1 = createPricedItem(title: "Cleaning Supplies", quantity: "1", price: "$25.00")
        kitchenItem1.task = kitchenTask1
        
        // Bathroom tasks
        let bathroomTask = createTestTask(
            title: "Paint Bathroom",
            description: "Repaint walls",
            category: "Painting",
            location: "Bathroom",
            priority: "Medium"
        )
        
        let paintItem = createPricedItem(title: "Paint", quantity: "2", price: "$30.00")
        paintItem.task = bathroomTask
        
        // Completed task
        let completedTask = createTestTask(
            title: "Organize Garage",
            description: "Sort and organize",
            category: "Organizing",
            location: "Garage",
            priority: "Low",
            isCompleted: true,
            completedDate: Date.now.formatted(date: .abbreviated, time: .shortened)
        )
        
        // Insert all
        context.insert(kitchenTask1)
        context.insert(kitchenItem1)
        context.insert(bathroomTask)
        context.insert(paintItem)
        context.insert(completedTask)
        
        try context.save()
    }
    
    // MARK: - Assertion Helpers
    
    /// Validates a task has expected default values
    static func assertDefaultTask(_ task: Task) {
        #expect(task.taskTitle != "")
        #expect(task.category != "")
        #expect(task.location != "")
        #expect(task.priority != "")
        #expect(!task.isCompleted)
    }
    
    /// Validates a task item's price calculation
    static func assertPriceCalculation(
        item: TaskItem,
        expectedTotal: Decimal,
        message: String = "Price calculation should be correct"
    ) {
        #expect(item.totalPrice == expectedTotal, Comment(rawValue: message))
    }
    
    // MARK: - Test Data Cleanup
    
    /// Removes all tasks and items from context
    static func cleanupContext(_ context: ModelContext) throws {
        let taskDescriptor = FetchDescriptor<Task>()
        let tasks = try context.fetch(taskDescriptor)
        tasks.forEach { context.delete($0) }
        
        let itemDescriptor = FetchDescriptor<TaskItem>()
        let items = try context.fetch(itemDescriptor)
        items.forEach { context.delete($0) }
        
        try context.save()
    }
}

// MARK: - Test Constants

/// Constants used across test files
enum TestConstants {
    static let sampleCategories = ["Cleaning", "Painting", "Organizing", "Repair"]
    static let sampleLocations = ["Kitchen", "Bathroom", "Bedroom", "Garage"]
    static let samplePriorities = ["High", "Medium", "Low"]
    
    static let samplePrices: [(String, String, Decimal)] = [
        ("1", "$10.00", 10.00),
        ("2", "$15.50", 31.00),
        ("3", "$5.25", 15.75),
        ("5", "$2.99", 14.95)
    ]
}

// MARK: - Mock Data Generators

extension TestHelpers {
    
    /// Generates a task with random but valid data
    static func randomTask() -> Task {
        createTestTask(
            title: "Task \(Int.random(in: 1...1000))",
            category: TestConstants.sampleCategories.randomElement()!,
            location: TestConstants.sampleLocations.randomElement()!,
            priority: TestConstants.samplePriorities.randomElement()!,
            isCompleted: Bool.random()
        )
    }
    
    /// Generates multiple random tasks for stress testing
    static func randomTasks(count: Int) -> [Task] {
        (1...count).map { _ in randomTask() }
    }
}

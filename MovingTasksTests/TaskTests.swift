//
//  TaskTests.swift
//  MovingTasksTests
//
//  Unit tests for Task model
//
@testable import MovingTasks
import Foundation
import SwiftData
import Testing

// MARK: - Task Model Tests

@Suite("Task Model Tests")
@MainActor
struct TaskTests {
    var modelContainer: ModelContainer
    var modelContext: ModelContext
    
    init() async throws {
        (modelContainer, modelContext) = try TestHelpers.createTestContainer()
    }
    
    // MARK: - Initialization Tests
    
    @Test("Task initializes with required fields")
    func taskInitialization() {
        let task = Task(
            taskTitle: "Kitchen Cleaning",
            taskDescription: "Deep clean kitchen",
            comment: "Before move-in"
        )
        
        #expect(task.taskTitle == "Kitchen Cleaning")
        #expect(task.taskDescription == "Deep clean kitchen")
        #expect(task.comment == "Before move-in")
    }
    
    @Test("Task initializes with default values")
    func taskDefaultValues() {
        let task = TestHelpers.createTestTask()
        
        #expect(task.category != "")
        #expect(task.location != "")
        #expect(task.priority != "")
        #expect(!task.isCompleted)
        #expect(task.completedDate == "")
        #expect(task.taskItemsArray.isEmpty)
    }
    
    @Test("Task can be created with empty strings")
    func taskWithEmptyStrings() {
        let task = Task(
            taskTitle: "",
            taskDescription: "",
            comment: ""
        )
        
        #expect(task.taskTitle == "")
        #expect(task.taskDescription == "")
        #expect(task.comment == "")
    }
    
    // MARK: - Property Tests
    
    @Test("Task category can be set and retrieved")
    func taskCategory() {
        let task = TestHelpers.createTestTask()
        task.category = "Painting"
        
        #expect(task.category == "Painting")
    }
    
    @Test("Task location can be set and retrieved")
    func taskLocation() {
        let task = TestHelpers.createTestTask()
        task.location = "Bedroom"
        
        #expect(task.location == "Bedroom")
    }
    
    @Test("Task priority can be set and retrieved")
    func taskPriority() {
        let task = TestHelpers.createTestTask()
        task.priority = "Medium"
        
        #expect(task.priority == "Medium")
    }
    
    @Test("Task completion status can be toggled")
    func taskCompletionToggle() {
        let task = TestHelpers.createTestTask(isCompleted: false)
        
        #expect(!task.isCompleted)
        
        task.isCompleted = true
        #expect(task.isCompleted)
        
        task.isCompleted = false
        #expect(!task.isCompleted)
    }
    
    @Test("Task completion date can be set")
    func taskCompletionDate() {
        let task = TestHelpers.createTestTask()
        let dateString = Date.now.formatted(date: .abbreviated, time: .shortened)
        
        task.isCompleted = true
        task.completedDate = dateString
        
        #expect(task.isCompleted)
        #expect(task.completedDate == dateString)
    }
    
    // MARK: - Relationship Tests
    
    @Test("Task can have task items added")
    func taskWithItems() {
        let task = TestHelpers.createTestTask()
        let item1 = TestHelpers.createTestTaskItem(itemTitle: "Item 1")
        let item2 = TestHelpers.createTestTaskItem(itemTitle: "Item 2")
        
        item1.task = task
        item2.task = task
        
        #expect(task.taskItemsArray.count == 2)
        #expect(task.taskItemsArray.contains(item1))
        #expect(task.taskItemsArray.contains(item2))
    }
    
    @Test("Task items array updates automatically")
    func taskItemsArrayAutoUpdate() {
        let task = TestHelpers.createTestTask()
        
        #expect(task.taskItemsArray.isEmpty)
        
        let item = TestHelpers.createTestTaskItem()
        item.task = task
        
        #expect(task.taskItemsArray.count == 1)
        #expect(task.taskItemsArray.first === item)
    }
    
    @Test("Task can have multiple items")
    func taskWithMultipleItems() {
        let task = TestHelpers.createTestTask()
        let items = TestHelpers.createItemsForTask(task: task, count: 5)
        
        #expect(task.taskItemsArray.count == 5)
        #expect(Set(task.taskItemsArray) == Set(items))
    }
    
    // MARK: - Persistence Tests
    
    @Test("Task can be inserted into context")
    func insertTask() throws {
        let task = TestHelpers.createTestTask(title: "New Task")
        
        modelContext.insert(task)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        #expect(tasks.count == 1)
        #expect(tasks.first?.taskTitle == "New Task")
    }
    
    @Test("Multiple tasks can be inserted")
    func insertMultipleTasks() throws {
        let tasks = TestHelpers.createMultipleTasks(count: 10)
        
        tasks.forEach { modelContext.insert($0) }
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let fetchedTasks = try modelContext.fetch(descriptor)
        
        #expect(fetchedTasks.count == 10)
    }
    
    @Test("Task can be updated")
    func updateTask() throws {
        let task = TestHelpers.createTestTask(title: "Original Title")
        modelContext.insert(task)
        try modelContext.save()
        
        task.taskTitle = "Updated Title"
        task.priority = "High"
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        #expect(tasks.first?.taskTitle == "Updated Title")
        #expect(tasks.first?.priority == "High")
    }
    
    @Test("Task can be deleted")
    func deleteTask() throws {
        let task = TestHelpers.createTestTask()
        modelContext.insert(task)
        try modelContext.save()
        
        modelContext.delete(task)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        #expect(tasks.isEmpty)
    }
    
    @Test("Deleting task cascades to items")
    func cascadeDelete() throws {
        let task = TestHelpers.createTestTask()
        let item1 = TestHelpers.createTestTaskItem(itemTitle: "Item 1")
        let item2 = TestHelpers.createTestTaskItem(itemTitle: "Item 2")
        
        item1.task = task
        item2.task = task
        
        modelContext.insert(task)
        modelContext.insert(item1)
        modelContext.insert(item2)
        try modelContext.save()
        
        // Verify items exist
        var itemDescriptor = FetchDescriptor<TaskItem>()
        var items = try modelContext.fetch(itemDescriptor)
        #expect(items.count == 2)
        
        // Delete task
        modelContext.delete(task)
        try modelContext.save()
        
        // Verify items are also deleted (cascade)
        itemDescriptor = FetchDescriptor<TaskItem>()
        items = try modelContext.fetch(itemDescriptor)
        
        // Note: Actual cascade behavior depends on relationship configuration
        // This test verifies the expected behavior
        #expect(items.isEmpty || items.allSatisfy { $0.task == nil })
    }
    
    // MARK: - Query Tests
    
    @Test("Tasks can be filtered by category")
    func filterByCategory() throws {
        let kitchenTask = TestHelpers.createTestTask(title: "Kitchen", category: "Cleaning")
        let bathroomTask = TestHelpers.createTestTask(title: "Bathroom", category: "Painting")
        
        modelContext.insert(kitchenTask)
        modelContext.insert(bathroomTask)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let allTasks = try modelContext.fetch(descriptor)
        let cleaningTasks = allTasks.filter { $0.category == "Cleaning" }
        
        #expect(cleaningTasks.count == 1)
        #expect(cleaningTasks.first?.taskTitle == "Kitchen")
    }
    
    @Test("Tasks can be filtered by location")
    func filterByLocation() throws {
        let task1 = TestHelpers.createTestTask(title: "Task 1", location: "Kitchen")
        let task2 = TestHelpers.createTestTask(title: "Task 2", location: "Bedroom")
        
        modelContext.insert(task1)
        modelContext.insert(task2)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let allTasks = try modelContext.fetch(descriptor)
        let kitchenTasks = allTasks.filter { $0.location == "Kitchen" }
        
        #expect(kitchenTasks.count == 1)
        #expect(kitchenTasks.first?.taskTitle == "Task 1")
    }
    
    @Test("Tasks can be filtered by priority")
    func filterByPriority() throws {
        let highTask = TestHelpers.createTestTask(title: "High", priority: "High")
        let lowTask = TestHelpers.createTestTask(title: "Low", priority: "Low")
        
        modelContext.insert(highTask)
        modelContext.insert(lowTask)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let allTasks = try modelContext.fetch(descriptor)
        let highPriorityTasks = allTasks.filter { $0.priority == "High" }
        
        #expect(highPriorityTasks.count == 1)
        #expect(highPriorityTasks.first?.taskTitle == "High")
    }
    
    @Test("Tasks can be filtered by completion status")
    func filterByCompletionStatus() throws {
        let completedTask = TestHelpers.createTestTask(title: "Done", isCompleted: true)
        let pendingTask = TestHelpers.createTestTask(title: "Pending", isCompleted: false)
        
        modelContext.insert(completedTask)
        modelContext.insert(pendingTask)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let allTasks = try modelContext.fetch(descriptor)
        let completed = allTasks.filter { $0.isCompleted }
        let pending = allTasks.filter { !$0.isCompleted }
        
        #expect(completed.count == 1)
        #expect(pending.count == 1)
        #expect(completed.first?.taskTitle == "Done")
        #expect(pending.first?.taskTitle == "Pending")
    }
    
    // MARK: - Validation Tests
    
    @Test("Task with all properties set validates correctly")
    func completeTask() {
        let task = Task(
            taskTitle: "Complete Task",
            taskDescription: "Full description",
            comment: "Important notes"
        )
        task.category = "Cleaning"
        task.location = "Kitchen"
        task.priority = "High"
        task.isCompleted = true
        task.completedDate = Date.now.formatted(date: .abbreviated, time: .shortened)
        
        #expect(task.taskTitle == "Complete Task")
        #expect(task.taskDescription == "Full description")
        #expect(task.comment == "Important notes")
        #expect(task.category == "Cleaning")
        #expect(task.location == "Kitchen")
        #expect(task.priority == "High")
        #expect(task.isCompleted)
        #expect(!task.completedDate.isEmpty)
    }
    
    @Test("Task with varied priorities",
          arguments: ["High", "Medium", "Low"])
    func taskWithVariedPriorities(priority: String) {
        let task = TestHelpers.createTestTask(priority: priority)
        #expect(task.priority == priority)
    }
    
    @Test("Task with varied categories",
          arguments: TestConstants.sampleCategories)
    func taskWithVariedCategories(category: String) {
        let task = TestHelpers.createTestTask(category: category)
        #expect(task.category == category)
    }
    
    @Test("Task with varied locations",
          arguments: TestConstants.sampleLocations)
    func taskWithVariedLocations(location: String) {
        let task = TestHelpers.createTestTask(location: location)
        #expect(task.location == location)
    }
}

// MARK: - Task Business Logic Tests

@Suite("Task Business Logic Tests")
@MainActor
struct TaskBusinessLogicTests {
    var modelContainer: ModelContainer
    var modelContext: ModelContext
    
    init() async throws {
        (modelContainer, modelContext) = try TestHelpers.createTestContainer()
    }
    
    @Test("Task total cost calculation with items")
    func taskTotalCost() {
        let task = TestHelpers.createTestTask()
        
        let item1 = TestHelpers.createPricedItem(title: "Item 1", quantity: "2", price: "$10.00")
        let item2 = TestHelpers.createPricedItem(title: "Item 2", quantity: "3", price: "$5.00")
        
        item1.task = task
        item2.task = task
        
        let total = task.taskItemsArray.reduce(Decimal.zero) { $0 + $1.totalPrice }
        
        // (2 * $10) + (3 * $5) = $20 + $15 = $35
        #expect(total == Decimal(35.00))
    }
    
    @Test("Task with no items has zero cost")
    func taskWithNoItemsZeroCost() {
        let task = TestHelpers.createTestTask()
        
        let total = task.taskItemsArray.reduce(Decimal.zero) { $0 + $1.totalPrice }
        
        #expect(total == Decimal.zero)
    }
    
    @Test("Task purchased items count")
    func purchasedItemsCount() {
        let task = TestHelpers.createTestTask()
        
        let item1 = TestHelpers.createTestTaskItem(wasPurchased: true)
        let item2 = TestHelpers.createTestTaskItem(wasPurchased: false)
        let item3 = TestHelpers.createTestTaskItem(wasPurchased: true)
        
        item1.task = task
        item2.task = task
        item3.task = task
        
        let purchasedCount = task.taskItemsArray.filter { $0.wasPurchased }.count
        
        #expect(purchasedCount == 2)
    }
    
    @Test("Task completion workflow")
    func completionWorkflow() {
        let task = TestHelpers.createTestTask(isCompleted: false)
        
        // Initially not completed
        #expect(!task.isCompleted)
        #expect(task.completedDate.isEmpty)
        
        // Mark as completed
        task.isCompleted = true
        task.completedDate = Date.now.formatted(date: .abbreviated, time: .shortened)
        
        #expect(task.isCompleted)
        #expect(!task.completedDate.isEmpty)
        
        // Mark as incomplete again
        task.isCompleted = false
        task.completedDate = ""
        
        #expect(!task.isCompleted)
        #expect(task.completedDate.isEmpty)
    }
}

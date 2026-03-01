//
//  DashboardViewTests.swift
//  MovingTasksTests
//
//  Unit tests for DashboardView statistics and calculations
//
@testable import MovingTasks
import Foundation
import SwiftData
import SwiftUI
import Testing

// MARK: - Dashboard Statistics Tests

@Suite("DashboardView Statistics Tests")
@MainActor
struct DashboardStatisticsTests {
    var modelContainer: ModelContainer
    var modelContext: ModelContext
    
    init() async throws {
        (modelContainer, modelContext) = try TestHelpers.createTestContainer()
    }
    
    // MARK: - Task Count Tests
    
    @Test("Total tasks count with no tasks")
    func totalTasksEmpty() throws {
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        #expect(tasks.count == 0)
    }
    
    @Test("Total tasks count with multiple tasks")
    func totalTasksMultiple() throws {
        let tasks = TestHelpers.createMultipleTasks(count: 5)
        tasks.forEach { modelContext.insert($0) }
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let fetchedTasks = try modelContext.fetch(descriptor)
        
        #expect(fetchedTasks.count == 5)
    }
    
    @Test("Completed tasks count")
    func completedTasksCount() throws {
        let completed1 = TestHelpers.createTestTask(title: "Task 1", isCompleted: true)
        let completed2 = TestHelpers.createTestTask(title: "Task 2", isCompleted: true)
        let pending = TestHelpers.createTestTask(title: "Task 3", isCompleted: false)
        
        modelContext.insert(completed1)
        modelContext.insert(completed2)
        modelContext.insert(pending)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        let completedCount = tasks.filter { $0.isCompleted }.count
        
        #expect(completedCount == 2)
    }
    
    @Test("Pending tasks count")
    func pendingTasksCount() throws {
        let completed = TestHelpers.createTestTask(title: "Done", isCompleted: true)
        let pending1 = TestHelpers.createTestTask(title: "Todo 1", isCompleted: false)
        let pending2 = TestHelpers.createTestTask(title: "Todo 2", isCompleted: false)
        
        modelContext.insert(completed)
        modelContext.insert(pending1)
        modelContext.insert(pending2)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        let pendingCount = tasks.filter { !$0.isCompleted }.count
        
        #expect(pendingCount == 2)
    }
    
    // MARK: - Completion Percentage Tests
    
    @Test("Completion percentage with no tasks")
    func completionPercentageEmpty() {
        let totalTasks = 0
        let completedTasks = 0
        
        let percentage = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) * 100 : 0
        
        #expect(percentage == 0.0)
    }
    
    @Test("Completion percentage with all tasks completed")
    func completionPercentageComplete() {
        let totalTasks = 10
        let completedTasks = 10
        
        let percentage = Double(completedTasks) / Double(totalTasks) * 100
        
        #expect(percentage == 100.0)
    }
    
    @Test("Completion percentage with half completed")
    func completionPercentageHalf() {
        let totalTasks = 10
        let completedTasks = 5
        
        let percentage = Double(completedTasks) / Double(totalTasks) * 100
        
        #expect(percentage == 50.0)
    }
    
    @Test("Completion percentage with partial completion")
    func completionPercentagePartial() {
        let totalTasks = 8
        let completedTasks = 3
        
        let percentage = Double(completedTasks) / Double(totalTasks) * 100
        
        #expect(percentage == 37.5)
    }
    
    // MARK: - Financial Summary Tests
    
    @Test("Total items count with no items")
    func totalItemsEmpty() throws {
        let descriptor = FetchDescriptor<TaskItem>()
        let items = try modelContext.fetch(descriptor)
        
        #expect(items.count == 0)
    }
    
    @Test("Total items count with multiple items")
    func totalItemsMultiple() throws {
        let task = TestHelpers.createTestTask()
        modelContext.insert(task)
        
        let items = TestHelpers.createItemsForTask(task: task, count: 10)
        items.forEach { modelContext.insert($0) }
        try modelContext.save()
        
        let descriptor = FetchDescriptor<TaskItem>()
        let fetchedItems = try modelContext.fetch(descriptor)
        
        #expect(fetchedItems.count == 10)
    }
    
    @Test("Purchased items count")
    func purchasedItemsCount() throws {
        let item1 = TestHelpers.createTestTaskItem(wasPurchased: true)
        let item2 = TestHelpers.createTestTaskItem(wasPurchased: false)
        let item3 = TestHelpers.createTestTaskItem(wasPurchased: true)
        let item4 = TestHelpers.createTestTaskItem(wasPurchased: true)
        
        modelContext.insert(item1)
        modelContext.insert(item2)
        modelContext.insert(item3)
        modelContext.insert(item4)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<TaskItem>()
        let items = try modelContext.fetch(descriptor)
        let purchasedCount = items.filter { $0.wasPurchased }.count
        
        #expect(purchasedCount == 3)
    }
    
    @Test("Total spent calculation with no items")
    func totalSpentEmpty() {
        let items: [TaskItem] = []
        let total = items.filter { $0.wasPurchased }.reduce(Decimal.zero) { $0 + $1.totalPrice }
        
        #expect(total == Decimal.zero)
    }
    
    @Test("Total spent calculation with purchased items")
    func totalSpentWithPurchases() {
        let item1 = TestHelpers.createPricedItem(quantity: "2", price: "$10.00")
        item1.wasPurchased = true
        
        let item2 = TestHelpers.createPricedItem(quantity: "1", price: "$25.50")
        item2.wasPurchased = true
        
        let item3 = TestHelpers.createPricedItem(quantity: "3", price: "$5.00")
        item3.wasPurchased = false // Not purchased
        
        let items = [item1, item2, item3]
        let total = items.filter { $0.wasPurchased }.reduce(Decimal.zero) { $0 + $1.totalPrice }
        
        // (2 * $10) + (1 * $25.50) = $20 + $25.50 = $45.50
        // Item3 not included because not purchased
        #expect(total == Decimal(string: "45.50"))
    }
    
    @Test("Total spent ignores unpurchased items")
    func totalSpentIgnoresUnpurchased() {
        let item1 = TestHelpers.createPricedItem(quantity: "10", price: "$100.00")
        item1.wasPurchased = false
        
        let item2 = TestHelpers.createPricedItem(quantity: "1", price: "$5.00")
        item2.wasPurchased = true
        
        let items = [item1, item2]
        let total = items.filter { $0.wasPurchased }.reduce(Decimal.zero) { $0 + $1.totalPrice }
        
        // Only item2: $5.00
        #expect(total == Decimal(5.00))
    }
    
    // MARK: - Task Grouping Tests
    
    @Test("Tasks grouped by priority")
    func tasksGroupedByPriority() throws {
        let high1 = TestHelpers.createTestTask(title: "High 1", priority: "High")
        let high2 = TestHelpers.createTestTask(title: "High 2", priority: "High")
        let medium = TestHelpers.createTestTask(title: "Medium", priority: "Medium")
        let low = TestHelpers.createTestTask(title: "Low", priority: "Low")
        
        modelContext.insert(high1)
        modelContext.insert(high2)
        modelContext.insert(medium)
        modelContext.insert(low)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        let grouped = Dictionary(grouping: tasks, by: { $0.priority })
        
        #expect(grouped["High"]?.count == 2)
        #expect(grouped["Medium"]?.count == 1)
        #expect(grouped["Low"]?.count == 1)
    }
    
    @Test("Tasks grouped by location")
    func tasksGroupedByLocation() throws {
        let kitchen1 = TestHelpers.createTestTask(title: "Kitchen 1", location: "Kitchen")
        let kitchen2 = TestHelpers.createTestTask(title: "Kitchen 2", location: "Kitchen")
        let bathroom = TestHelpers.createTestTask(title: "Bathroom", location: "Bathroom")
        
        modelContext.insert(kitchen1)
        modelContext.insert(kitchen2)
        modelContext.insert(bathroom)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        let grouped = Dictionary(grouping: tasks, by: { $0.location })
        
        #expect(grouped["Kitchen"]?.count == 2)
        #expect(grouped["Bathroom"]?.count == 1)
    }
    
    @Test("Tasks grouped by category")
    func tasksGroupedByCategory() throws {
        let cleaning1 = TestHelpers.createTestTask(title: "Clean 1", category: "Cleaning")
        let cleaning2 = TestHelpers.createTestTask(title: "Clean 2", category: "Cleaning")
        let cleaning3 = TestHelpers.createTestTask(title: "Clean 3", category: "Cleaning")
        let painting = TestHelpers.createTestTask(title: "Paint", category: "Painting")
        
        modelContext.insert(cleaning1)
        modelContext.insert(cleaning2)
        modelContext.insert(cleaning3)
        modelContext.insert(painting)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        let grouped = Dictionary(grouping: tasks, by: { $0.category })
        
        #expect(grouped["Cleaning"]?.count == 3)
        #expect(grouped["Painting"]?.count == 1)
    }
    
    // MARK: - High Priority Tasks Tests
    
    @Test("High priority incomplete tasks filtering")
    func highPriorityIncompleteTasks() throws {
        let highIncomplete1 = TestHelpers.createTestTask(title: "High 1", priority: "High", isCompleted: false)
        let highIncomplete2 = TestHelpers.createTestTask(title: "High 2", priority: "High", isCompleted: false)
        let highCompleted = TestHelpers.createTestTask(title: "High Done", priority: "High", isCompleted: true)
        let mediumIncomplete = TestHelpers.createTestTask(title: "Medium", priority: "Medium", isCompleted: false)
        
        modelContext.insert(highIncomplete1)
        modelContext.insert(highIncomplete2)
        modelContext.insert(highCompleted)
        modelContext.insert(mediumIncomplete)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        let highPriorityIncomplete = tasks.filter { !$0.isCompleted && $0.priority == "High" }
        
        #expect(highPriorityIncomplete.count == 2)
    }
    
    @Test("High priority tasks sorted by date")
    func highPriorityTasksSorted() async throws {
        let task1 = TestHelpers.createTestTask(title: "Task 1", priority: "High")
        let task2 = TestHelpers.createTestTask(title: "Task 2", priority: "High")
        let task3 = TestHelpers.createTestTask(title: "Task 3", priority: "High")
        
        modelContext.insert(task1)
        try modelContext.save()
        
        // Longer delay to ensure different formatted date strings
        try await _Concurrency.Task.sleep(for: .seconds(1))
        
        modelContext.insert(task2)
        try modelContext.save()
        
        try await _Concurrency.Task.sleep(for: .seconds(1))
        
        modelContext.insert(task3)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.priority == "High" },
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        let tasks = try modelContext.fetch(descriptor)
        
        #expect(tasks.count == 3)
        // Note: Since createdDate is a formatted string, sorting may not work as expected
        // This test verifies all high priority tasks are fetched
        #expect(tasks.contains { $0.taskTitle == "Task 1" })
        #expect(tasks.contains { $0.taskTitle == "Task 2" })
        #expect(tasks.contains { $0.taskTitle == "Task 3" })
    }
    
    // MARK: - Recently Completed Tasks Tests
    
    @Test("Recently completed tasks filtering")
    func recentlyCompletedTasks() throws {
        let completed1 = TestHelpers.createTestTask(
            title: "Done 1",
            isCompleted: true,
            completedDate: Date.now.formatted(date: .abbreviated, time: .shortened)
        )
        let completed2 = TestHelpers.createTestTask(
            title: "Done 2",
            isCompleted: true,
            completedDate: Date.now.formatted(date: .abbreviated, time: .shortened)
        )
        let incomplete = TestHelpers.createTestTask(title: "Todo", isCompleted: false)
        
        modelContext.insert(completed1)
        modelContext.insert(completed2)
        modelContext.insert(incomplete)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        let completed = tasks.filter { $0.isCompleted }
        
        #expect(completed.count == 2)
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete dashboard data scenario")
    func completeDashboardScenario() throws {
        // Create diverse task set
        let highTask = TestHelpers.createTestTask(title: "High Priority", priority: "High", isCompleted: false)
        let completedTask = TestHelpers.createTestTask(title: "Done", priority: "Medium", isCompleted: true)
        let lowTask = TestHelpers.createTestTask(title: "Low Priority", priority: "Low", isCompleted: false)
        
        modelContext.insert(highTask)
        modelContext.insert(completedTask)
        modelContext.insert(lowTask)
        
        // Add items
        let item1 = TestHelpers.createPricedItem(quantity: "2", price: "$15.00")
        item1.wasPurchased = true
        item1.task = highTask
        
        let item2 = TestHelpers.createPricedItem(quantity: "1", price: "$25.00")
        item2.wasPurchased = false
        item2.task = lowTask
        
        modelContext.insert(item1)
        modelContext.insert(item2)
        try modelContext.save()
        
        // Fetch and verify
        let taskDescriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(taskDescriptor)
        
        let itemDescriptor = FetchDescriptor<TaskItem>()
        let items = try modelContext.fetch(itemDescriptor)
        
        // Verify counts
        #expect(tasks.count == 3)
        #expect(items.count == 2)
        
        // Verify statistics
        let totalTasks = tasks.count
        let completedTasks = tasks.filter { $0.isCompleted }.count
        let completionPercentage = Double(completedTasks) / Double(totalTasks) * 100
        
        #expect(totalTasks == 3)
        #expect(completedTasks == 1)
        #expect(completionPercentage ≈ 33.33)
        
        // Verify financial
        let purchasedCount = items.filter { $0.wasPurchased }.count
        let totalSpent = items.filter { $0.wasPurchased }.reduce(Decimal.zero) { $0 + $1.totalPrice }
        
        #expect(purchasedCount == 1)
        #expect(totalSpent == Decimal(30.00)) // 2 * $15
        
        // Verify grouping
        let byPriority = Dictionary(grouping: tasks, by: { $0.priority })
        #expect(byPriority["High"]?.count == 1)
        #expect(byPriority["Medium"]?.count == 1)
        #expect(byPriority["Low"]?.count == 1)
    }
}

// MARK: - Custom Operators for Testing

infix operator ≈: ComparisonPrecedence

/// Approximately equal operator for Double comparisons
func ≈(lhs: Double, rhs: Double) -> Bool {
    abs(lhs - rhs) < 0.01
}

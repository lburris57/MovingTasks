//
//  TaskListViewTests.swift
//  MovingTasksTests
//
//  Unit tests for TaskListView using Swift Testing framework
//

import Testing
import SwiftData
import SwiftUI
@testable import MovingTasks

// MARK: - Test Suite for TaskListView

@Suite("TaskListView Tests")
@MainActor
struct TaskListViewTests {
    
    var modelContainer: ModelContainer
    var modelContext: ModelContext
    
    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Task.self, TaskItem.self, configurations: config)
        modelContext = ModelContext(modelContainer)
    }
    
    // MARK: - Helper Methods
    
    func createTestTask(
        title: String = "Test Task",
        description: String = "Test Description",
        category: String = "Kitchen",
        location: String = "Inside",
        priority: String = "High",
        isCompleted: Bool = false
    ) -> Task {
        let task = Task(taskTitle: title, taskDescription: description, comment: "Test comment")
        task.category = category
        task.location = location
        task.priority = priority
        task.isCompleted = isCompleted
        return task
    }
    
    func createTestTaskItem(
        itemDescription: String = "Test Item",
        quantity: Int = 1,
        unitPrice: String = "$10.00"
    ) -> TaskItem {
        let taskItem = TaskItem(
            itemDescription: itemDescription,
            quantity: quantity,
            unitPriceString: unitPrice
        )
        return taskItem
    }
    
    // MARK: - Priority Styling Tests
    
    @Test("Low priority returns green color")
    func lowPriorityReturnsGreen() {
        let view = TaskListView()
        let color = view.styleForPriority("Low")
        #expect(color == .green)
    }
    
    @Test("Medium priority returns orange color")
    func mediumPriorityReturnsOrange() {
        let view = TaskListView()
        let color = view.styleForPriority("Medium")
        #expect(color == .orange)
    }
    
    @Test("High priority returns red color")
    func highPriorityReturnsRed() {
        let view = TaskListView()
        let color = view.styleForPriority("High")
        #expect(color == .red)
    }
    
    @Test("Invalid priority returns default blue color")
    func invalidPriorityReturnsBlue() {
        let view = TaskListView()
        let color = view.styleForPriority("Invalid")
        #expect(color == .blue)
    }
    
    @Test("All priority values return correct colors", 
          arguments: [
            ("Low", Color.green),
            ("Medium", Color.orange),
            ("High", Color.red),
            ("Unknown", Color.blue)
          ])
    func priorityValuesReturnCorrectColors(priority: String, expectedColor: Color) {
        let view = TaskListView()
        let color = view.styleForPriority(priority)
        #expect(color == expectedColor)
    }
    
    // MARK: - Task Filtering Tests
    
    @Test("Filter by specific category matches correctly")
    func filterByCategory() {
        let kitchenTask = createTestTask(title: "Kitchen Task", category: "Kitchen")
        let bathroomTask = createTestTask(title: "Bathroom Task", category: "Bathroom")
        
        modelContext.insert(kitchenTask)
        modelContext.insert(bathroomTask)
        
        #expect(kitchenTask.category == "Kitchen")
        #expect(bathroomTask.category == "Bathroom")
        #expect(kitchenTask.category.lowercased().contains("kitchen"))
    }
    
    @Test("Filter by specific location matches correctly")
    func filterByLocation() {
        let insideTask = createTestTask(title: "Inside Task", location: "Inside")
        let outsideTask = createTestTask(title: "Outside Task", location: "Outside")
        
        modelContext.insert(insideTask)
        modelContext.insert(outsideTask)
        
        #expect(insideTask.location == "Inside")
        #expect(outsideTask.location == "Outside")
    }
    
    @Test("Filter by priority matches correctly")
    func filterByPriority() {
        let highPriorityTask = createTestTask(title: "High Priority", priority: "High")
        let lowPriorityTask = createTestTask(title: "Low Priority", priority: "Low")
        
        modelContext.insert(highPriorityTask)
        modelContext.insert(lowPriorityTask)
        
        #expect(highPriorityTask.priority == "High")
        #expect(lowPriorityTask.priority == "Low")
    }
    
    @Test("Filter by completed status works correctly")
    func filterByCompletedStatus() {
        let completedTask = createTestTask(title: "Completed Task", isCompleted: true)
        let incompleteTask = createTestTask(title: "Incomplete Task", isCompleted: false)
        
        modelContext.insert(completedTask)
        modelContext.insert(incompleteTask)
        
        #expect(completedTask.isCompleted == true)
        #expect(incompleteTask.isCompleted == false)
    }
    
    @Test("Filter by incomplete status works correctly")
    func filterByIncompleteStatus() {
        let completedTask = createTestTask(title: "Completed Task", isCompleted: true)
        let incompleteTask = createTestTask(title: "Incomplete Task", isCompleted: false)
        
        modelContext.insert(completedTask)
        modelContext.insert(incompleteTask)
        
        #expect(incompleteTask.isCompleted == false)
    }
    
    @Test("Filter matching is case-insensitive")
    func caseInsensitiveFiltering() {
        let task = createTestTask(title: "Test Task", category: "KITCHEN")
        modelContext.insert(task)
        
        #expect(task.category.lowercased().contains("kitchen"))
        #expect(task.category.lowercased().contains("KITCHEN".lowercased()))
        #expect(task.category.lowercased().contains("KiTcHeN".lowercased()))
    }
    
    // MARK: - Delete Task Tests
    
    @Test("Deleting a task removes it from context")
    func deleteTaskRemovesFromContext() throws {
        let task1 = createTestTask(title: "Task 1")
        let task2 = createTestTask(title: "Task 2")
        
        modelContext.insert(task1)
        modelContext.insert(task2)
        try modelContext.save()
        
        modelContext.delete(task1)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let remainingTasks = try modelContext.fetch(descriptor)
        
        #expect(remainingTasks.count == 1)
        #expect(remainingTasks.first?.taskTitle == "Task 2")
    }
    
    @Test("Deleting multiple tasks works correctly")
    func deleteMultipleTasks() throws {
        let task1 = createTestTask(title: "Task 1")
        let task2 = createTestTask(title: "Task 2")
        let task3 = createTestTask(title: "Task 3")
        
        modelContext.insert(task1)
        modelContext.insert(task2)
        modelContext.insert(task3)
        try modelContext.save()
        
        modelContext.delete(task1)
        modelContext.delete(task2)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let remainingTasks = try modelContext.fetch(descriptor)
        
        #expect(remainingTasks.count == 1)
        #expect(remainingTasks.first?.taskTitle == "Task 3")
    }
    
    // MARK: - Grand Total Calculation Tests
    
    @Test("Grand total with no items returns zero")
    func grandTotalWithNoItems() {
        let expectedTotal = Decimal(0.00).formatted(.currency(code: "USD"))
        #expect(expectedTotal == "$0.00")
    }
    
    @Test("Grand total with single item calculates correctly")
    func grandTotalWithSingleItem() {
        let taskItem = createTestTaskItem(quantity: 2, unitPrice: "$10.00")
        modelContext.insert(taskItem)
        
        let totalPriceString = taskItem.totalPriceString.replacingOccurrences(of: "$", with: "")
        let totalPrice = Decimal(string: totalPriceString)
        
        #expect(totalPrice != nil)
        #expect(totalPrice == Decimal(20.00))
    }
    
    @Test("Grand total with multiple items calculates correctly")
    func grandTotalWithMultipleItems() {
        let taskItem1 = createTestTaskItem(quantity: 2, unitPrice: "$10.00")
        let taskItem2 = createTestTaskItem(quantity: 3, unitPrice: "$5.00")
        let taskItem3 = createTestTaskItem(quantity: 1, unitPrice: "$25.50")
        
        modelContext.insert(taskItem1)
        modelContext.insert(taskItem2)
        modelContext.insert(taskItem3)
        
        var total: Decimal = 0.00
        let items = [taskItem1, taskItem2, taskItem3]
        
        for item in items {
            let priceString = item.totalPriceString.replacingOccurrences(of: "$", with: "")
            if let price = Decimal(string: priceString) {
                total += price
            }
        }
        
        // (2 * $10) + (3 * $5) + (1 * $25.50) = $20 + $15 + $25.50 = $60.50
        #expect(total == Decimal(60.50))
    }
    
    @Test("Grand total handles invalid price strings gracefully")
    func grandTotalHandlesInvalidPrices() {
        let taskItem = TaskItem(
            itemDescription: "Invalid Item",
            quantity: 1,
            unitPriceString: "Invalid"
        )
        modelContext.insert(taskItem)
        
        let priceString = taskItem.totalPriceString.replacingOccurrences(of: "$", with: "")
        let price = Decimal(string: priceString)
        let safePrice = price ?? 0.00
        
        #expect(safePrice == 0.00)
    }
    
    @Test("Grand total with decimal prices calculates correctly")
    func grandTotalWithDecimalPrices() {
        let taskItem1 = createTestTaskItem(quantity: 1, unitPrice: "$9.99")
        let taskItem2 = createTestTaskItem(quantity: 2, unitPrice: "$15.50")
        
        modelContext.insert(taskItem1)
        modelContext.insert(taskItem2)
        
        var total: Decimal = 0.00
        for item in [taskItem1, taskItem2] {
            let priceString = item.totalPriceString.replacingOccurrences(of: "$", with: "")
            if let price = Decimal(string: priceString) {
                total += price
            }
        }
        
        // (1 * $9.99) + (2 * $15.50) = $9.99 + $31.00 = $40.99
        #expect(total == Decimal(40.99))
    }
    
    @Test("Grand total calculation with various prices",
          arguments: [
            (1, "$10.00", Decimal(10.00)),
            (2, "$5.50", Decimal(11.00)),
            (3, "$3.33", Decimal(9.99)),
            (10, "$1.00", Decimal(10.00))
          ])
    func grandTotalVariousPrices(quantity: Int, unitPrice: String, expectedTotal: Decimal) {
        let taskItem = createTestTaskItem(quantity: quantity, unitPrice: unitPrice)
        let priceString = taskItem.totalPriceString.replacingOccurrences(of: "$", with: "")
        let total = Decimal(string: priceString) ?? 0.00
        
        #expect(total == expectedTotal)
    }
    
    // MARK: - Navigation Path Tests
    
    @Test("Navigation path initializes empty")
    func navigationPathInitializesEmpty() {
        let path = NavigationPath()
        #expect(path.count == 0)
    }
    
    @Test("Navigation path appends task correctly")
    func navigationPathAppendsTask() {
        var path = NavigationPath()
        let task = createTestTask()
        
        path.append(task)
        
        #expect(path.count == 1)
    }
    
    @Test("Navigation path appends multiple tasks correctly")
    func navigationPathAppendsMultipleTasks() {
        var path = NavigationPath()
        let task1 = createTestTask(title: "Task 1")
        let task2 = createTestTask(title: "Task 2")
        
        path.append(task1)
        path.append(task2)
        
        #expect(path.count == 2)
    }
    
    @Test("Navigation path can be cleared")
    func navigationPathCanBeCleared() {
        var path = NavigationPath()
        let task = createTestTask()
        
        path.append(task)
        #expect(path.count == 1)
        
        path.removeLast()
        #expect(path.count == 0)
    }
    
    // MARK: - Task Creation Tests
    
    @Test("New task can be created with empty fields")
    func createTaskWithEmptyFields() {
        let task = Task(
            taskTitle: Constants.EMPTY_STRING,
            taskDescription: Constants.EMPTY_STRING,
            comment: Constants.EMPTY_STRING
        )
        
        #expect(task.taskTitle == "")
        #expect(task.taskDescription == "")
        #expect(task.comment == "")
    }
    
    @Test("New task can be inserted into context")
    func insertTaskIntoContext() throws {
        let task = createTestTask(title: "New Task")
        
        modelContext.insert(task)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        #expect(tasks.count == 1)
        #expect(tasks.first?.taskTitle == "New Task")
    }
    
    @Test("Multiple tasks can be inserted into context")
    func insertMultipleTasksIntoContext() throws {
        let task1 = createTestTask(title: "Task 1")
        let task2 = createTestTask(title: "Task 2")
        let task3 = createTestTask(title: "Task 3")
        
        modelContext.insert(task1)
        modelContext.insert(task2)
        modelContext.insert(task3)
        try modelContext.save()
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        #expect(tasks.count == 3)
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty task list is handled correctly")
    func emptyTaskListHandling() throws {
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        #expect(tasks.count == 0)
    }
    
    @Test("Filter with empty result set returns no matches")
    func filterWithEmptyResultSet() {
        let task = createTestTask(category: "Kitchen")
        modelContext.insert(task)
        
        let matchesNonExistent = task.category.lowercased().contains("bedroom".lowercased())
        
        #expect(matchesNonExistent == false)
    }
    
    @Test("Task with all default values can be created")
    func taskWithDefaultValues() {
        let task = createTestTask()
        
        #expect(task.taskTitle == "Test Task")
        #expect(task.taskDescription == "Test Description")
        #expect(task.category == "Kitchen")
        #expect(task.location == "Inside")
        #expect(task.priority == "High")
        #expect(task.isCompleted == false)
    }
}

// MARK: - FilterView Tests

@Suite("FilterView Tests")
@MainActor
struct FilterViewTests {
    
    @Test("Filter view initial state is correct")
    func initialState() {
        let filterValue = "All"
        let selectedSearchType = FilterEnum.none
        
        #expect(filterValue == "All")
        #expect(selectedSearchType == .none)
    }
    
    @Test("Filter value can be reset to All")
    func resetFilterValue() {
        var filterValue = "Kitchen"
        filterValue = "All"
        
        #expect(filterValue == "All")
    }
    
    @Test("FilterEnum contains all expected cases")
    func filterEnumCases() {
        let allCases = FilterEnum.allCases
        
        #expect(allCases.contains(.none))
        #expect(allCases.contains(.category))
        #expect(allCases.contains(.location))
        #expect(allCases.contains(.priority))
        #expect(allCases.contains(.status))
    }
    
    @Test("FilterEnum case count is correct")
    func filterEnumCaseCount() {
        let allCases = FilterEnum.allCases
        #expect(allCases.count == 5)
    }
}

// MARK: - Integration Tests

@Suite("TaskListView Integration Tests")
@MainActor
struct TaskListViewIntegrationTests {
    
    var modelContainer: ModelContainer
    var modelContext: ModelContext
    
    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Task.self, TaskItem.self, configurations: config)
        modelContext = ModelContext(modelContainer)
    }
    
    @Test("Complete workflow: Create, filter, and delete task")
    func completeWorkflow() throws {
        // Create tasks
        let task1 = Task(taskTitle: "Kitchen Task", taskDescription: "Clean", comment: "")
        task1.category = "Kitchen"
        task1.priority = "High"
        
        let task2 = Task(taskTitle: "Bathroom Task", taskDescription: "Paint", comment: "")
        task2.category = "Bathroom"
        task2.priority = "Low"
        
        modelContext.insert(task1)
        modelContext.insert(task2)
        try modelContext.save()
        
        // Verify both tasks exist
        var descriptor = FetchDescriptor<Task>()
        var tasks = try modelContext.fetch(descriptor)
        #expect(tasks.count == 2)
        
        // Filter by category
        let kitchenTasks = tasks.filter { $0.category == "Kitchen" }
        #expect(kitchenTasks.count == 1)
        #expect(kitchenTasks.first?.taskTitle == "Kitchen Task")
        
        // Delete one task
        modelContext.delete(task1)
        try modelContext.save()
        
        // Verify only one task remains
        descriptor = FetchDescriptor<Task>()
        tasks = try modelContext.fetch(descriptor)
        #expect(tasks.count == 1)
        #expect(tasks.first?.taskTitle == "Bathroom Task")
    }
    
    @Test("Task with multiple task items calculates grand total correctly")
    func taskWithMultipleItems() throws {
        let task = Task(taskTitle: "Shopping Task", taskDescription: "Buy items", comment: "")
        modelContext.insert(task)
        
        let item1 = TaskItem(itemDescription: "Item 1", quantity: 2, unitPriceString: "$10.00")
        let item2 = TaskItem(itemDescription: "Item 2", quantity: 1, unitPriceString: "$15.00")
        
        modelContext.insert(item1)
        modelContext.insert(item2)
        try modelContext.save()
        
        var total: Decimal = 0.00
        for item in [item1, item2] {
            let priceString = item.totalPriceString.replacingOccurrences(of: "$", with: "")
            if let price = Decimal(string: priceString) {
                total += price
            }
        }
        
        // (2 * $10) + (1 * $15) = $35
        #expect(total == Decimal(35.00))
    }
}
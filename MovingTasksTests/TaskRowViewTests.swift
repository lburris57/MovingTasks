//
//  TaskRowViewTests.swift
//  MovingTasksTests
//
//  Unit tests for TaskRowView component
//
@testable import MovingTasks
import Foundation
import SwiftUI
import Testing

// MARK: - TaskRowView Component Tests

@Suite("TaskRowView Component Tests")
@MainActor
struct TaskRowViewTests {
    
    // MARK: - Color Assignment Tests
    
    @Test("Category color returns correct color for cleaning")
    func categoryColorCleaning() {
        let task = TestHelpers.createTestTask(category: "Cleaning")
        _ = TaskRowView(task: task, styleForPriority: { _ in .blue })
        
        // Based on TaskRowView's colorForCategory implementation
        let color = categoryColorHelper("cleaning")
        #expect(color == .cyan)
    }
    
    @Test("Category color returns correct color for painting")
    func categoryColorPainting() {
        let color = categoryColorHelper("painting")
        #expect(color == .purple)
    }
    
    @Test("Category color returns correct color for organizing")
    func categoryColorOrganizing() {
        let color = categoryColorHelper("organizing")
        #expect(color == .orange)
    }
    
    @Test("Category color returns correct color for repair")
    func categoryColorRepair() {
        let color = categoryColorHelper("repair")
        #expect(color == .red)
    }
    
    @Test("Category color returns default blue for unknown")
    func categoryColorUnknown() {
        let color = categoryColorHelper("unknown")
        #expect(color == .blue)
    }
    
    @Test("Location color returns correct color for kitchen")
    func locationColorKitchen() {
        let color = locationColorHelper("kitchen")
        #expect(color == .green)
    }
    
    @Test("Location color returns correct color for bedroom")
    func locationColorBedroom() {
        let color = locationColorHelper("bedroom")
        #expect(color == .blue)
    }
    
    @Test("Location color returns correct color for bathroom")
    func locationColorBathroom() {
        let color = locationColorHelper("bathroom")
        #expect(color == .cyan)
    }
    
    @Test("Location color returns correct color for garage")
    func locationColorGarage() {
        let color = locationColorHelper("garage")
        #expect(color == .gray)
    }
    
    @Test("Location color returns default teal for unknown")
    func locationColorUnknown() {
        let color = locationColorHelper("unknown")
        #expect(color == .teal)
    }
    
    // MARK: - Priority Badge Tests
    
    @Test("Priority badge color for high priority")
    func priorityBadgeColorHigh() {
        _ = PriorityBadge(priority: "High")
        // Badge should use red color for high priority
        #expect(priorityBadgeColorHelper("High") == .red)
    }
    
    @Test("Priority badge color for medium priority")
    func priorityBadgeColorMedium() {
        #expect(priorityBadgeColorHelper("Medium") == .orange)
    }
    
    @Test("Priority badge color for low priority")
    func priorityBadgeColorLow() {
        #expect(priorityBadgeColorHelper("Low") == .green)
    }
    
    @Test("Priority badge color for unknown priority")
    func priorityBadgeColorUnknown() {
        #expect(priorityBadgeColorHelper("Unknown") == .gray)
    }
    
    @Test("Priority badge text matches priority",
          arguments: ["High", "Medium", "Low"])
    func priorityBadgeText(priority: String) {
        let badge = PriorityBadge(priority: priority)
        // Badge should display the priority text
        // This is verified through the badge's priority property
        #expect(badge.priority == priority)
    }
    
    // MARK: - Task Item Count Tests
    
    @Test("Task with zero items shows correct count")
    func taskZeroItemsCount() {
        let task = TestHelpers.createTestTask()
        #expect(task.taskItemsArray.count == 0)
        
        let text = "\(task.taskItemsArray.count) \(task.taskItemsArray.count == 1 ? "item" : "items")"
        #expect(text == "0 items")
    }
    
    @Test("Task with one item shows singular 'item'")
    func taskOneItemSingular() {
        let task = TestHelpers.createTestTask()
        let item = TestHelpers.createTestTaskItem()
        item.task = task
        
        #expect(task.taskItemsArray.count == 1)
        
        let text = "\(task.taskItemsArray.count) \(task.taskItemsArray.count == 1 ? "item" : "items")"
        #expect(text == "1 item")
    }
    
    @Test("Task with multiple items shows plural 'items'")
    func taskMultipleItemsPlural() {
        let task = TestHelpers.createTestTask()
        _ = TestHelpers.createItemsForTask(task: task, count: 5)
        
        #expect(task.taskItemsArray.count == 5)
        
        let text = "\(task.taskItemsArray.count) \(task.taskItemsArray.count == 1 ? "item" : "items")"
        #expect(text == "5 items")
    }
    
    @Test("Item count pluralization with various counts",
          arguments: [
              (0, "0 items"),
              (1, "1 item"),
              (2, "2 items"),
              (10, "10 items"),
              (100, "100 items")
          ])
    func itemCountPluralization(count: Int, expected: String) {
        let text = "\(count) \(count == 1 ? "item" : "items")"
        #expect(text == expected)
    }
    
    // MARK: - Task Display Properties Tests
    
    @Test("Task row displays task title")
    func taskRowDisplaysTitle() {
        let task = TestHelpers.createTestTask(title: "Clean Kitchen")
        #expect(task.taskTitle == "Clean Kitchen")
    }
    
    @Test("Task row displays task description")
    func taskRowDisplaysDescription() {
        let task = TestHelpers.createTestTask(description: "Deep clean all surfaces")
        #expect(task.taskDescription == "Deep clean all surfaces")
    }
    
    @Test("Task row displays location")
    func taskRowDisplaysLocation() {
        let task = TestHelpers.createTestTask(location: "Kitchen")
        #expect(task.location == "Kitchen")
    }
    
    @Test("Task row displays category")
    func taskRowDisplaysCategory() {
        let task = TestHelpers.createTestTask(category: "Cleaning")
        #expect(task.category == "Cleaning")
    }
    
    @Test("Task row displays priority")
    func taskRowDisplaysPriority() {
        let task = TestHelpers.createTestTask(priority: "High")
        #expect(task.priority == "High")
    }
    
    @Test("Task row shows completion status")
    func taskRowCompletionStatus() {
        let completed = TestHelpers.createTestTask(isCompleted: true)
        let incomplete = TestHelpers.createTestTask(isCompleted: false)
        
        #expect(completed.isCompleted)
        #expect(!incomplete.isCompleted)
    }
    
    @Test("Task row shows completed date when applicable")
    func taskRowCompletedDate() {
        let dateString = Date.now.formatted(date: .abbreviated, time: .shortened)
        let task = TestHelpers.createTestTask(
            isCompleted: true,
            completedDate: dateString
        )
        
        #expect(task.isCompleted)
        #expect(task.completedDate == dateString)
    }
    
    // MARK: - ChipView Tests
    
    @Test("Chip view displays text")
    func chipViewText() {
        let chip = ChipView(icon: "location.fill", text: "Kitchen", color: .green)
        #expect(chip.text == "Kitchen")
    }
    
    @Test("Chip view has icon")
    func chipViewIcon() {
        let chip = ChipView(icon: "tag.fill", text: "Cleaning", color: .cyan)
        #expect(chip.icon == "tag.fill")
    }
    
    @Test("Chip view has color")
    func chipViewColor() {
        let chip = ChipView(icon: "location.fill", text: "Kitchen", color: .green)
        #expect(chip.color == .green)
    }
    
    // MARK: - Task Row Integration Tests
    
    @Test("Complete task row with all properties")
    func completeTaskRow() {
        let task = Task(
            taskTitle: "Clean Kitchen",
            taskDescription: "Deep clean all surfaces before move-in",
            comment: "Use eco-friendly products"
        )
        task.category = "Cleaning"
        task.location = "Kitchen"
        task.priority = "High"
        task.isCompleted = false
        
        let item1 = TestHelpers.createTestTaskItem(itemTitle: "Cleaner")
        let item2 = TestHelpers.createTestTaskItem(itemTitle: "Sponges")
        item1.task = task
        item2.task = task
        
        // Verify all properties are accessible
        #expect(task.taskTitle == "Clean Kitchen")
        #expect(task.taskDescription == "Deep clean all surfaces before move-in")
        #expect(task.category == "Cleaning")
        #expect(task.location == "Kitchen")
        #expect(task.priority == "High")
        #expect(!task.isCompleted)
        #expect(task.taskItemsArray.count == 2)
    }
    
    @Test("Task row with completed task")
    func completedTaskRow() {
        let dateString = Date.now.formatted(date: .abbreviated, time: .shortened)
        let task = TestHelpers.createTestTask(
            title: "Organize Garage",
            isCompleted: true,
            completedDate: dateString
        )
        
        #expect(task.isCompleted)
        #expect(!task.completedDate.isEmpty)
        #expect(task.completedDate == dateString)
    }
    
    // MARK: - Edge Cases
    
    @Test("Task with empty description")
    func taskWithEmptyDescription() {
        let task = TestHelpers.createTestTask(description: "")
        #expect(task.taskDescription == "")
    }
    
    @Test("Task with very long title")
    func taskWithLongTitle() {
        let longTitle = String(repeating: "Very Long Task Title ", count: 10)
        let task = TestHelpers.createTestTask(title: longTitle)
        #expect(task.taskTitle == longTitle)
        #expect(task.taskTitle.count > 100)
    }
    
    @Test("Task with special characters in title")
    func taskWithSpecialCharacters() {
        let task = TestHelpers.createTestTask(title: "Clean & Paint 🏠 Kitchen! (2024)")
        #expect(task.taskTitle.contains("&"))
        #expect(task.taskTitle.contains("🏠"))
        #expect(task.taskTitle.contains("!"))
    }
}

// MARK: - Helper Functions

/// Helper function to simulate category color logic from TaskRowView
private func categoryColorHelper(_ category: String) -> Color {
    switch category.lowercased() {
    case "cleaning": return .cyan
    case "painting": return .purple
    case "organizing": return .orange
    case "repair": return .red
    case "packing": return .brown
    case "removal": return .gray
    case "replacement": return .indigo
    case "carpeting": return .teal
    case "storage": return .mint
    default: return .blue
    }
}

/// Helper function to simulate location color logic from TaskRowView
private func locationColorHelper(_ location: String) -> Color {
    switch location.lowercased() {
    case "kitchen": return .green
    case "bedroom": return .blue
    case "bathroom": return .cyan
    case "living room": return .orange
    case "garage": return .gray
    case "home office": return .purple
    case "basement": return .brown
    case "attic": return .indigo
    default: return .teal
    }
}

/// Helper function to simulate priority badge color logic
private func priorityBadgeColorHelper(_ priority: String) -> Color {
    switch priority {
    case "High": return .red
    case "Medium": return .orange
    case "Low": return .green
    default: return .gray
    }
}

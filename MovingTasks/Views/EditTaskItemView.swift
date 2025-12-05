//
//  EditTaskItemView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/12/23.
//
import FloatingPromptTextField
import SwiftData
import SwiftUI

/// A comprehensive view for creating and editing task items within a task.
///
/// `EditTaskItemView` provides a detailed form interface for managing individual task items,
/// including basic information, purchase details, and pricing calculations. The view automatically
/// validates required fields and deletes incomplete task items to maintain data integrity.
///
/// ## Key Features
///
/// - **Basic Information**: Title, description, and comment fields using floating prompt text fields
/// - **Purchase Tracking**: Toggle to indicate whether an item was purchased
/// - **Purchase Details**: URL, quantity, and purchase price fields (shown only when purchased)
/// - **Automatic Calculations**: Total price calculated from quantity × purchase price
/// - **Purchase Date**: Date picker for tracking when items were purchased
/// - **Navigation**: Multi-level navigation support to return to task list, task items list, or edit task
/// - **Data Validation**: Automatic deletion of incomplete task items when the view disappears
///
/// ## Data Validation
///
/// Three fields must be populated for a task item to be saved:
/// - `itemTitle`
/// - `itemDescription`
/// - `comment`
///
/// If any of these fields are empty when the view disappears, the task item is automatically
/// deleted from the SwiftData model context.
///
/// ## Purchase Information
///
/// When the "Was this item purchased?" checkbox is toggled:
/// - **Checked**: Purchase date is set to the current date, and purchase-related fields become visible
/// - **Unchecked**: Purchase date is set to the distant future, and purchase fields are hidden
///
/// ## Navigation Controls
///
/// The toolbar provides a menu with three navigation options:
/// - Return to Task Item List
/// - Return to Edit Task
/// - Return to Task List (root)
///
/// ## Usage Example
///
/// ```swift
/// @State private var navigationPath = NavigationPath()
/// let newTaskItem = TaskItem(itemTitle: "", itemDescription: "", comment: "")
///
/// NavigationStack(path: $navigationPath) {
///     EditTaskItemView(taskItem: newTaskItem, path: $navigationPath)
/// }
/// ```
///
/// - Important: Requires a SwiftData model context in the environment.
/// - Note: The navigation title changes between "Add Task Item" and "Edit Task Item"
///   based on whether required fields are populated.
///
struct EditTaskItemView: View
{
    // MARK: - Properties
    
    /// The task item being edited or created.
    ///
    /// Marked as `@Bindable` to enable two-way data binding between the view and
    /// the task item's properties. Changes are immediately reflected in the SwiftData model context.
    @Bindable var taskItem: TaskItem
    
    /// The navigation path for managing the navigation stack.
    ///
    /// Used to programmatically navigate back to various levels in the view hierarchy.
    @Binding var path: NavigationPath
    
    /// The quantity as an integer (currently unused).
    ///
    /// This property appears to be for potential future use with integer-based quantity handling.
    @State private var quantityInt = 0
    
    /// The SwiftData model context for performing database operations.
    ///
    /// Used for deleting invalid task items when required fields are not populated.
    @Environment(\.modelContext) var modelContext
    
    /// The current color scheme (light or dark mode).
    ///
    /// Used to adjust text field prompt colors for optimal visibility in different appearances.
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Helper Methods
    
    /// Validates and deletes the task item if required fields are empty.
    ///
    /// This method is called automatically when the view disappears. If any of the three
    /// required fields (title, description, or comment) are empty, the task item is deleted
    /// from the model context with animation.
    func validateTaskItem()
    {
        if taskItem.itemTitle == Constants.EMPTY_STRING ||
             taskItem.itemDescription == Constants.EMPTY_STRING ||
             taskItem.comment == Constants.EMPTY_STRING
        {
            withAnimation
            {
                modelContext.delete(taskItem)
            }
        }
    }
    
    /// Checks whether all required fields are populated.
    ///
    /// Used to determine the navigation title and potentially for other validation purposes.
    ///
    /// - Returns: `true` if all required fields have values, `false` otherwise
    func validateFields() -> Bool
    {
        if taskItem.itemTitle == Constants.EMPTY_STRING || 
             taskItem.itemDescription == Constants.EMPTY_STRING ||
             taskItem.comment == Constants.EMPTY_STRING
        {
            return false
        }

        return true
    }
    
    /// Toggles the purchased status of the task item.
    ///
    /// When toggled to purchased, sets the purchase date to the current date.
    /// When toggled to not purchased, sets the purchase date to the distant future.
    /// This method is called by the checkbox button in the purchase information section.
    func toggleWasPurchased()
    {
        taskItem.wasPurchased.toggle()
    }
    
    // MARK: - Body
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            Form
            {
                Section("Task Item Information")
                {
                    FloatingPromptTextField(text: $taskItem.itemTitle, prompt: Text("Title:")
                        .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                    
                    FloatingPromptTextField(text: $taskItem.itemDescription, prompt: Text("Description:")
                        .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                    
                    FloatingPromptTextField(text: $taskItem.comment, prompt: Text("Comment:")
                        .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                }
                
                Section("Purchase Information")
                {
                    VStack(alignment: .leading, spacing: 12)
                    {
                        Text("Was this item purchased?").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                        
                        HStack
                        {
                            Text(taskItem.wrappedWasPurchased)
                            
                            Spacer()
                            
                            Button(action:
                            {
                                toggleWasPurchased()
                                
                                if taskItem.wasPurchased
                                {
                                    taskItem.purchaseDate = Date.now//.formatted(date: .abbreviated, time: .shortened)
                                }
                                else
                                {
                                    taskItem.purchaseDate = Date.distantFuture
                                }
                            },
                            label:
                            {
                                Image(systemName: taskItem.wasPurchased ? "checkmark.square" : "square")
                                    .foregroundStyle(colorScheme == .dark ? .gray : .blue)
                            })
                        }
                        
                        if taskItem.wasPurchased
                        {
                            FloatingPromptTextField(text: $taskItem.url, prompt: Text("URL:")
                                .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                            .floatingPromptScale(1.0)
                            
                            FloatingPromptTextField(text: $taskItem.quantity, prompt: Text("Quantity:")
                                .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                            .floatingPromptScale(1.0)
                            
                            FloatingPromptTextField(text: $taskItem.purchasedPrice, prompt: Text("Purchase Price:")
                                .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                            .floatingPromptScale(1.0)
                            
                            VStack(alignment: .leading, spacing: 12)
                            {
                                Text("Total Price:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                                
                                Text("\(taskItem.formattedTotalPriceString)").font(.body).bold()
                                
                                Text("Purchase Date:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                                
                                DatePicker("Please enter a date", selection: $taskItem.purchaseDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .toolbar
        {
            Menu("\(Image(systemName: "arrowshape.turn.up.left.fill"))")
            {
                Button("Go to Task Item List")
                {
                    path.removeLast(taskItem.task!.taskItems!.count)
                }
            
                Button("Go to Edit Task")
                {
                    path.removeLast(2)
                }
            
                Button("Go to Task List")
                {
                    path = NavigationPath()
                }
            }
            .padding(.horizontal)
        }
        .onDisappear(perform: validateTaskItem)
        .navigationTitle(validateFields() ? "Edit Task Item" : "Add Task Item")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//
//  TaskItemListView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/13/23.
//
import SwiftUI
import SwiftData

/// A view that displays a list of task items associated with a specific task.
///
/// `TaskItemListView` presents a scrollable list of task items with their details, including
/// title, description, and purchase price (if applicable). It also calculates and displays
/// a grand total of all task item prices.
///
/// ## Key Features
///
/// - **Grand Total Calculation**: Automatically calculates the sum of all task item prices
///   and displays it at the top of the view
/// - **Task Item Display**: Shows each task item with its title, description, and formatted price
///   (only displayed for purchased items)
/// - **Navigation**: Supports navigation to individual task item edit views
/// - **Deletion**: Allows swipe-to-delete functionality for removing task items
/// - **Return Navigation**: Provides a toolbar menu to return to the task list
///
/// ## Data Display
///
/// Each task item in the list shows:
/// - Item title (bold, primary text color)
/// - Item description (secondary text color)
/// - Formatted total price (only if the item was purchased)
///
/// ## Navigation Controls
///
/// The toolbar provides a menu with a single option to return to the task list using
/// the router to dismiss the screen.
///
/// ## Usage Example
///
/// ```swift
/// router.showScreen(.push) { _ in
///     TaskItemListView(taskItems: task.taskItemsArray)
/// }
/// ```
///
/// - Important: Requires a SwiftData model context in the environment for deletion operations.
/// - Note: The grand total is recalculated each time the view appears.
///
struct TaskItemListView: View 
{
    // MARK: - Environment Properties
    
    /// The current color scheme (light or dark mode).
    ///
    /// Used to adjust UI elements for optimal visibility in different appearances.
    @Environment(\.colorScheme) var colorScheme
    
    /// The SwiftData model context for performing database operations.
    ///
    /// Used for deleting task items when the user swipes to delete.
    @Environment(\.modelContext) var modelContext
    
    // MARK: - State Properties
    
    /// The formatted grand total of all task item prices.
    ///
    /// Calculated by summing the total price of all task items and formatted as USD currency.
    @State private var grandTotal: String = Constants.ZERO_STRING
    
    // MARK: - Input Properties
    
    /// The array of task items to display.
    ///
    /// Typically passed from a parent view containing the task items associated with a specific task.
    var taskItems: [TaskItem]
    
    /// The navigation path for managing the navigation stack.
    ///
    /// Used to programmatically navigate back to the task list or other levels in the hierarchy.
    @Binding var path: NavigationPath
    
    // MARK: - Helper Methods
    
    /// Deletes task items at the specified index positions.
    ///
    /// This method is called when the user swipes to delete a task item from the list.
    /// The task item is removed from the SwiftData model context, which automatically
    /// triggers a save and updates the UI.
    ///
    /// - Parameter indexSet: The set of indices in the taskItems array to delete
    private func deleteTaskItem(at indexSet: IndexSet)
    {
        indexSet.forEach
        {
            index in

            let taskItem = taskItems[index]

            // Delete the task item
            modelContext.delete(taskItem)
        }
    }
    
    /// Calculates and updates the grand total of all task item prices.
    ///
    /// This method iterates through all task items, extracts their total price values
    /// (removing currency symbols), sums them, and formats the result as a USD currency string.
    ///
    /// The calculation includes debug print statements to track the accumulation of the total.
    /// The final result is stored in the `grandTotal` state property, which triggers a UI update.
    ///
    /// - Note: This method is called automatically when the view appears via the
    ///   `.onAppear(perform:)` modifier.
    private func populateGrandTotal()
    {
        var total: Decimal = 0.00
        
        for taskItem in taskItems
        {
            let totalPrice = Decimal(string: taskItem.totalPriceString.replacingOccurrences(of: Constants.DOLLAR_SIGN, with: Constants.EMPTY_STRING))
            
            print("Total price string from taskItem is: \( taskItem.totalPriceString)")
            print("Total price from taskItem is: \(totalPrice ?? 0.00)")
            
            total += totalPrice ?? 0.00
            
            print("Total is: \(total)")
        }
        
        grandTotal = total.formatted(.currency(code: "USD"))
    }
    
    // MARK: - Body
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            HStack
            {
                Spacer()
                
                Text("Grand Total: " + grandTotal).font(.body).bold()
                
                Spacer()
            }
            
            List
            {
                ForEach(taskItems)
                {
                    taskItem in

                    NavigationLink(value: taskItem)
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text("\(taskItem.itemTitle)").font(.body).foregroundStyle(.primary).bold()
                            Text("\(taskItem.itemDescription)").font(.callout).foregroundStyle(.secondary).bold()
                            
                            if(taskItem.wasPurchased)
                            {
                                Text("\(taskItem.formattedTotalPriceString)").font(.callout).foregroundStyle(.secondary).bold()
                            }
                        }
                    }
                }
                .onDelete(perform: deleteTaskItem)
                .listStyle(.plain)
                .padding(.bottom)
                .navigationTitle("Task Item List")
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar
            {
                Menu("\(Image(systemName: "arrowshape.turn.up.left.fill"))")
                {
                    Button("Go to Task List")
                    {
                        path = NavigationPath()
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationDestination(for: TaskItem.self)
        {
            taskItem in

            EditTaskItemView(taskItem: taskItem, path: $path)
        }
        .onAppear(perform: populateGrandTotal)
    }
}

//#Preview
//{
//    do
//    {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//
//        let container = try ModelContainer(for: Task.self, TaskItem.self, configurations: config)
//
//        return TaskItemListView().modelContainer(container)
//    }
//    catch
//    {
//        Text("Failed to create container: \(error.localizedDescription)")
//    }
//}

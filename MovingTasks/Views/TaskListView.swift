//
//  TaskListView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import SwiftData
import SwiftUI

private struct NewTaskRoute: Hashable {}

/// The main view that displays a list of tasks with filtering, sorting, and navigation capabilities.
///
/// `TaskListView` serves as the primary interface for managing tasks in the MovingTasks application.
/// It provides comprehensive filtering options by category, location, priority, and status, along with
/// real-time calculation of a grand total based on all task items' purchase prices.
///
/// ## Key Features
///
/// - **Task Display**: Shows all tasks in a scrollable list with detailed information including
///   title, description, location, category, status, and creation date
/// - **Filtering**: Dynamic filtering by category, location, priority, or completion status
/// - **Grand Total Calculation**: Automatically calculates and displays the sum of all task item prices
/// - **Priority Visualization**: Color-coded circles indicate task priority (green for low, orange for medium, red for high)
/// - **Task Items Counter**: Displays the count of task items associated with each task
/// - **Task Management**: Add new tasks, edit existing tasks, and delete tasks with swipe-to-delete
/// - **Empty States**: Provides helpful content unavailable views when no tasks exist or no tasks match the filter
///
/// ## Data Management
///
/// The view uses SwiftData's `@Query` to automatically fetch and observe changes to tasks and task items.
/// Tasks are sorted by creation date (newest first) and priority (highest first) by default.
///
/// ## Navigation
///
/// Uses `NavigationStack` with `NavigationPath` to enable deep linking to task editing views
/// and their associated task items. The navigation state is maintained and can be programmatically
/// controlled to return to specific levels in the hierarchy.
///
/// ## Usage Example
///
/// ```swift
/// @main
/// struct MovingTasksApp: App {
///     var body: some Scene {
///         WindowGroup {
///             TaskListView()
///                 .modelContainer(for: [Task.self, TaskItem.self])
///         }
///     }
/// }
/// ```
///
/// - Important: Requires a SwiftData model container in the environment for Task and TaskItem models.
/// - Note: The grand total is recalculated each time the view appears to ensure accuracy.
///
struct TaskListView: View
{
    // MARK: - Environment and Query Properties
    
    /// The SwiftData model context for performing database operations.
    @Environment(\.modelContext) private var modelContext

    /// All tasks in the database, sorted by title.
    ///
    /// This query automatically updates when tasks are added, modified, or deleted.
    @Query(sort: \Task.taskTitle) var tasks: [Task]
    
    /// All task items in the database.
    ///
    /// Used for calculating the grand total of all purchase prices across all tasks.
    @Query var taskItems: [TaskItem]
    
    // MARK: - State Properties
    
    /// The formatted grand total of all task item prices.
    ///
    /// Calculated by summing the total price of all task items and formatted as USD currency.
    @State private var grandTotal: String = Constants.ZERO_STRING

    /// The current filter value selected by the user.
    ///
    /// The meaning of this value depends on `selectedSearchType`. For example:
    /// - "All" means no filtering
    /// - "Cleaning" filters by category
    /// - "Completed" filters by completion status
    @State private var filterValue: String = "All"
    
    /// The type of filter currently being applied.
    ///
    /// Determines which task property is being filtered (category, location, priority, status, or none).
    @State private var selectedSearchType: FilterEnum = .none

    /// The navigation path for managing the navigation stack.
    ///
    /// Used to programmatically navigate to edit views and return to specific levels in the hierarchy.
    @State private var path = NavigationPath()
    
    /// The sort descriptors for ordering tasks.
    ///
    /// Currently unused but available for future implementation of dynamic sorting.
    @State private var sortOrder = 
    [
        SortDescriptor(\Task.createdDate, order: .reverse),
        SortDescriptor(\Task.priority, order: .reverse)
    ]
    
    // MARK: - Computed Properties
    
    /// Returns tasks filtered according to the current filter settings.
    ///
    /// The filtering logic varies based on `selectedSearchType`:
    /// - `.none`: No filtering, returns all tasks
    /// - `.category`: Filters by task category (case-insensitive)
    /// - `.location`: Filters by task location (case-insensitive)
    /// - `.priority`: Filters by task priority (case-insensitive)
    /// - `.status`: Filters by completion status (completed, incomplete, or all)
    ///
    /// The special value "All" bypasses filtering for category, location, and priority types.
    var filteredTasks: [Task]
    {
        let filteredTasks = tasks
        
        switch selectedSearchType
        {
            case .none:
                return filteredTasks
            
            case .category:
            if filterValue == "All"
            {
                return filteredTasks
            }
            else
            {
                return filteredTasks.filter {$0.category.lowercased().contains(filterValue.lowercased())}
            }
                
            case .location:
            if filterValue == "All"
            {
                return filteredTasks
            }
            else
            {
                return filteredTasks.filter {$0.location.lowercased().contains(filterValue.lowercased())}
            }
                
            case .priority:
            if filterValue == "All"
            {
                return filteredTasks
            }
            else
            {
                return filteredTasks.filter {$0.priority.lowercased().contains(filterValue.lowercased())}
            }
                
            case .status:
            if filterValue == "Completed"
            {
                return filteredTasks.filter {$0.isCompleted}
            }
            else if filterValue == "Incomplete"
            {
                return filteredTasks.filter {!$0.isCompleted}
            }
            else
            {
                return filteredTasks
            }
        }
    }

    // MARK: - Helper Methods
    
    /// Returns the appropriate color for a task based on its priority level.
    ///
    /// Priority colors:
    /// - Low: Green
    /// - Medium: Orange
    /// - High: Red
    /// - Unknown/Other: Blue (fallback)
    ///
    /// - Parameter value: The priority string from the task
    /// - Returns: The color to display for the priority indicator
    func styleForPriority(_ value: String) -> Color
    {
        let priority = PriorityEnum(rawValue: value)

        switch priority
        {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        default:
            return .blue
        }
    }

    /// Deletes tasks at the specified index positions.
    ///
    /// This method is called when the user swipes to delete a task from the list.
    /// The task is removed from the SwiftData model context, which automatically
    /// triggers a save and updates the UI.
    ///
    /// - Parameter indexSet: The set of indices in the tasks array to delete
    private func deleteTask(at indexSet: IndexSet)
    {
        indexSet.forEach
        {
            index in

            let task = tasks[index]

            // Delete the task
            modelContext.delete(task)
        }
    }
    
    /// Calculates and updates the grand total of all task item prices.
    ///
    /// This method iterates through all task items in the database, extracts their
    /// total price values (removing currency symbols), sums them, and formats the
    /// result as a USD currency string.
    ///
    /// The calculation includes debug print statements to track the accumulation
    /// of the total. The final result is stored in the `grandTotal` state property,
    /// which triggers a UI update.
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
        NavigationStack(path: $path)
        {
            ZStack
            {
                LinearGradient(colors: [.gray, .teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .opacity(0.25)
                    .ignoresSafeArea()
                
                VStack
                {
                    if tasks.count == 0
                    {
                        ContentUnavailableView
                        {
                            Label("No tasks are available for display.", systemImage: "calendar.badge.clock")
                        }
                        description:
                        {
                            Text("Please click the plus icon to add a new task.")
                        }
                    }
                    else if filteredTasks.count == 0
                    {
                        FilterView(filterValue: $filterValue, selectedSearchType: $selectedSearchType)
                        
                        ContentUnavailableView
                        {
                            Label("No tasks were found for display.", systemImage: "calendar.badge.clock")
                        }
                        description:
                        {
                            Text("Please refine your filter.")
                        }
                    }
                    else
                    {
                        FilterView(filterValue: $filterValue, selectedSearchType: $selectedSearchType)

                        HStack
                        {
                            Spacer()
                            
                            Text("Grand Total: " + grandTotal).font(.body).bold()
                            
                            Spacer()
                        }
                        
                        List
                        {
                            ForEach(filteredTasks)
                            {
                                task in
                                
                                HStack
                                {
                                    NavigationLink(value: task)
                                    {
                                        VStack(alignment: .leading)
                                        {
                                            HStack
                                            {
                                                Circle()
                                                    .fill(styleForPriority(task.priority))
                                                    .frame(width: 15, height: 15)
                                                
                                                Text(task.taskTitle).font(.headline)
                                                
                                                Spacer()
                                                
                                                Text("Task Items:").font(.callout)
                                                
                                                Text("\(task.taskItemsArray.count)").font(.body).bold()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(.white)
                                                    .background(.blue)
                                                    .clipShape(.capsule)
                                            }
                                            
                                            Text(task.taskDescription).font(.callout)
                                            
                                            Text("\nLocation: \(task.location)").font(.caption).bold()
                                            Text("Category: \(task.category)").font(.caption).bold()
                                            Text("Status: \(task.wrappedIsCompleted)").font(.caption).bold()
                                            Text("Date Created: \(task.createdDate)").font(.caption).bold()
                                            
                                            if task.isCompleted
                                            {
                                                Text("Date Completed: \(task.completedDate)").font(.caption).bold()
                                            }
                                        }
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                            .onDelete(perform: deleteTask)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filteredTasks)
                        }
                        .navigationDestination(for: Task.self)
                        {
                            task in
                            
                            EditTaskView(task: task, path: $path)
                        }
                        .navigationDestination(for: NewTaskRoute.self) { _ in
                            // Present EditTaskView in creation mode without inserting a Task upfront
                            let placeholder = Task(taskTitle: Constants.EMPTY_STRING, taskDescription: Constants.EMPTY_STRING, comment: Constants.EMPTY_STRING)
                            EditTaskView(task: placeholder, path: $path, isNew: true)
                        }
                        .listStyle(.plain)
                        .padding()
                    }
                }
                .toolbar
                {
                    ToolbarItem(placement: .topBarTrailing)
                    {
                        Button(action:
                        {
                            path.append(NewTaskRoute())
                        },
                        label:
                        {
                            HStack
                            {
                                Text("Add Task").font(.body)
                                Image(systemName: "plus")
                            }
                        })
                    }

                    if tasks.count > 0
                    {
                        ToolbarItem(placement: .topBarLeading)
                        {
                            EditButton()
                        }
                    }
                }
                .navigationTitle("Tasks")
            }.onAppear(perform: populateGrandTotal)
        }
    }
}

/// A view that provides filtering controls for the task list.
///
/// `FilterView` presents a two-tier filtering interface:
/// 1. A picker to select the type of filter (category, location, priority, status, or none)
/// 2. A context-sensitive picker that shows appropriate values based on the selected filter type
///
/// ## Filter Types
///
/// - **None**: No filtering applied
/// - **Location**: Filter by task location (uses `LocationEnum` values)
/// - **Category**: Filter by task category (uses `CategoryEnum` values)
/// - **Priority**: Filter by task priority (uses `PriorityEnum` values)
/// - **Status**: Filter by completion status (uses `StatusEnum` values)
///
/// ## Behavior
///
/// When the filter type changes, the filter value automatically resets to "All" to prevent
/// showing results from a previously selected filter with mismatched criteria.
///
/// ## Usage Example
///
/// ```swift
/// @State private var filterValue = "All"
/// @State private var selectedSearchType: FilterEnum = .none
///
/// FilterView(filterValue: $filterValue, selectedSearchType: $selectedSearchType)
/// ```
///
/// - Note: The second picker only appears when a filter type other than `.none` is selected.
///
struct FilterView: View
{
    // MARK: - Properties
    
    /// The currently selected filter value.
    ///
    /// The meaning of this value depends on the selected search type. For example,
    /// if filtering by category, this might be "Cleaning" or "Painting".
    @Binding  var filterValue: String
    
    /// The type of filter being applied.
    ///
    /// Determines which set of filter values to display in the second picker.
    @Binding var selectedSearchType: FilterEnum
    
    // MARK: - Helper Methods
    
    /// Resets the filter value to "All".
    ///
    /// Called automatically when the filter type changes to ensure the filter
    /// value is appropriate for the newly selected filter type.
    func setFilterValue()
    {
        filterValue = "All"
    }
    
    // MARK: - Body
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack
            {
                Text("Filter List:   ").font(.body).foregroundStyle(.secondary).bold()
                
                Picker(Constants.EMPTY_STRING, selection: $selectedSearchType)
                {
                    ForEach(FilterEnum.allCases)
                    {
                        filter in
                        
                        Text(filter.filterType).tag(filter)
                    }
                }
                .pickerStyle(.menu)
                .onTapGesture(perform: setFilterValue)
                .onChange(of: selectedSearchType) 
                {
                    setFilterValue()
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            HStack
            {
                if selectedSearchType != .none
                {
                    Text("Filter Value:").font(.body).foregroundStyle(.secondary).bold()
                    
                    if selectedSearchType == .location
                    {
                        Picker(Constants.EMPTY_STRING, selection: $filterValue)
                        {
                            ForEach(LocationEnum.allCases)
                            {
                                location in
                                
                                Text(location.title).tag(location.title)
                            }
                        }.pickerStyle(.menu)
                    }
                    
                    if selectedSearchType == .category
                    {
                        Picker(Constants.EMPTY_STRING, selection: $filterValue)
                        {
                            ForEach(CategoryEnum.allCases)
                            {
                                category in
                                
                                Text(category.title).tag(category.title)
                            }
                        }.pickerStyle(.menu)
                    }
                    
                    if selectedSearchType == .priority
                    {
                        Picker(Constants.EMPTY_STRING, selection: $filterValue)
                        {
                            ForEach(PriorityEnum.allCases)
                            {
                                priority in
                                
                                Text(priority.title).tag(priority.title)
                            }
                        }.pickerStyle(.menu)
                    }
                    
                    if selectedSearchType == .status
                    {
                        Picker(Constants.EMPTY_STRING, selection: $filterValue)
                        {
                            ForEach(StatusEnum.allCases)
                            {
                                status in
                                
                                Text(status.title).tag(status.rawValue)
                            }
                        }.pickerStyle(.menu)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview
{
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, TaskItem.self, configurations: config)
    
    TaskListView()
        .modelContainer(container)
}


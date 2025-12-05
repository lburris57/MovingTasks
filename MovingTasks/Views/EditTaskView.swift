//
//  EditTaskView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//

import FloatingPromptTextField
import SwiftData
import SwiftUI
import PhotosUI

/// A comprehensive view for creating and editing tasks within the MovingTasks application.
///
/// `EditTaskView` provides a full-featured form interface for managing all aspects of a task, including:
/// - Basic task information (title, description, and comments)
/// - Task categorization (location, category, and priority)
/// - Visual documentation with before and after photos
/// - Task completion status and timestamps
/// - Navigation to and management of associated task items
///
/// The view implements automatic validation of required fields and will delete incomplete tasks
/// when the view disappears to maintain data integrity. It dynamically adjusts its interface
/// based on whether a task is being created or edited.
///
/// ## Data Validation
///
/// The view enforces that three fields must be populated before a task can be saved:
/// - `taskTitle`
/// - `taskDescription`
/// - `comment`
///
/// If these fields are empty when the view disappears, the task is automatically deleted from
/// the SwiftData model context.
///
/// ## Photo Management
///
/// Users can add before and after photos to document task progress. Photos are selected using
/// `PhotosPicker` and are automatically loaded and converted to `Data` for storage in SwiftData.
/// The photos are displayed with rounded corners and labeled overlays.
///
/// ## Navigation
///
/// The view integrates with SwiftUI's navigation system using `NavigationPath` to support:
/// - Returning to the task list
/// - Navigating to the task item list
/// - Navigating to individual task item edit views
///
/// ## Usage Example
///
/// ```swift
/// @State private var navigationPath = NavigationPath()
/// let newTask = Task(taskTitle: "", taskDescription: "", comment: "")
///
/// NavigationStack(path: $navigationPath) {
///     EditTaskView(task: newTask, path: $navigationPath)
/// }
/// ```
///
/// - Note: This view requires a SwiftData model context to be present in the environment.
/// - Important: The task must have empty required fields deleted automatically to prevent
///   incomplete records from being saved.
///
struct EditTaskView: View
{
    // MARK: - Properties
    
    /// The task being edited or created.
    ///
    /// Marked as `@Bindable` to enable two-way data binding between the view and the task's
    /// properties throughout the interface. Changes to the task are immediately reflected
    /// in the SwiftData model context.
    @Bindable var task: Task

    /// The SwiftData model context for performing database operations.
    ///
    /// Used for inserting new task items and deleting invalid tasks. The context is
    /// automatically provided by the SwiftUI environment.
    @Environment(\.modelContext) var modelContext

    /// The current color scheme (light or dark mode).
    ///
    /// Used to adjust label colors and UI elements for optimal visibility in both
    /// light and dark appearances.
    @Environment(\.colorScheme) var colorScheme
    
    /// The currently selected "before" photo from the photo library.
    ///
    /// When changed, triggers async loading of the photo data which is then stored
    /// in the task's `beforeImage` property.
    @State var selectedBeforePhoto: PhotosPickerItem?
    
    /// The currently selected "after" photo from the photo library.
    ///
    /// When changed, triggers async loading of the photo data which is then stored
    /// in the task's `afterImage` property.
    @State var selectedAfterPhoto: PhotosPickerItem?

    /// The navigation path used for programmatic navigation.
    ///
    /// Binding to the navigation stack's path enables:
    /// - Popping back to root (task list)
    /// - Pushing to task item list view
    /// - Pushing to task item edit view
    @Binding var path: NavigationPath

    // MARK: - Methods
    
    /// Toggles the completion status of the task.
    ///
    /// This method flips the `isCompleted` boolean on the task. The calling code is
    /// responsible for updating the `completedDate` property based on the new state.
    ///
    /// - Note: This method only toggles the boolean flag. Date management is handled
    ///   by the button action in the Status Information section.
    func toggleIsComplete()
    {
        task.isCompleted.toggle()
    }

    // MARK: - Body
    
    /// The main view body containing the task editing interface.
    ///
    /// Organized into multiple sections within a `Form`:
    /// 1. **Task Information** - Text fields and pickers for task details
    /// 2. **Before & After Images** - Photo selection and display
    /// 3. **Task Items** - Navigation to associated task items (conditional)
    /// 4. **Status Information** - Completion status and dates
    ///
    /// The view includes a toolbar with:
    /// - Leading button for navigation (Save/Back)
    /// - Trailing button to add new task items
    ///
    /// - Returns: A view displaying the task editing interface with a gradient background.
    var body: some View
    {
        ZStack
        {
            LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.25)
                .ignoresSafeArea()
            
            Form
            {
                // Task Information Section
                // Contains text fields for title, description, and comment,
                // plus pickers for location, category, priority, and creation date display
                Section("Task Information")
                {
                    Group
                    {
                        FloatingPromptTextField(text: $task.taskTitle, prompt: Text("Title:")
                            .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                        .floatingPromptScale(1.0)
                        
                        FloatingPromptTextField(text: $task.taskDescription, prompt: Text("Description:")
                            .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                        .floatingPromptScale(1.0)
                        
                        FloatingPromptTextField(text: $task.comment, prompt: Text("Comment:")
                            .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                        .floatingPromptScale(1.0)
                    }
                    
                    Group
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text("Location:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                            
                            Picker(Constants.EMPTY_STRING, selection: $task.location)
                            {
                                ForEach(LocationEnum.allCases)
                                {
                                    location in
                                    
                                    Text(location.title).tag(location.title)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text("Category:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                            
                            Picker(Constants.EMPTY_STRING, selection: $task.category)
                            {
                                ForEach(CategoryEnum.allCases)
                                {
                                    category in
                                    
                                    Text(category.title).tag(category.title)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text("Priority:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                            
                            Picker(Constants.EMPTY_STRING, selection: $task.priority)
                            {
                                ForEach(PriorityEnum.allCases)
                                {
                                    priority in
                                    
                                    if priority.title != "All"
                                    {
                                        Text(priority.title).tag(priority.title)
                                    }
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text("Date Created:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                            Text("\(task.createdDate)")
                        }
                    }
                }
                
                // Before & After Images Section
                // Displays existing photos and provides PhotosPicker controls for adding new ones
                Section("Before & After Images")
                {
                    HStack
                    {
                        VStack
                        {
                            if let selectedBeforePhotoData = task.beforeImage, let uiImage = UIImage(data: selectedBeforePhotoData)
                            {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 150, maxHeight: 150)
                                    .cornerRadius(15)
                                    .overlay(alignment: .bottomTrailing)
                                {
                                    Text("BEFORE").font(.caption).backgroundStyle(.black).foregroundStyle(.white).bold().padding(.horizontal)
                                }
                            }
                            
//                            if task.beforeImage == nil
//                            {
                                PhotosPicker(selection: $selectedBeforePhoto, matching: .images, photoLibrary: .shared())
                                {
                                    Label("Add Before Image", systemImage: "photo").font(.caption)
                                }
//                            }
                            
//                            if task.beforeImage != nil
//                            {
//                                Button(role: .destructive)
//                                {
//                                    withAnimation
//                                    {
//                                        selectedBeforePhoto = nil
//                                        //task.beforeImage = nil
//                                    }
//                                }
//                                label:
//                                {
//                                    Label("Remove Image", systemImage: "xmark").font(.caption).foregroundStyle(.red)
//                                }.padding()
//                            }
                        }
                        
                        Spacer()
                        
                        VStack
                        {
                            if let selectedAfterPhotoData = task.afterImage, let uiImage2 = UIImage(data: selectedAfterPhotoData)
                            {
                                Image(uiImage: uiImage2)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 150, maxHeight: 150)
                                    .cornerRadius(15)
                                    .overlay(alignment: .bottomTrailing)
                                {
                                    Text("AFTER").font(.caption).backgroundStyle(.black).foregroundStyle(.white).bold().padding(.horizontal)
                                }
                            }
                            
//                            if task.afterImage == nil
//                            {
                                PhotosPicker(selection: $selectedAfterPhoto, matching: .images, photoLibrary: .shared())
                                {
                                    Label("Add After Image", systemImage: "photo").font(.caption)
                                }
//                            }
                            
//                            if task.afterImage != nil
//                            {
//                                Button(role: .destructive)
//                                {
//                                    withAnimation
//                                    {
//                                        selectedAfterPhoto = nil
//                                        //task.afterImage = nil
//                                    }
//                                }
//                                label:
//                                {
//                                    Label("Remove Image", systemImage: "xmark").font(.caption).foregroundStyle(.red)
//                                }.padding()
//                            }
                        }
                    }
                }
                
                // Task Items Section (conditional)
                // Only displayed when the task has associated task items
                // Provides navigation link to view the task item list
                if task.taskItemsArray.count > 0
                {
                    Section("Task Items")
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            NavigationLink(value: task.taskItems)
                            {
                                Button
                                {
                                    path.append(task.taskItems)
                                }
                                label:
                                {
                                    Text("Task Item List")
                                }
                            }
                        }
                    }
                }
                
                // Status Information Section
                // Displays completion status with toggle button
                // Shows completion date when task is marked complete
                Section("Status Information")
                {
                    VStack(alignment: .leading, spacing: 5)
                    {
                        Text("Status:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                        
                        HStack
                        {
                            Text("\(task.wrappedIsCompleted)")
                            
                            Spacer()
                            
                            Button(action:
                            {
                                toggleIsComplete()
                                
                                if task.isCompleted
                                {
                                    task.completedDate = Date.now.formatted(date: .abbreviated, time: .shortened)
                                }
                                else
                                {
                                    task.completedDate = Constants.EMPTY_STRING
                                }
                            },
                            label:
                            {
                                Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                                    .foregroundStyle(colorScheme == .dark ? .gray : .blue)
                            })
                        }
                    }
                    
                    if task.isCompleted
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text("Date Completed:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                            Text("\(task.completedDate)")
                        }
                    }
                }
            }
            .toolbar
            {
                // Leading toolbar button
                // Displays "Save" for valid tasks or back navigation for incomplete tasks
                ToolbarItem(placement: .topBarLeading)
                {
                    Button(validateFields() ? "Save" : "<  Task Item List")
                    {
                        path = NavigationPath()
                    }
                    .padding(.horizontal)
                }
                
                // Trailing toolbar button
                // Creates and navigates to a new task item associated with this task
                ToolbarItem
                {
                    Button(action:
                    {
                        let taskItem = TaskItem(itemTitle: Constants.EMPTY_STRING,
                                                itemDescription: Constants.EMPTY_STRING,
                                                comment: Constants.EMPTY_STRING)
                        
                        taskItem.task = task
                        
                        modelContext.insert(taskItem)
                        
                        path.append(taskItem)
                    },
                    label:
                    {
                        HStack
                        {
                            Text("Add Task Item").font(.callout)
                            Image(systemName: "plus")
                        }
                    })
                }
            }
            .navigationTitle(validateFields() ? "Edit Task" : "Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onDisappear(perform: validateTask)
            
            // Navigation destinations
            // Handles navigation to both task item list and individual task item edit views
            .navigationDestination(for: [TaskItem].self)
            {
                taskItems in
                
                TaskItemListView(taskItems: taskItems, path: $path)
            }
            .navigationDestination(for: TaskItem.self)
            {
                taskItem in
                
                EditTaskItemView(taskItem: taskItem, path: $path)
            }
            
            // Photo loading tasks
            // Async tasks that load selected photos from PhotosPicker and store them as Data
            .task(id: selectedBeforePhoto) 
            {
                if let data = try? await selectedBeforePhoto?.loadTransferable(type: Data.self)
                {
                    task.beforeImage = data
                }
            }
            .task(id: selectedAfterPhoto) 
            {
                if let data = try? await selectedAfterPhoto?.loadTransferable(type: Data.self) 
                {
                    task.afterImage = data
                }
            }
        }
    }

    // MARK: - Validation Methods
    
    /// Validates the task and deletes it if required fields are empty.
    ///
    /// This method is called when the view disappears (via `.onDisappear` modifier).
    /// If any of the three required fields (title, description, or comment) are empty,
    /// the task is deleted from the model context with animation.
    ///
    /// This ensures that only complete tasks are persisted in the database, preventing
    /// orphaned or incomplete records.
    ///
    /// - Note: Deletion occurs within a `withAnimation` block for smooth UI transitions.
    func validateTask()
    {
        if task.taskTitle == Constants.EMPTY_STRING || 
             task.taskDescription == Constants.EMPTY_STRING ||
             task.comment == Constants.EMPTY_STRING
        {
            withAnimation
            {
                modelContext.delete(task)
            }
        }
    }

    /// Determines whether all required task fields contain values.
    ///
    /// Used to conditionally update UI elements such as:
    /// - Navigation title ("Edit Task" vs "Add Task")
    /// - Leading toolbar button label ("Save" vs back navigation)
    ///
    /// - Returns: `true` if title, description, and comment are all non-empty; `false` otherwise.
    func validateFields() -> Bool
    {
        if task.taskTitle == Constants.EMPTY_STRING || 
             task.taskDescription == Constants.EMPTY_STRING ||
             task.comment == Constants.EMPTY_STRING
        {
            return false
        }

        return true
    }
}

// MARK: - Preview

/// Preview provider for `EditTaskView`.
///
/// Creates an in-memory SwiftData model container with sample data for preview purposes.
/// The preview demonstrates the view with a pre-populated task from the sample data set.
///
/// - Note: If container creation fails, displays an error message instead of the view.
#Preview
{
    @State var path = NavigationPath()
    
    do
    {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: Task.self, TaskItem.self, configurations: config)

        return EditTaskView(task: Task.sampleData()[0], path: $path).modelContainer(container)
    }
    catch
    {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}


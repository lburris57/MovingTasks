//
//  EditTaskView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//

import FloatingPromptTextField
import PhotosUI
import SwiftData
import SwiftUI

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
    @State private var selectedBeforePhoto: PhotosPickerItem?

    /// The currently selected "after" photo from the photo library.
    ///
    /// When changed, triggers async loading of the photo data which is then stored
    /// in the task's `afterImage` property.
    @State private var selectedAfterPhoto: PhotosPickerItem?

    /// Local cache of the before image data to prevent loss during SwiftData refaulting.
    @State private var beforeImageData: Data?

    /// Local cache of the after image data to prevent loss during SwiftData refaulting.
    @State private var afterImageData: Data?
    
    /// Flag to track if we've initialized the image caches from the task.
    @State private var hasInitializedImageCaches = false
    
    /// Track if we're currently loading a before image to prevent duplicate loads
    @State private var isLoadingBeforeImage = false
    
    /// Track if we're currently loading an after image to prevent duplicate loads
    @State private var isLoadingAfterImage = false

    /// The navigation path used for programmatic navigation.
    ///
    /// Binding to the navigation stack's path enables:
    /// - Popping back to root (task list)
    /// - Pushing to task item list view
    /// - Pushing to task item edit view
    @Binding var path: NavigationPath

    // New properties for draft editing and creation mode
    let isNew: Bool
    @State private var draftTitle: String = ""
    @State private var draftDescription: String = ""
    @State private var draftComment: String = ""
    @State private var draftLocation: String = LocationEnum.allCases.first?.title ?? ""
    @State private var draftCategory: String = CategoryEnum.allCases.first?.title ?? ""
    @State private var draftPriority: String = PriorityEnum.allCases.first?.title ?? ""
    
    // Explicit initializer to support isNew and initialize drafts
    init(task: Task, path: Binding<NavigationPath>, isNew: Bool = false) {
        self._task = Bindable(wrappedValue: task)
        self._path = path
        self.isNew = isNew
        // Initialize drafts from existing task when editing
        _draftTitle = State(initialValue: task.taskTitle)
        _draftDescription = State(initialValue: task.taskDescription)
        _draftComment = State(initialValue: task.comment)
        _draftLocation = State(initialValue: task.location)
        _draftCategory = State(initialValue: task.category)
        _draftPriority = State(initialValue: task.priority)
    }

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
            backgroundGradient

            formContent
                .navigationTitle(isNew ? "Create Task" : (validateFields() ? "Edit Task" : "Add Task"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.regularMaterial, for: .navigationBar)
                .onAppear(perform: handleViewAppear)
                .onDisappear(perform: handleViewDisappear)
                .modifier(NavigationModifier(path: $path))
                .modifier(PhotoLoadingModifier(
                    selectedBeforePhoto: $selectedBeforePhoto,
                    selectedAfterPhoto: $selectedAfterPhoto,
                    loadBeforeImage: loadBeforeImage,
                    loadAfterImage: loadAfterImage
                ))
                .onChange(of: beforeImageData)
                { oldValue, newValue in
                    handleBeforeImageDataChange(oldValue: oldValue, newValue: newValue)
                }
                .onChange(of: afterImageData)
                { oldValue, newValue in
                    handleAfterImageDataChange(oldValue: oldValue, newValue: newValue)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            // In creation mode, just go back without inserting a task
                            // In edit mode, simply navigate back
                            path = NavigationPath()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button(isNew ? "Create" : "Save") {
                            if isNew {
                                let newTask = Task(taskTitle: draftTitle, taskDescription: draftDescription, comment: draftComment)
                                newTask.location = draftLocation
                                newTask.category = draftCategory
                                newTask.priority = draftPriority
                                newTask.beforeImage = beforeImageData
                                newTask.afterImage = afterImageData
                                modelContext.insert(newTask)
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("❌ Error creating task: \(error)")
                                }
                                path = NavigationPath()
                            } else {
                                applyImagesFromCacheToTask()
                                path = NavigationPath()
                            }
                        }
                        .disabled(isNew ? !validateDraftFields() : !validateFields())
                    }
                }
        }
    }

    // MARK: - View Components

    private var backgroundGradient: some View
    {
        ZStack
        {
            // Main gradient background
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.25),
                    Color.blue.opacity(0.20),
                    Color.purple.opacity(0.22),
                    Color.pink.opacity(0.18),
                    Color.orange.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative orbs
            decorativeOrbsView
        }
    }
    
    private var decorativeOrbsView: some View
    {
        GeometryReader { geometry in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.green.opacity(0.4), Color.mint.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .position(x: geometry.size.width * 0.2, y: 100)
                .blur(radius: 50)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.45), Color.indigo.opacity(0.25), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .position(x: geometry.size.width * 0.8, y: 250)
                .blur(radius: 45)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.35), Color.yellow.opacity(0.20), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .position(x: geometry.size.width * 0.3, y: 500)
                .blur(radius: 40)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.pink.opacity(0.38), Color.red.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .position(x: geometry.size.width * 0.7, y: 700)
                .blur(radius: 35)
        }
        .allowsHitTesting(false)
    }

    private var formContent: some View
    {
        Form
        {
            taskInformationSection
            taskItemsSection
            beforeAfterImagesSection
            statusInformationSection
        }
        .scrollContentBackground(.hidden)
    }

    private var taskInformationSection: some View
    {
        Section
        {
            VStack(spacing: 16)
            {
                // Section header
                HStack
                {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Task Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.bottom, 8)
                
                textFieldsGroup
                pickersGroup
            }
            .padding()
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowSeparator(.hidden)
    }

    private var textFieldsGroup: some View
    {
        Group
        {
            FloatingPromptTextField(
                text: isNew ? $draftTitle : $task.taskTitle,
                prompt: Text("Title:")
                    .foregroundStyle(colorScheme == .dark ? .gray : .blue)
            )
            .floatingPromptScale(1.0)

            FloatingPromptTextField(
                text: isNew ? $draftDescription : $task.taskDescription,
                prompt: Text("Description:")
                    .foregroundStyle(colorScheme == .dark ? .gray : .blue)
            )
            .floatingPromptScale(1.0)

            FloatingPromptTextField(
                text: isNew ? $draftComment : $task.comment,
                prompt: Text("Comment:")
                    .foregroundStyle(colorScheme == .dark ? .gray : .blue)
            )
            .floatingPromptScale(1.0)
        }
    }

    private var pickersGroup: some View
    {
        Group
        {
            locationPicker
            categoryPicker
            priorityPicker
            dateCreatedView
                .padding(.top, 8)
        }
    }

    private var locationPicker: some View
    {
        HStack
        {
            Text("Location:")
                .font(.body)
                .foregroundStyle(colorScheme == .dark ? .gray : .blue)

            Spacer()

            Picker(Constants.EMPTY_STRING, selection: isNew ? $draftLocation : $task.location)
            {
                ForEach(LocationEnum.allCases)
                { location in
                    Text(location.title).tag(location.title)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }

    private var categoryPicker: some View
    {
        HStack
        {
            Text("Category:")
                .font(.body)
                .foregroundStyle(colorScheme == .dark ? .gray : .blue)

            Spacer()

            Picker(Constants.EMPTY_STRING, selection: isNew ? $draftCategory : $task.category)
            {
                ForEach(CategoryEnum.allCases)
                { category in
                    Text(category.title).tag(category.title)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }

    private var priorityPicker: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            HStack
            {
                Text("Priority:")
                    .font(.body)
                    .foregroundStyle(colorScheme == .dark ? .gray : .blue)
                
                Spacer()
            }

            Picker(Constants.EMPTY_STRING, selection: isNew ? $draftPriority : $task.priority)
            {
                ForEach(PriorityEnum.allCases)
                { priority in
                    if priority.title != "All"
                    {
                        Text(priority.title).tag(priority.title)
                    }
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    private var dateCreatedView: some View
    {
        HStack
        {
            Text("Date Created:")
                .font(.body)
                .foregroundStyle(colorScheme == .dark ? .gray : .blue)
            
            Spacer()
            
            Text(isNew ? "" : "\(task.createdDate)")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var beforeAfterImagesSection: some View
    {
        Section
        {
            VStack(spacing: 20)
            {
                // Section header
                HStack
                {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Before & After Images")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.bottom, 8)
                
                HStack
                {
                    Text("Before Image")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                beforeImageColumn

                Divider()
                    .padding(.vertical, 8)

                HStack
                {
                    Text("After Image")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                afterImageColumn
            }
            .padding()
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowSeparator(.hidden)
    }

    private var beforeImageColumn: some View
    {
        VStack
        {
            if let imageData = beforeImageData,
               let uiImage = UIImage(data: imageData)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 200)
                    .cornerRadius(15)
                    .overlay(alignment: .bottom)
                    {
                        Text("BEFORE")
                            .font(.caption)
                            .backgroundStyle(.black)
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }

                PhotosPicker(
                    selection: $selectedBeforePhoto,
                    matching: .images,
                    photoLibrary: .shared()
                )
                {
                    Label("Modify Before Image", systemImage: "photo")
                        .font(.caption)
                }

                Button(role: .destructive)
                {
                    print("🗑️ User explicitly removing before image")
                    selectedBeforePhoto = nil
                    beforeImageData = nil
                }
                label:
                {
                    Label("Remove Image", systemImage: "xmark")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .padding(.top, 4)
            }
            else
            {
                PhotosPicker(
                    selection: $selectedBeforePhoto,
                    matching: .images,
                    photoLibrary: .shared()
                )
                {
                    Label("Add Before Image", systemImage: "photo")
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var afterImageColumn: some View
    {
        VStack
        {
            if let imageData = afterImageData,
               let uiImage = UIImage(data: imageData)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 200)
                    .cornerRadius(15)
                    .overlay(alignment: .bottom)
                    {
                        Text("AFTER")
                            .font(.caption)
                            .backgroundStyle(.black)
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }

                PhotosPicker(
                    selection: $selectedAfterPhoto,
                    matching: .images,
                    photoLibrary: .shared()
                )
                {
                    Label("Modify After Image", systemImage: "photo")
                        .font(.caption)
                }

                Button(role: .destructive)
                {
                    print("🗑️ User explicitly removing after image")
                    selectedAfterPhoto = nil
                    afterImageData = nil
                }
                label:
                {
                    Label("Remove Image", systemImage: "xmark")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .padding(.top, 4)
            }
            else
            {
                PhotosPicker(
                    selection: $selectedAfterPhoto,
                    matching: .images,
                    photoLibrary: .shared()
                )
                {
                    Label("Add After Image", systemImage: "photo")
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var taskItemsSection: some View
    {
        // Don't show task items section when creating a new task
        if !isNew
        {
            Section
            {
                VStack(spacing: 16)
                {
                    // Section header with count and add button
                    HStack
                    {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Task Items")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ZStack
                        {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 24, height: 24)
                            
                            Text("\(task.taskItemsArray.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            let newTaskItem = TaskItem(
                                itemTitle: Constants.EMPTY_STRING,
                                itemDescription: Constants.EMPTY_STRING,
                                comment: Constants.EMPTY_STRING
                            )
                            newTaskItem.task = task
                            task.taskItems?.append(newTaskItem)
                            path.append(newTaskItem)
                        }) {
                            Label("Add Task Item", systemImage: "plus.circle.fill")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .font(.title3)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Show task items if there are any
                    if task.taskItemsArray.count > 0
                    {
                        Divider()
                            .padding(.vertical, 4)
                        
                        ForEach(task.taskItemsArray)
                        { taskItem in
                            NavigationLink(value: taskItem)
                            {
                                taskItemRow(for: taskItem)
                            }
                        }
                    }
                }
                .padding()
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.green.opacity(0.3), .mint.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
        }
    }

    private func taskItemRow(for taskItem: TaskItem) -> some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            Text(taskItem.itemTitle)
                .font(.body)
                .foregroundStyle(.primary)
                .bold()

            Text(taskItem.itemDescription)
                .font(.callout)
                .foregroundStyle(.secondary)

            if taskItem.wasPurchased
            {
                HStack
                {
                    Text("Purchased")
                        .font(.caption)
                        .foregroundStyle(.green)

                    Spacer()

                    Text(taskItem.formattedTotalPriceString)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .bold()
                }
            }
            else
            {
                Text("Not Purchased")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var statusInformationSection: some View
    {
        Section
        {
            VStack(spacing: 16)
            {
                // Section header
                HStack
                {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Status Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.bottom, 8)
                
                statusToggleView

                if task.isCompleted
                {
                    completedDateView
                }
            }
            .padding()
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowSeparator(.hidden)
    }

    private var statusToggleView: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            Text("Status:")
                .font(.body)
                .foregroundStyle(colorScheme == .dark ? .gray : .blue)

            HStack
            {
                Text("\(task.wrappedIsCompleted)")

                Spacer()

                Button(action: handleStatusToggle)
                {
                    Image(systemName: task.isCompleted ? "checkmark.square" : "square")
                        .foregroundStyle(colorScheme == .dark ? .gray : .blue)
                }
            }
        }
    }

    private var completedDateView: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            Text("Date Completed:")
                .font(.body)
                .foregroundStyle(colorScheme == .dark ? .gray : .blue)
            Text("\(task.completedDate)")
        }
    }

    // MARK: - Helper Methods

    private func handleViewAppear()
    {
        print("🔵 EditTaskView appeared")
        print("   Task has before image: \(task.beforeImage != nil) (\(task.beforeImage?.count ?? 0) bytes)")
        print("   Task has after image: \(task.afterImage != nil) (\(task.afterImage?.count ?? 0) bytes)")
        print("   Cache has before image: \(beforeImageData != nil) (\(beforeImageData?.count ?? 0) bytes)")
        print("   Cache has after image: \(afterImageData != nil) (\(afterImageData?.count ?? 0) bytes)")
        print("   Has initialized caches: \(hasInitializedImageCaches)")

        // If we're creating a new task, do not initialize caches from task
        if isNew {
            hasInitializedImageCaches = true
            return
        }

        // Only initialize cache ONCE when the view first appears
        // After that, the cache is the source of truth and should never be overwritten
        guard !hasInitializedImageCaches else {
            print("   ⏭️ Skipping cache initialization - already initialized")
            return
        }
        
        print("   🎬 Performing one-time cache initialization...")
        hasInitializedImageCaches = true
        
        // Initialize cache from task data if available
        // This should only happen ONCE per view lifecycle
        if let beforeImage = task.beforeImage {
            print("   ✅ Initializing before image cache from task (\(beforeImage.count) bytes)")
            beforeImageData = beforeImage
        }
        if let afterImage = task.afterImage {
            print("   ✅ Initializing after image cache from task (\(afterImage.count) bytes)")
            afterImageData = afterImage
        }
        
        print("   Cache initialization complete:")
        print("     - Before: \(beforeImageData?.count ?? 0) bytes")
        print("     - After: \(afterImageData?.count ?? 0) bytes")
    }

    private func handleViewDisappear()
    {
        print("🔴 EditTaskView disappeared")
        if !isNew { validateTask() }
    }

    private func handleBeforeImageDataChange(oldValue: Data?, newValue: Data?)
    {
        let oldSize = oldValue?.count ?? 0
        let newSize = newValue?.count ?? 0
        
        print("💾 beforeImageData changed from \(oldSize) bytes to \(newSize) bytes")
        
        // CRITICAL: If data is being unexpectedly cleared, restore it!
        if oldSize > 0 && newSize == 0 && !hasInitializedImageCaches {
            print("⚠️ WARNING: Before image data was cleared unexpectedly! This shouldn't happen.")
            print("   Stack trace would show what caused this...")
        }
    }

    private func handleAfterImageDataChange(oldValue: Data?, newValue: Data?)
    {
        print("💾 afterImageData changed from \(oldValue?.count ?? 0) bytes to \(newValue?.count ?? 0) bytes")
    }

    private func addNewTaskItem()
    {
        let taskItem = TaskItem(
            itemTitle: Constants.EMPTY_STRING,
            itemDescription: Constants.EMPTY_STRING,
            comment: Constants.EMPTY_STRING
        )

        taskItem.task = task
        modelContext.insert(taskItem)
        path.append(taskItem)
    }

    private func handleStatusToggle()
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
    }

    private func loadBeforeImage(from item: PhotosPickerItem?) async
    {
        guard let item
        else
        {
            print("🔴 loadBeforeImage called with nil item - this shouldn't happen!")
            return
        }
        
        // Prevent loading the same photo twice using a flag
        guard !isLoadingBeforeImage else
        {
            print("⏭️ Skipping duplicate before image load - already loading")
            return
        }

        print("📷 Loading before image...")
        isLoadingBeforeImage = true
        defer { isLoadingBeforeImage = false }

        do
        {
            if let data = try await item.loadTransferable(type: Data.self)
            {
                print("✅ Before image loaded: \(data.count) bytes")

                await MainActor.run
                {
                    // Update cache - this will be saved when the user leaves the view
                    // or manually saves via the toolbar button
                    beforeImageData = data
                    
                    // CRITICAL: Clear the picker selection to prevent it from triggering again
                    selectedBeforePhoto = nil
                }
            }
        }
        catch
        {
            print("❌ Error loading before image: \(error)")
            await MainActor.run
            {
                selectedBeforePhoto = nil
            }
        }
    }

    private func loadAfterImage(from item: PhotosPickerItem?) async
    {
        guard let item
        else
        {
            print("🔴 loadAfterImage called with nil item - this shouldn't happen!")
            return
        }
        
        // Prevent loading the same photo twice using a flag
        guard !isLoadingAfterImage else
        {
            print("⏭️ Skipping duplicate after image load - already loading")
            return
        }

        print("📷 Loading after image...")
        isLoadingAfterImage = true
        defer { isLoadingAfterImage = false }

        do
        {
            if let data = try await item.loadTransferable(type: Data.self)
            {
                print("✅ After image loaded: \(data.count) bytes")

                await MainActor.run
                {
                    // Update cache - this will be saved when the user leaves the view
                    // or manually saves via the toolbar button
                    afterImageData = data
                }
            }
        }
        catch
        {
            print("❌ Error loading after image: \(error)")
        }
    }

    /// Applies both cached images to the task object and saves the context.
    ///
    /// This ensures that both images are always set together, preventing SwiftData
    /// from clearing one while saving the other (which can happen with external storage).
    private func applyImagesFromCacheToTask(writeBefore: Bool = true, writeAfter: Bool = true)
    {
        print("📸 Applying images from cache:")
        print("   Before image size: \(beforeImageData?.count ?? 0) bytes")
        print("   After image size: \(afterImageData?.count ?? 0) bytes")

        // Set both images from cache
        if writeBefore { task.beforeImage = beforeImageData }
        if writeAfter { task.afterImage = afterImageData }

        do
        {
            try modelContext.save()
            print("✅ Images saved successfully")

            // Verify the task still has both images after save
            print("📋 After save verification:")
            print("   Task before image: \(task.beforeImage?.count ?? 0) bytes")
            print("   Task after image: \(task.afterImage?.count ?? 0) bytes")

            // DO NOT update cache from task - cache is the source of truth!
            // The task object may be refaulted by SwiftData at any time,
            // but our @State cache persists across refaults.
        }
        catch
        {
            print("❌ Error saving images: \(error)")
        }
    }

    // MARK: - Validation Methods

    /// Validates the task and deletes it if required fields are empty.
    ///
    /// This method is called when the view disappears (via `.onDisappear` modifier).
    /// If any of the three required fields (title, description, or comment) are empty,
    /// the task is deleted from the model context.
    ///
    /// This ensures that only complete tasks are persisted in the database, preventing
    /// orphaned or incomplete records when the user navigates away without explicitly
    /// canceling (e.g., using a swipe gesture).
    ///
    /// - Note: The main deletion logic is handled in the Cancel button to prevent flashing.
    ///   This method serves as a safety net for other navigation methods.
    func validateTask()
    {
        if task.taskTitle == Constants.EMPTY_STRING ||
            task.taskDescription == Constants.EMPTY_STRING ||
            task.comment == Constants.EMPTY_STRING
        {
            modelContext.delete(task)
            try? modelContext.save()
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
    
    /// Determines whether all required draft fields contain values.
    ///
    /// Used for creation mode validation.
    ///
    /// - Returns: `true` if draft title, description, and comment are all non-empty; `false` otherwise.
    func validateDraftFields() -> Bool
    {
        if draftTitle == Constants.EMPTY_STRING ||
            draftDescription == Constants.EMPTY_STRING ||
            draftComment == Constants.EMPTY_STRING
        {
            return false
        }
        return true
    }
}

// MARK: - View Modifiers

/// A view modifier that handles navigation destinations for task items.
private struct NavigationModifier: ViewModifier
{
    @Binding var path: NavigationPath
    
    func body(content: Content) -> some View
    {
        content
            .navigationDestination(for: [TaskItem].self)
            { taskItems in
                TaskItemListView(taskItems: taskItems, path: $path)
            }
            .navigationDestination(for: TaskItem.self)
            { taskItem in
                EditTaskItemView(taskItem: taskItem, path: $path)
            }
    }
}

/// A view modifier that handles photo picker changes and triggers image loading.
private struct PhotoLoadingModifier: ViewModifier
{
    @Binding var selectedBeforePhoto: PhotosPickerItem?
    @Binding var selectedAfterPhoto: PhotosPickerItem?
    let loadBeforeImage: (PhotosPickerItem?) async -> Void
    let loadAfterImage: (PhotosPickerItem?) async -> Void
    
    func body(content: Content) -> some View
    {
        content
            .onChange(of: selectedBeforePhoto) { oldValue, newValue in
                handleBeforePhotoChange(oldValue: oldValue, newValue: newValue)
            }
            .onChange(of: selectedAfterPhoto) { oldValue, newValue in
                handleAfterPhotoChange(oldValue: oldValue, newValue: newValue)
            }
    }
    
    private func handleBeforePhotoChange(oldValue: PhotosPickerItem?, newValue: PhotosPickerItem?) {
        // Only load if the value actually changed and is not nil
        guard newValue != nil, newValue?.itemIdentifier != oldValue?.itemIdentifier else { 
            return 
        }
        
        _Concurrency.Task {
            await self.loadBeforeImage(newValue)
        }
    }
    
    private func handleAfterPhotoChange(oldValue: PhotosPickerItem?, newValue: PhotosPickerItem?) {
        // Only load if the value actually changed and is not nil
        guard newValue != nil, newValue?.itemIdentifier != oldValue?.itemIdentifier else { 
            return 
        }
        
        _Concurrency.Task {
            await self.loadAfterImage(newValue)
        }
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
    @Previewable @State var path = NavigationPath()

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, TaskItem.self, configurations: config)

    EditTaskView(task: Task.sampleData()[0], path: $path)
        .modelContainer(container)
}


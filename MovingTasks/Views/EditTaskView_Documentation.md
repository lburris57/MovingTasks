# EditTaskView Documentation

## Overview

`EditTaskView` is a comprehensive SwiftUI view for creating and editing tasks in the MovingTasks application. It provides a full-featured form interface with validation, photo management, and navigation capabilities.

## Features

### Core Functionality
- **Task Creation & Editing**: Supports both creating new tasks and editing existing ones
- **Form-Based Interface**: Organized into logical sections for easy data entry
- **Automatic Validation**: Validates required fields and removes incomplete tasks
- **Photo Management**: Supports before and after photos with PhotosPicker integration
- **Task Item Navigation**: Seamlessly navigate to associated task items
- **Status Tracking**: Toggle completion status with automatic date stamping

### User Interface Sections

#### 1. Task Information
- **Title**: Primary identifier for the task (required)
- **Description**: Detailed description of the task (required)
- **Comment**: Additional notes or comments (required)
- **Location**: Dropdown picker for task location
- **Category**: Dropdown picker for task categorization
- **Priority**: Segmented control for priority selection (excludes "All" option)
- **Date Created**: Read-only display of task creation timestamp

#### 2. Before & After Images
- Side-by-side photo display with labeled overlays
- PhotosPicker integration for selecting images from photo library
- Images displayed at 150x150 max dimensions with rounded corners
- Labeled with "BEFORE" and "AFTER" text overlays

#### 3. Task Items (Conditional)
- Only displayed when task has associated task items
- Navigation link to view complete list of task items
- Button to navigate to task item list view

#### 4. Status Information
- Current completion status display
- Toggle button to mark task complete/incomplete
- Completion date display (when task is marked complete)
- Automatic timestamp when task is marked complete

## Technical Details

### Properties

#### Bindable Properties
```swift
@Bindable var task: Task
```
The task being edited, with two-way binding to enable real-time updates.

#### Binding Properties
```swift
@Binding var path: NavigationPath
```
Navigation path for programmatic navigation throughout the app.

#### Environment Properties
```swift
@Environment(\.modelContext) var modelContext
@Environment(\.colorScheme) var colorScheme
```
- `modelContext`: SwiftData context for database operations
- `colorScheme`: Current appearance mode for adaptive styling

#### State Properties
```swift
@State var selectedBeforePhoto: PhotosPickerItem?
@State var selectedAfterPhoto: PhotosPickerItem?
```
Track currently selected photos from the photo picker.

### Methods

#### `toggleIsComplete()`
Toggles the task's completion status.

**Behavior**:
- Flips the `isCompleted` boolean on the task
- Caller is responsible for updating `completedDate`

**Usage**:
```swift
toggleIsComplete()
if task.isCompleted {
    task.completedDate = Date.now.formatted(date: .abbreviated, time: .shortened)
} else {
    task.completedDate = Constants.EMPTY_STRING
}
```

#### `validateTask()`
Validates task and deletes if incomplete.

**Validation Rules**:
- Task title must not be empty
- Task description must not be empty
- Task comment must not be empty

**Behavior**:
- Called automatically via `.onDisappear` modifier
- Deletes task from model context if validation fails
- Deletion occurs with animation for smooth UX

**Purpose**: Prevents incomplete or orphaned task records in the database.

#### `validateFields() -> Bool`
Checks if all required fields contain values.

**Returns**: 
- `true` if all required fields are populated
- `false` if any required field is empty

**Used For**:
- Determining navigation title ("Edit Task" vs "Add Task")
- Setting toolbar button label ("Save" vs back navigation)

### Async Operations

#### Photo Loading
The view uses SwiftUI's `.task(id:)` modifier to asynchronously load photos:

```swift
.task(id: selectedBeforePhoto) {
    if let data = try? await selectedBeforePhoto?.loadTransferable(type: Data.self) {
        task.beforeImage = data
    }
}
```

**Behavior**:
- Triggered when photo selection changes
- Loads photo data asynchronously
- Converts photo to `Data` for SwiftData storage
- Updates task property directly

### Navigation Flow

```
EditTaskView
    ├── Back to Task List (via path reset)
    ├── Navigate to TaskItemListView (for [TaskItem])
    └── Navigate to EditTaskItemView (for TaskItem)
```

**Navigation Patterns**:

1. **Return to Task List**:
   ```swift
   path = NavigationPath() // Resets to root
   ```

2. **Navigate to Task Items**:
   ```swift
   path.append(task.taskItems) // Push to list
   ```

3. **Add New Task Item**:
   ```swift
   let taskItem = TaskItem(...)
   taskItem.task = task
   modelContext.insert(taskItem)
   path.append(taskItem) // Push to edit view
   ```

## User Experience

### Visual Design
- **Background**: Blue to indigo linear gradient with 25% opacity
- **Color Scheme Aware**: Labels adapt between light (blue) and dark (gray) modes
- **Form Style**: Native iOS form with sections and grouped appearance
- **Rounded Corners**: Images use 15pt corner radius

### Toolbar Configuration
- **Leading Button**: Context-aware (Save/Back)
- **Trailing Button**: Add Task Item with plus icon
- **Title Display**: Inline navigation bar title
- **Back Button**: Hidden (custom navigation via leading button)

### Validation Feedback
- Title updates based on validation state
- Button labels change based on field completion
- Automatic cleanup of incomplete tasks

## Data Flow

### Task Creation Flow
1. User creates new task with empty fields
2. User fills in required information
3. User adds optional photos
4. User creates task items (optional)
5. User navigates away
6. If valid: Task is saved
7. If invalid: Task is deleted

### Task Editing Flow
1. User selects existing task
2. Fields are pre-populated
3. User modifies information
4. Changes are automatically saved (via @Bindable)
5. User navigates away
6. Task persists in database

### Photo Selection Flow
1. User taps PhotosPicker
2. System photo picker appears
3. User selects photo
4. `.task(id:)` modifier triggers
5. Photo is loaded asynchronously
6. Data is stored in task property
7. Image appears in UI

## Dependencies

### Frameworks
- **SwiftUI**: Core UI framework
- **SwiftData**: Data persistence
- **PhotosUI**: Photo selection interface
- **FloatingPromptTextField**: Third-party text field component

### Related Types
- `Task`: SwiftData model for tasks
- `TaskItem`: SwiftData model for task items
- `LocationEnum`: Enumeration of location options
- `CategoryEnum`: Enumeration of category options
- `PriorityEnum`: Enumeration of priority levels
- `Constants`: Application-wide constants

## Best Practices

### When Using This View

1. **Always Provide Navigation Path**: Pass a valid `NavigationPath` binding
2. **Model Context Required**: Ensure SwiftData model context is in environment
3. **Handle Validation**: Be aware that incomplete tasks are auto-deleted
4. **Photo Memory**: Large photos are stored as Data in database

### Performance Considerations

- Photos are loaded asynchronously to avoid blocking UI
- Validation only occurs on view disappearance
- Form updates are efficient via SwiftUI's binding system

### Accessibility

- All interactive elements are accessible
- Labels and hints provided via Label views
- Color scheme awareness ensures visibility

## Testing

### Preview Configuration
The preview uses an in-memory SwiftData container:

```swift
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(for: Task.self, TaskItem.self, configurations: config)
```

This allows testing without affecting persistent data.

### Test Scenarios

1. **Create Task**: Verify empty task is deleted if fields remain empty
2. **Edit Task**: Verify changes are saved automatically
3. **Add Photos**: Verify photos load and display correctly
4. **Toggle Completion**: Verify status and date update correctly
5. **Navigation**: Verify all navigation paths work correctly

## Common Issues & Solutions

### Issue: Task Disappears After Creation
**Cause**: Required fields (title, description, comment) are empty
**Solution**: Fill in all required fields before navigating away

### Issue: Photos Don't Load
**Cause**: Photo picker permissions not granted
**Solution**: Check photo library permissions in Settings

### Issue: Navigation Doesn't Work
**Cause**: NavigationPath not properly bound
**Solution**: Ensure path binding is passed from NavigationStack

## Future Enhancements

Potential improvements for this view:

1. **Photo Removal**: Add ability to remove photos after adding them
2. **Field Validation Feedback**: Show inline validation errors
3. **Photo Preview**: Full-screen photo viewing
4. **Drag & Drop**: Support drag and drop for photos
5. **Rich Text**: Support for formatted comments
6. **Duplicate Task**: Add ability to duplicate existing task
7. **Template Support**: Create tasks from templates

## Related Documentation

- `Task.swift` - Task data model documentation
- `TaskItem.swift` - Task item data model documentation
- `TaskItemListView.swift` - Task item list view documentation
- `EditTaskItemView.swift` - Task item editing documentation

---

**Last Updated**: December 4, 2025
**Version**: 1.0
**Platform**: iOS
**Framework**: SwiftUI

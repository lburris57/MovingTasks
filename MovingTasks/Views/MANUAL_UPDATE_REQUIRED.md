# TaskListView - Required Changes for Modern UI

## Problem
The automated edits to TaskListView keep failing to persist, leaving the file in an inconsistent state with old List-based code that references the new TaskRowView component that's now in a separate file.

## Current State
- ✅ TaskRowView.swift exists with modern card components
- ❌ TaskListView.swift still has old List-based body
- ❌ Compiler can't find TaskRowView (needs import or to be in same file)
- ❌ Complex expression timeout (old code too complex)

---

## Solution: Manual Update Required

Since automated edits keep failing, here's what needs to be manually changed in TaskListView.swift:

### 1. Add Import (if TaskRowView is separate file)
```swift
// At top of file, after existing imports
import SwiftData
import SwiftUI
```
*(TaskRowView is in same module, so no import needed)*

### 2. Add State Variable for Filter Sheet
Add this around line 90 with other @State properties:

```swift
/// Controls whether the filter sheet is presented.
@State private var showingFilterSheet = false
```

### 3. Replace the Entire `var body: some View` Section

**Find this (around line 440):**
```swift
var body: some View
{
    NavigationStack(path: $path)
    {
        ZStack
        {
            LinearGradient(...)
            ...old code with List...
        }
    }
}
```

**Replace with:**
```swift
var body: some View
{
    NavigationStack(path: $path)
    {
        Group
        {
            if tasks.count == 0
            {
                ContentUnavailableView
                {
                    Label("No Tasks Yet", systemImage: "checklist")
                }
                description:
                {
                    Text("Tap the plus button to create your first task, or use Sample Data to explore.")
                }
                actions:
                {
                    HStack(spacing: 12)
                    {
                        Button
                        {
                            createSampleData()
                        } label: {
                            Label("Sample Data", systemImage: "doc.on.doc.fill")
                        }
                        .buttonStyle(.bordered)
                        
                        Button
                        {
                            path.append(NewTaskRoute())
                        } label: {
                            Label("New Task", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            else if filteredTasks.count == 0
            {
                ContentUnavailableView
                {
                    Label("No Matching Tasks", systemImage: "line.3.horizontal.decrease.circle")
                }
                description:
                {
                    Text("Try adjusting your filter to see more results.")
                }
            }
            else
            {
                ScrollView
                {
                    VStack(spacing: 16)
                    {
                        // Grand Total Card
                        HStack
                        {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                            
                            VStack(alignment: .leading, spacing: 2)
                            {
                                Text("Grand Total")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(grandTotal)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                            
                            Spacer()
                            
                            Text("\(filteredTasks.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                            +
                            Text(" tasks")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        // Tasks List
                        LazyVStack(spacing: 12)
                        {
                            ForEach(filteredTasks)
                            {
                                task in
                                
                                TaskRowView(task: task, styleForPriority: styleForPriority)
                                    .contentShape(Rectangle())
                                    .onTapGesture
                                    {
                                        path.append(task)
                                    }
                                    .contextMenu
                                    {
                                        Button(role: .destructive)
                                        {
                                            withAnimation
                                            {
                                                modelContext.delete(task)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button
                                        {
                                            path.append(task)
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filteredTasks)
            }
        }
        .navigationDestination(for: Task.self)
        {
            task in
            
            EditTaskView(task: task, path: $path)
        }
        .navigationDestination(for: NewTaskRoute.self)
        {
            _ in
            let placeholder = Task(taskTitle: Constants.EMPTY_STRING, taskDescription: Constants.EMPTY_STRING, comment: Constants.EMPTY_STRING)
            EditTaskView(task: placeholder, path: $path, isNew: true)
        }
        .sheet(isPresented: $showingFilterSheet)
        {
            NavigationStack
            {
                FilterView(filterValue: $filterValue, selectedSearchType: $selectedSearchType)
                    .navigationTitle("Filter Tasks")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar
                    {
                        ToolbarItem(placement: .confirmationAction)
                        {
                            Button("Done")
                            {
                                showingFilterSheet = false
                            }
                        }
                        
                        ToolbarItem(placement: .cancellationAction)
                        {
                            Button("Clear")
                            {
                                selectedSearchType = .none
                                filterValue = "All"
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
            }
        }
        .toolbar
        {
            ToolbarItemGroup(placement: .topBarTrailing)
            {
                if tasks.count > 0
                {
                    Button
                    {
                        showingFilterSheet = true
                    } label: {
                        Label("Filter", systemImage: selectedSearchType == .none ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                
                Button
                {
                    path.append(NewTaskRoute())
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }

            if tasks.count > 0
            {
                ToolbarItem(placement: .topBarLeading)
                {
                    Menu
                    {
                        Button
                        {
                            createSampleData()
                        } label: {
                            Label("Add Sample Data", systemImage: "doc.on.doc.fill")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: populateGrandTotal)
    }
}
```

---

## Key Changes Summary

### What's Different:
1. **No more ZStack/Gradient** - Clean Group-based layout
2. **No more List** - Uses ScrollView + LazyVStack
3. **TaskRowView** - Modern card components (in TaskRowView.swift)
4. **Filter Sheet** - Toolbar button presents modal sheet
5. **Fixed Navigation** - `.inline` title display mode
6. **Context Menus** - Long-press for delete/edit
7. **Enhanced Empty States** - Action buttons built-in

### What Stays the Same:
- All the helper methods (styleForPriority, deleteTask, etc.)
- FilterView struct (keep as-is)
- All @State and @Query properties
- Navigation destinations
- Preview code

---

## Alternative: Move Components to TaskListView

If you prefer everything in one file, copy the TaskRowView and ChipView structs from TaskRowView.swift and paste them **after** the closing brace of `TaskListView` but **before** `FilterView`.

Like this structure:
```swift
struct TaskListView: View
{
    // ... all existing code ...
}

struct TaskRowView: View
{
    // ... from TaskRowView.swift ...
}

struct ChipView: View
{
    // ... from TaskRowView.swift ...
}

struct FilterView: View
{
    // ... existing FilterView ...
}

#Preview
{
    // ... existing preview ...
}
```

---

## Why This Keeps Failing

The `str_replace_based_edit_tool` has issues with:
- Large replacements (>100 lines)
- Multiple sequential edits
- Complex nested structures
- Detecting exact match boundaries

**Manual editing is more reliable** for these major structural changes.

---

## After Manual Update

Once you've made these changes manually:
1. Build the project
2. Check for any remaining compiler errors
3. Test the modern UI
4. Confirm filter sheet works
5. Verify navigation and context menus

---

*Created: February 21, 2026*

//  TaskListView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import SwiftData
import SwiftUI

private struct NewTaskRoute: Hashable {}

struct TaskListView: View
{
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.taskTitle) var tasks: [Task]
    @Query var taskItems: [TaskItem]
    
    @State private var grandTotal: String = Constants.ZERO_STRING
    @State private var filterValue: String = "All"
    @State private var selectedSearchType: FilterEnum = .none
    @State private var path = NavigationPath()
    @State private var sortOrder = [
        SortDescriptor(\Task.createdDate, order: .reverse),
        SortDescriptor(\Task.priority, order: .reverse)
    ]
    
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

    private func deleteTask(at indexSet: IndexSet)
    {
        indexSet.forEach
        {
            index in
            let task = tasks[index]
            modelContext.delete(task)
        }
    }
    
    private func populateGrandTotal()
    {
        var total: Decimal = 0.00
        
        for taskItem in taskItems
        {
            let totalPrice = Decimal(string: taskItem.totalPriceString.replacingOccurrences(of: Constants.DOLLAR_SIGN, with: Constants.EMPTY_STRING))
            total += totalPrice ?? 0.00
        }
        
        grandTotal = total.formatted(.currency(code: "USD"))
    }
    
    private func createSampleData()
    {
        let kitchenTask = Task(
            taskTitle: "Kitchen Renovation",
            taskDescription: "Paint kitchen walls and cabinets",
            comment: "Need to finish before the holidays",
            location: "Kitchen",
            isCompleted: false,
            category: "Painting",
            priority: "High"
        )
        
        let paintItem1 = TaskItem(
            itemTitle: "Wall Paint",
            itemDescription: "Eggshell white paint for walls",
            comment: "Need 2 gallons"
        )
        paintItem1.quantity = "2"
        paintItem1.purchasedPrice = "$34.99"
        paintItem1.wasPurchased = true
        paintItem1.url = "https://www.homedepot.com"
        paintItem1.task = kitchenTask
        
        let paintItem2 = TaskItem(
            itemTitle: "Cabinet Paint",
            itemDescription: "Semi-gloss gray paint for cabinets",
            comment: "Premium quality"
        )
        paintItem2.quantity = "1"
        paintItem2.purchasedPrice = "$45.99"
        paintItem2.wasPurchased = false
        paintItem2.task = kitchenTask
        
        let paintItem3 = TaskItem(
            itemTitle: "Paint Brushes",
            itemDescription: "Professional brush set",
            comment: "3-inch and 2-inch brushes"
        )
        paintItem3.quantity = "1"
        paintItem3.purchasedPrice = "$24.99"
        paintItem3.wasPurchased = true
        paintItem3.url = "https://www.amazon.com"
        paintItem3.task = kitchenTask
        
        kitchenTask.taskItems = [paintItem1, paintItem2, paintItem3]
        
        let bedroomTask = Task(
            taskTitle: "Bedroom Organization",
            taskDescription: "Organize closet and install shelving",
            comment: "Spring cleaning project",
            location: "Bedroom",
            isCompleted: false,
            category: "Organizing",
            priority: "Medium"
        )
        
        let storageItem1 = TaskItem(
            itemTitle: "Storage Bins",
            itemDescription: "Clear plastic storage containers",
            comment: "Large size"
        )
        storageItem1.quantity = "6"
        storageItem1.purchasedPrice = "$12.99"
        storageItem1.wasPurchased = true
        storageItem1.task = bedroomTask
        
        let storageItem2 = TaskItem(
            itemTitle: "Closet Shelving",
            itemDescription: "Wire shelving system",
            comment: "Adjustable height"
        )
        storageItem2.quantity = "1"
        storageItem2.purchasedPrice = "$89.99"
        storageItem2.wasPurchased = false
        storageItem2.url = "https://www.ikea.com"
        storageItem2.task = bedroomTask
        
        bedroomTask.taskItems = [storageItem1, storageItem2]
        
        let livingRoomTask = Task(
            taskTitle: "Living Room Deep Clean",
            taskDescription: "Deep clean carpets and upholstery",
            comment: "Annual deep cleaning",
            location: "Living Room",
            isCompleted: true,
            category: "Cleaning",
            priority: "Low"
        )
        livingRoomTask.completedDate = Date.now.formatted(date: .abbreviated, time: .shortened)
        
        let cleaningItem1 = TaskItem(
            itemTitle: "Carpet Cleaner Solution",
            itemDescription: "Professional strength cleaner",
            comment: "Fresh scent"
        )
        cleaningItem1.quantity = "2"
        cleaningItem1.purchasedPrice = "$18.99"
        cleaningItem1.wasPurchased = true
        cleaningItem1.task = livingRoomTask
        
        let cleaningItem2 = TaskItem(
            itemTitle: "Upholstery Brush",
            itemDescription: "Soft bristle brush attachment",
            comment: "For delicate fabrics"
        )
        cleaningItem2.quantity = "1"
        cleaningItem2.purchasedPrice = "$15.49"
        cleaningItem2.wasPurchased = true
        cleaningItem2.task = livingRoomTask
        
        livingRoomTask.taskItems = [cleaningItem1, cleaningItem2]
        
        let garageTask = Task(
            taskTitle: "Garage Door Repair",
            taskDescription: "Fix garage door opener and lubricate tracks",
            comment: "Door is making loud noises",
            location: "Garage",
            isCompleted: false,
            category: "Repair",
            priority: "High"
        )
        
        let repairItem = TaskItem(
            itemTitle: "Garage Door Lubricant",
            itemDescription: "Silicone-based lubricant spray",
            comment: "Weather resistant"
        )
        repairItem.quantity = "1"
        repairItem.purchasedPrice = "$9.99"
        repairItem.wasPurchased = true
        repairItem.url = "https://www.lowes.com"
        repairItem.task = garageTask
        
        garageTask.taskItems = [repairItem]
        
        let officeTask = Task(
            taskTitle: "Home Office Setup",
            taskDescription: "Set up new desk and organize cables",
            comment: "Work from home setup",
            location: "Home Office",
            isCompleted: false,
            category: "Miscellaneous",
            priority: "Medium"
        )
        
        modelContext.insert(kitchenTask)
        modelContext.insert(bedroomTask)
        modelContext.insert(livingRoomTask)
        modelContext.insert(garageTask)
        modelContext.insert(officeTask)
        
        populateGrandTotal()
    }

    var body: some View
    {
        NavigationStack(path: $path)
        {
            Group
            {
                if tasks.count == 0
                {
                    VStack(spacing: 24)
                    {
                        Spacer()
                        
                        ZStack
                        {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.1), .purple.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "checklist")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 8)
                        {
                            Text("No Tasks Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Tap the plus button to create your first task, or use Sample Data to explore.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        HStack(spacing: 12)
                        {
                            Button
                            {
                                createSampleData()
                            } label: {
                                HStack
                                {
                                    Image(systemName: "doc.on.doc.fill")
                                    Text("Sample Data")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            
                            Button
                            {
                                path.append(NewTaskRoute())
                            } label: {
                                HStack
                                {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Task")
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                                .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                    }
                }
                else if filteredTasks.count == 0
                {
                    VStack(spacing: 24)
                    {
                        Spacer()
                        
                        ZStack
                        {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.1), .yellow.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 8)
                        {
                            Text("No Matching Tasks")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Try adjusting your filter to see more results.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        Button
                        {
                            withAnimation
                            {
                                selectedSearchType = .none
                                filterValue = "All"
                            }
                        } label: {
                            HStack
                            {
                                Image(systemName: "xmark.circle.fill")
                                Text("Clear Filter")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                }
                else
                {
                    ScrollView
                    {
                        VStack(spacing: 20)
                        {
                            // Enhanced stats cards
                            HStack(spacing: 12)
                            {
                                // Grand Total Card
                                VStack(alignment: .leading, spacing: 8)
                                {
                                    HStack
                                    {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.green, .mint],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Spacer()
                                    }
                                    
                                    Text("Grand Total")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(grandTotal)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    LinearGradient(
                                        colors: [.green.opacity(0.1), .mint.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
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
                                
                                // Task Count Card
                                VStack(alignment: .leading, spacing: 8)
                                {
                                    HStack
                                    {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .cyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        Spacer()
                                    }
                                    
                                    Text("Total Tasks")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("\(filteredTasks.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.1), .cyan.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
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
                            }
                            .padding(.horizontal)
                            
                            // Completion stats
                            if !filteredTasks.isEmpty
                            {
                                let completedCount = filteredTasks.filter { $0.isCompleted }.count
                                let completionPercentage = Double(completedCount) / Double(filteredTasks.count)
                                
                                VStack(alignment: .leading, spacing: 12)
                                {
                                    HStack
                                    {
                                        HStack(spacing: 6)
                                        {
                                            Image(systemName: "chart.bar.fill")
                                                .foregroundStyle(.purple)
                                            Text("Progress")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(completedCount) of \(filteredTasks.count) completed")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading)
                                        {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.15))
                                                .frame(height: 12)
                                            
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.purple, .pink],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: geometry.size.width * completionPercentage, height: 12)
                                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completionPercentage)
                                        }
                                    }
                                    .frame(height: 12)
                                    
                                    HStack(spacing: 20)
                                    {
                                        HStack(spacing: 4)
                                        {
                                            Circle()
                                                .fill(.green)
                                                .frame(width: 8, height: 8)
                                            Text("Completed: \(completedCount)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        HStack(spacing: 4)
                                        {
                                            Circle()
                                                .fill(.orange)
                                                .frame(width: 8, height: 8)
                                            Text("Pending: \(filteredTasks.count - completedCount)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                            }
                            
                            // Active filter indicator
                            if selectedSearchType != .none
                            {
                                HStack
                                {
                                    Image(systemName: filterIconFor(selectedSearchType))
                                        .foregroundStyle(.white)
                                        .font(.caption)
                                    
                                    Text("Filtered by: \(filterValue)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Button
                                    {
                                        withAnimation
                                        {
                                            selectedSearchType = .none
                                            filterValue = "All"
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white.opacity(0.8))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.indigo, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                                .padding(.horizontal)
                            }
                            
                            LazyVStack(spacing: 12)
                            {
                                ForEach(filteredTasks)
                                {
                                    task in
                                    
                                    TaskRowView(task: task, styleForPriority: styleForPriority)
                                        .contentShape(Rectangle())
                                        .onTapGesture { path.append(task) }
                                        .contextMenu
                                        {
                                            Button(role: .destructive)
                                            {
                                                withAnimation { modelContext.delete(task) }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            
                                            Button { path.append(task) } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                        }
                                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: filteredTasks)
                }
            }
            .navigationDestination(for: Task.self) { task in
                EditTaskView(task: task, path: $path)
            }
            .navigationDestination(for: NewTaskRoute.self) { _ in
                let placeholder = Task(taskTitle: Constants.EMPTY_STRING, taskDescription: Constants.EMPTY_STRING, comment: Constants.EMPTY_STRING)
                EditTaskView(task: placeholder, path: $path, isNew: true)
            }
            .toolbar
            {
                ToolbarItemGroup(placement: .topBarTrailing)
                {
                    if tasks.count > 0
                    {
                        Menu
                        {
                            Menu
                            {
                                ForEach(LocationEnum.allCases)
                                {
                                    location in
                                    Button
                                    {
                                        selectedSearchType = .location
                                        filterValue = location.title
                                    } label: {
                                        HStack
                                        {
                                            Text(location.title)
                                            Spacer()
                                            if selectedSearchType == .location && filterValue == location.title
                                            {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Label("Location", systemImage: "location.fill")
                            }
                            
                            Menu
                            {
                                ForEach(CategoryEnum.allCases)
                                {
                                    category in
                                    Button
                                    {
                                        selectedSearchType = .category
                                        filterValue = category.title
                                    } label: {
                                        HStack
                                        {
                                            Text(category.title)
                                            Spacer()
                                            if selectedSearchType == .category && filterValue == category.title
                                            {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Label("Category", systemImage: "tag.fill")
                            }
                            
                            Menu
                            {
                                ForEach(PriorityEnum.allCases)
                                {
                                    priority in
                                    Button
                                    {
                                        selectedSearchType = .priority
                                        filterValue = priority.title
                                    } label: {
                                        HStack
                                        {
                                            Text(priority.title)
                                            Spacer()
                                            if selectedSearchType == .priority && filterValue == priority.title
                                            {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Label("Priority", systemImage: "flag.fill")
                            }
                            
                            Menu
                            {
                                ForEach(StatusEnum.allCases)
                                {
                                    status in
                                    Button
                                    {
                                        selectedSearchType = .status
                                        filterValue = status.rawValue
                                    } label: {
                                        HStack
                                        {
                                            Text(status.title)
                                            Spacer()
                                            if selectedSearchType == .status && filterValue == status.rawValue
                                            {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Label("Status", systemImage: "checkmark.circle.fill")
                            }
                            
                            if selectedSearchType != .none
                            {
                                Divider()
                                
                                Button(role: .destructive)
                                {
                                    selectedSearchType = .none
                                    filterValue = "All"
                                } label: {
                                    Label("Clear Filter", systemImage: "xmark.circle")
                                }
                            }
                        } label: {
                            Label("Filter", systemImage: selectedSearchType == .none ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    
                    Button { path.append(NewTaskRoute()) } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                }

                if tasks.count > 0
                {
                    ToolbarItem(placement: .topBarLeading)
                    {
                        Menu
                        {
                            Button { createSampleData() } label: {
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
    
    private func filterIconFor(_ filter: FilterEnum) -> String
    {
        switch filter
        {
        case .none:
            return "line.3.horizontal.decrease"
        case .location:
            return "location.fill"
        case .category:
            return "tag.fill"
        case .priority:
            return "flag.fill"
        case .status:
            return "checkmark.circle.fill"
        }
    }
}

#Preview
{
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, TaskItem.self, configurations: config)
    
    let context = container.mainContext
    
    let sampleTask = Task(
        taskTitle: "Preview Task",
        taskDescription: "This is a sample task for preview",
        comment: "Preview comment",
        location: "Kitchen",
        isCompleted: false,
        category: "Cleaning",
        priority: "High"
    )
    
    let sampleItem = TaskItem(
        itemTitle: "Sample Item",
        itemDescription: "A sample task item",
        comment: "Test item"
    )
    sampleItem.quantity = "2"
    sampleItem.purchasedPrice = "$15.99"
    sampleItem.wasPurchased = true
    sampleItem.task = sampleTask
    
    sampleTask.taskItems = [sampleItem]
    
    context.insert(sampleTask)
    
    return TaskListView()
        .modelContainer(container)
}

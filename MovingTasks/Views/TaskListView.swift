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
                            Button { createSampleData() } label: {
                                Label("Sample Data", systemImage: "doc.on.doc.fill")
                            }
                            .buttonStyle(.bordered)
                            
                            Button { path.append(NewTaskRoute()) } label: {
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
                                }
                                
                                Spacer()
                                
                                Text("\(filteredTasks.count)").font(.title2).fontWeight(.bold).foregroundStyle(.blue)
                                +
                                Text(" tasks").font(.caption).foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                            
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
                                        Label(location.title, systemImage: selectedSearchType == .location && filterValue == location.title ? "checkmark" : "")
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
                                        Label(category.title, systemImage: selectedSearchType == .category && filterValue == category.title ? "checkmark" : "")
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
                                        Label(priority.title, systemImage: selectedSearchType == .priority && filterValue == priority.title ? "checkmark" : "")
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
                                        Label(status.title, systemImage: selectedSearchType == .status && filterValue == status.rawValue ? "checkmark" : "")
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

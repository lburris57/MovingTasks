//
//  TaskListView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import SwiftData
import SwiftUI

struct TaskListView: View
{
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Task.taskTitle) var tasks: [Task]

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

    //  Returns the color based on the priority
    private func styleForPriority(_ value: String) -> Color
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

            // Delete the task
            modelContext.delete(task)
        }
    }
    
    mutating func filterAndSort(isCompleted: Bool, sortOrder: [SortDescriptor<Task>])
    {
        _tasks = Query(filter: #Predicate<Task>
        {
            task in
            
            task.isCompleted == true
        }, 
            sort: sortOrder)
    }

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
                                .navigationDestination(for: Task.self)
                                {
                                    task in
                                    
                                    EditTaskView(task: task, path: $path)
                                }
                            }
                            .onDelete(perform: deleteTask)
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
                            let task = Task(taskTitle: Constants.EMPTY_STRING,
                                            taskDescription: Constants.EMPTY_STRING,
                                            comment: Constants.EMPTY_STRING)

                            modelContext.insert(task)

                            path.append(task)
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
            }
        }
    }
}

struct FilterView: View
{
    @Binding  var filterValue: String
    
    @Binding var selectedSearchType: FilterEnum
    
    func setFilterValue()
    {
        filterValue = "All"
    }
    
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
    do
    {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(for: Task.self, TaskItem.self, configurations: config)

        return TaskListView().modelContainer(container)
    }
    catch
    {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}

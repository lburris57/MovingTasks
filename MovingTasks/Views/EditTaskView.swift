//
//  EditTaskView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import FloatingPromptTextField
import SwiftData
import SwiftUI

struct EditTaskView: View
{
    @Bindable var task: Task

    @Environment(\.modelContext) var modelContext

    @Environment(\.colorScheme) var colorScheme

    @Binding var path: NavigationPath

    func toggleIsComplete()
    {
        task.isCompleted.toggle()
    }
    
    private func deleteTaskItem(at indexSet: IndexSet)
    {
        indexSet.forEach
        {
            index in

            let taskItem = task.taskItemsArray[index]

            // Delete the task item
            modelContext.delete(taskItem)
        }
    }

    var body: some View
    {
        ZStack
        {
            LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.25)
                .ignoresSafeArea()
            
            Form
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
                    
                    VStack(alignment: .leading, spacing: 5)
                    {
                        Text("Date Created:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                        Text("\(task.createdDate)")
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
                
                if task.taskItemsArray.count > 0
                {
                    VStack(alignment: .leading)
                    {
                        Text("Task Items").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                        
                        List
                        {
                            ForEach(task.taskItemsArray)
                            {
                                taskItem in
                                
                                NavigationLink(value: taskItem)
                                {
                                    Text("Created date: \(taskItem.createdDate)")
                                }
                            }
                            .onDelete(perform: deleteTaskItem)
                            .listStyle(.plain)
                            .padding(.bottom)
                        }
                    }
                    .navigationDestination(for: TaskItem.self)
                    {
                        taskItem in
                        
                        EditTaskItemView(taskItem: taskItem, path: $path)
                    }
                }
            }
            .toolbar
            {
                ToolbarItem
                {
                    VStack(alignment: .trailing, spacing: 0)
                    {
                        Button("Save")
                        {
                            path = NavigationPath()
                        }
                        .padding(.horizontal)
                        
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
            }
            .navigationTitle(validateFields() ? "Edit Task" : "Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear(perform: validateTask)
            .navigationDestination(for: TaskItem.self)
            {
                taskItem in
                
                EditTaskItemView(taskItem: taskItem, path: $path)
            }
        }
    }

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

    func validateFields() -> Bool
    {
        if task.taskTitle == Constants.EMPTY_STRING || task.taskDescription == Constants.EMPTY_STRING || task.comment == Constants.EMPTY_STRING
        {
            return false
        }

        return true
    }
}

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

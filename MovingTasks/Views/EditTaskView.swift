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
    
    func toggleIsComplete()
    {
        task.isCompleted.toggle()
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
                FloatingPromptTextField(text: $task.taskTitle, prompt: Text("Title:")
                    .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                
                FloatingPromptTextField(text: $task.taskDescription, prompt: Text("Description:")
                    .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                
                FloatingPromptTextField(text: $task.comment, prompt: Text("Comment:")
                    .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                
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
                            
                            Text(priority.title).tag(priority.title)
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
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear(perform: validateTask)
        }
    }
    
    func validateTask()
    {
        if task.taskTitle == "" || task.taskDescription == "" || task.comment == ""
        {
            withAnimation
            {
                modelContext.delete(task)
            }
        }
    }
}

#Preview
{
    do
    {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(for: Task.self, configurations: config)
        
        return EditTaskView(task: Task.sampleData()[0]).modelContainer(container)
    }
    catch
    {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}

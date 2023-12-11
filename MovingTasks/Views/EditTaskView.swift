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
    
    @State private var priority: String = PriorityEnum.medium.title
    
    func toggleIsComplete()
    {
        task.isCompleted?.toggle()
    }
    
    func updatePriority()
    {
        task.priority = priority
    }
    
    var body: some View
    {
        Form
        {
            FloatingPromptTextField(text: $task.taskTitle.toUnwrapped(defaultValue: ""), prompt: Text("Title:"))
            
            FloatingPromptTextField(text: $task.taskDescription.toUnwrapped(defaultValue: ""), prompt: Text("Description:"))
            
            FloatingPromptTextField(text: $task.comment.toUnwrapped(defaultValue: ""), prompt: Text("Comment:"))
            
            VStack(alignment: .leading, spacing: 5)
            {
                Text("Category:").font(.caption2).foregroundStyle(.blue)
                
                Picker(Constants.EMPTY_STRING, selection: $task.category.toUnwrapped(defaultValue: "Miscellaneous"))
                {
                    ForEach(CategoryEnum.allCases)
                    {
                        category in
                        
                        Text(category.title).tag(category.title)
                    }
                }
                .pickerStyle(.menu)
                .onSubmit
                {
                    updatePriority()
                }
                .labelsHidden()
            }
            
            VStack(alignment: .leading, spacing: 5)
            {
                Text("Priority:").font(.caption2).foregroundStyle(.blue)
                
                Picker(Constants.EMPTY_STRING, selection: $task.priority.toUnwrapped(defaultValue: "Medium"))
                {
                    ForEach(PriorityEnum.allCases)
                    {
                        priority in
                        
                        Text(priority.title).tag(priority.title)
                    }
                }
                .pickerStyle(.segmented)
                .onSubmit
                {
                    updatePriority()
                }
                .labelsHidden()
            }
            
            VStack(alignment: .leading, spacing: 5)
            {
                Text("Status:").font(.caption2).foregroundStyle(.blue)
                
                HStack
                {
                    Text("\(task.wrappedIsCompleted)")
                    Spacer()
                    Button(action: 
                    {
                        toggleIsComplete()
                    },
                    label: 
                    {
                        Image(systemName: task.isCompleted! ? "checkmark.square" : "square")
                    })
                }
            }
            
            VStack(alignment: .leading, spacing: 5)
            {
                Text("Date Created:").font(.caption2).foregroundStyle(.blue)
                Text("\(task.wrappedCreatedDate)")
            }
        }
        .navigationTitle("Edit Task")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: validateTask)
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

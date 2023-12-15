//
//  EditTaskItemView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/12/23.
//
import FloatingPromptTextField
import SwiftData
import SwiftUI

struct EditTaskItemView: View
{
    @Bindable var taskItem: TaskItem
    
    @Binding var path: NavigationPath
    
    @State private var quantityInt = 0
    
    @Environment(\.modelContext) var modelContext
    
    @Environment(\.colorScheme) var colorScheme
    
    func validateFields() -> Bool
    {
        if taskItem.itemTitle == Constants.EMPTY_STRING || 
             taskItem.itemDescription == Constants.EMPTY_STRING ||
             taskItem.comment == Constants.EMPTY_STRING
        {
            return false
        }

        return true
    }
    
    func toggleWasPurchased()
    {
        taskItem.wasPurchased.toggle()
    }
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            Form
            {
                Section("Task Item Information")
                {
                    FloatingPromptTextField(text: $taskItem.itemTitle, prompt: Text("Title:")
                        .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                    
                    FloatingPromptTextField(text: $taskItem.itemDescription, prompt: Text("Description:")
                        .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                    
                    FloatingPromptTextField(text: $taskItem.comment, prompt: Text("Comment:")
                        .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                    .floatingPromptScale(1.0)
                }
                
                Section("Purchase Information")
                {
                    VStack(alignment: .leading, spacing: 12)
                    {
                        Text("Was this item purchased?").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                        
                        HStack
                        {
                            Text(taskItem.wrappedWasPurchased)
                            
                            Spacer()
                            
                            Button(action:
                            {
                                toggleWasPurchased()
                                
                                if taskItem.wasPurchased
                                {
                                    taskItem.purchaseDate = Date.now//.formatted(date: .abbreviated, time: .shortened)
                                }
                                else
                                {
                                    taskItem.purchaseDate = Date.distantFuture
                                }
                            },
                            label:
                            {
                                Image(systemName: taskItem.wasPurchased ? "checkmark.square" : "square")
                                    .foregroundStyle(colorScheme == .dark ? .gray : .blue)
                            })
                        }
                        
                        if taskItem.wasPurchased
                        {
                            FloatingPromptTextField(text: $taskItem.quantity, prompt: Text("Quantity:")
                                .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                            .floatingPromptScale(1.0)
                            
                            FloatingPromptTextField(text: $taskItem.purchasedPrice, prompt: Text("Purchase Price:")
                                .foregroundStyle(colorScheme == .dark ? .gray : .blue))
                            .floatingPromptScale(1.0)
                            
                            VStack(alignment: .leading, spacing: 12)
                            {
                                Text("Total Price:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                                Text("\(taskItem.totalPrice)").font(.body).bold()
                                
                                Text("Purchase Date:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
                                
                                DatePicker("Please enter a date", selection: $taskItem.purchaseDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .toolbar
        {
            Menu("\(Image(systemName: "arrowshape.turn.up.left.fill"))")
            {
                Button("Go to Task Item List")
                {
                    path.removeLast(taskItem.task!.taskItems!.count)
                }
            
                Button("Go to Edit Task")
                {
                    path.removeLast(2)
                }
            
                Button("Go to Task List")
                {
                    path = NavigationPath()
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(validateFields() ? "Edit Task Item" : "Add Task Item")
        .navigationBarTitleDisplayMode(.inline)
    }
}

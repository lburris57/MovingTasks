//
//  TaskItemListView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/13/23.
//
import SwiftUI
import SwiftData

struct TaskItemListView: View 
{
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.modelContext) var modelContext
    
    @State private var grandTotal: String = Constants.ZERO_STRING
    
    var taskItems: [TaskItem]
    
    @Binding var path: NavigationPath
    
    private func deleteTaskItem(at indexSet: IndexSet)
    {
        indexSet.forEach
        {
            index in

            let taskItem = taskItems[index]

            // Delete the task item
            modelContext.delete(taskItem)
        }
    }
    
    private func populateGrandTotal()
    {
        var total: Decimal = 0.00
        
        for taskItem in taskItems
        {
            let totalPrice = Decimal(string: taskItem.totalPriceString.replacingOccurrences(of: Constants.DOLLAR_SIGN, with: Constants.EMPTY_STRING))
            
            print("Total price string from taskItem is: \( taskItem.totalPriceString)")
            print("Total price from taskItem is: \(totalPrice ?? 0.00)")
            
            total += totalPrice ?? 0.00
            
            print("Total is: \(total)")
        }
        
        grandTotal = total.formatted(.currency(code: "USD"))
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            HStack
            {
                Spacer()
                
                Text("Grand Total: " + grandTotal).font(.body).bold()
                
                Spacer()
            }
            
            List
            {
                ForEach(taskItems)
                {
                    taskItem in

                    NavigationLink(value: taskItem)
                    {
                        VStack(alignment: .leading, spacing: 5)
                        {
                            Text("\(taskItem.itemTitle)").font(.body).foregroundStyle(.primary).bold()
                            Text("\(taskItem.itemDescription)").font(.callout).foregroundStyle(.secondary).bold()
                            
                            if(taskItem.wasPurchased)
                            {
                                Text("\(taskItem.formattedTotalPriceString)").font(.callout).foregroundStyle(.secondary).bold()
                            }
                        }
                    }
                }
                .onDelete(perform: deleteTaskItem)
                .listStyle(.plain)
                .padding(.bottom)
                .navigationTitle("Task Item List")
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar
            {
                Menu("\(Image(systemName: "arrowshape.turn.up.left.fill"))")
                {
                    Button("Go to Task List")
                    {
                        path = NavigationPath()
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationDestination(for: TaskItem.self)
        {
            taskItem in

            EditTaskItemView(taskItem: taskItem, path: $path)
        }
        .onAppear(perform: populateGrandTotal)
    }
}

//#Preview
//{
//    do
//    {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//
//        let container = try ModelContainer(for: Task.self, TaskItem.self, configurations: config)
//
//        return TaskItemListView().modelContainer(container)
//    }
//    catch
//    {
//        Text("Failed to create container: \(error.localizedDescription)")
//    }
//}

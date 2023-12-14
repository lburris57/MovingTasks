//
//  TaskItemListView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/13/23.
//

import SwiftUI

struct TaskItemListView: View 
{
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.modelContext) var modelContext
    
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
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
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
                        }
                    }
                }
                .onDelete(perform: deleteTaskItem)
                .listStyle(.plain)
                .padding(.bottom)
                .navigationTitle("Task Item List")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationDestination(for: TaskItem.self)
        {
            taskItem in

            EditTaskItemView(taskItem: taskItem, path: $path)
        }
    }
}

//#Preview {
//    TaskItemListView()
//}

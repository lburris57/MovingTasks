//
//  EditTaskItemView.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/12/23.
//
import SwiftUI

struct EditTaskItemView: View
{
    @Bindable var taskItem: TaskItem
    
    @Binding var path: NavigationPath
    
    @Environment(\.modelContext) var modelContext
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View
    {
        VStack
        {
            Text("Created date is: \(taskItem.createdDate)")
            
            if let task = taskItem.task
            {
                Text("Task location is: \(task.location)")
            }
        }
        .padding()
        .toolbar
        {
            Menu("\(Image(systemName: "arrowshape.turn.up.left.fill"))")
            {
                    Button("Edit Task")
                    {
                        path.removeLast(taskItem.task!.taskItems!.count)
                    }
                
                    Button("Task List")
                    {
                        path = NavigationPath()
                    }
            }
            .padding(.horizontal)
        }
    }
}

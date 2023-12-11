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

    @State private var path = [Task]()

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

    var body: some View
    {
        NavigationStack(path: $path)
        {
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
                else
                {
                    List
                    {
                        ForEach(tasks)
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
                                                .fill(styleForPriority(task.wrappedPriority))
                                                .frame(width: 15, height: 15)

                                            Text(task.wrappedTaskTitle).font(.headline)
                                        }

                                        Text(task.wrappedTaskDescription).font(.callout)
                                        
                                        Text("\nCategory: \(task.wrappedCategory)").font(.caption).bold()
                                        Text("Status: \(task.wrappedIsCompleted)").font(.caption).bold()
                                        Text("Date Created: \(task.wrappedCreatedDate)").font(.caption).bold()
                                    }
                                }
                            }
                        }.onDelete(perform: deleteTask)
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

                            path = [task]
                        },
                        label:
                        {
                            HStack
                            {
                                Text("Add Task").font(.caption)
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
            .navigationDestination(for: Task.self)
            {
                task in

                EditTaskView(task: task)
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

        return TaskListView().modelContainer(container)
    }
    catch
    {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
}

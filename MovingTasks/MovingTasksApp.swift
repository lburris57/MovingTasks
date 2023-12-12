//
//  MovingTasksApp.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import SwiftData
import SwiftUI

@main
struct MovingTasksApp: App
{
    var body: some Scene
    {
        WindowGroup
        {
            LaunchScreenView()
        }
        .modelContainer(for: Task.self)
    }
    
    init()
    {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}

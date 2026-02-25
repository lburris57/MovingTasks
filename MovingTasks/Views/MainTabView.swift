//
//  MainTabView.swift
//  MovingTasks
//
//  Created on 2/24/26.
//

import SwiftUI

/// The main tab view that provides navigation between Dashboard and Tasks.
///
/// `MainTabView` serves as the primary navigation structure for the MovingTasks app,
/// offering quick access to:
/// - Dashboard: Overview and statistics of all tasks
/// - Tasks: Full task list with filtering and management
///
/// The tab bar uses SF Symbols for icons and includes visual feedback for the selected tab.
///
/// ## Usage Example
///
/// ```swift
/// @main
/// struct MovingTasksApp: App {
///     var body: some Scene {
///         WindowGroup {
///             LaunchScreenView() // Transitions to MainTabView after splash
///         }
///     }
/// }
/// ```
struct MainTabView: View
{
    /// Tracks the currently selected tab
    @State private var selectedTab = 0
    
    /// Navigation path for dashboard navigation
    @State private var dashboardPath = NavigationPath()
    
    var body: some View
    {
        TabView(selection: $selectedTab)
        {
            // Dashboard Tab
            NavigationStack(path: $dashboardPath)
            {
                DashboardView(path: $dashboardPath)
            }
            .tabItem
            {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            .tag(0)
            
            // Tasks Tab
            TaskListView()
                .tabItem
                {
                    Label("Tasks", systemImage: "list.bullet")
                }
                .tag(1)
        }
        .tint(.blue) // Accent color for selected tab
    }
}

// MARK: - Preview

#Preview
{
    MainTabView()
        .modelContainer(for: [Task.self, TaskItem.self], inMemory: true)
}

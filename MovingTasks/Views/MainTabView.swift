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
/// Uses a custom compact tab bar with opaque background for reduced vertical space usage.
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
    @State private var selectedTab: Tab = .dashboard
    
    /// Navigation path for dashboard navigation
    @State private var dashboardPath = NavigationPath()
    
    /// Available tabs
    enum Tab: String, CaseIterable
    {
        case dashboard = "Dashboard"
        case tasks = "Tasks"
        
        var icon: String
        {
            switch self
            {
            case .dashboard: return "chart.bar.fill"
            case .tasks: return "list.bullet"
            }
        }
    }
    
    var body: some View
    {
        ZStack(alignment: .bottom)
        {
            // Main content
            Group
            {
                switch selectedTab
                {
                case .dashboard:
                    NavigationStack(path: $dashboardPath)
                    {
                        DashboardView(path: $dashboardPath)
                    }
                    
                case .tasks:
                    TaskListView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom compact tab bar with opaque background
            compactTabBar
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var compactTabBar: some View
    {
        HStack(spacing: 0)
        {
            ForEach(Tab.allCases, id: \.self)
            { tab in
                compactTabButton(for: tab)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8) // Compact vertical padding
        .background(
            ZStack
            {
                // Solid opaque base layer to prevent data bleed-through
                Color(.systemBackground)
                
                // Subtle material effect on top for visual interest
                Color(.systemBackground)
                    .opacity(0.95)
                    .background(.ultraThinMaterial)
            }
        )
        .overlay(alignment: .top)
        {
            Divider()
        }
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: -1)
    }
    
    private func compactTabButton(for tab: Tab) -> some View
    {
        Button
        {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7))
            {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4)
            {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
                
                Text(tab.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6) // Compact padding
            .foregroundStyle(selectedTab == tab ? Color.blue : Color.secondary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview
{
    MainTabView()
        .modelContainer(for: [Task.self, TaskItem.self], inMemory: true)
}

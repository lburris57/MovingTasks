//
//  DashboardView.swift
//  MovingTasks
//
//  Created on 2/24/26.
//

import SwiftData
import SwiftUI

/// A comprehensive dashboard view that provides visual summaries and statistics
/// about tasks and task items in the MovingTasks application.
///
/// The dashboard displays:
/// - Overall task completion statistics
/// - Task breakdown by priority, location, and category
/// - Financial summary of purchased items
/// - Recent activity and upcoming tasks
/// - Visual charts and progress indicators
///
/// ## Features
///
/// - **Real-time Updates**: Uses SwiftData queries to automatically refresh when data changes
/// - **Interactive Cards**: Tap on summary cards to see detailed breakdowns
/// - **Visual Analytics**: Charts and graphs for easy data interpretation
/// - **Quick Actions**: Fast access to common tasks
///
/// ## Usage Example
///
/// ```swift
/// NavigationStack {
///     DashboardView(path: $navigationPath)
/// }
/// ```
struct DashboardView: View
{
    // MARK: - Properties

    /// All tasks from the database
    @Query private var tasks: [Task]

    /// All task items from the database
    @Query private var taskItems: [TaskItem]

    /// The current color scheme (light or dark mode)
    @Environment(\.colorScheme) var colorScheme

    /// Navigation path for programmatic navigation
    @Binding var path: NavigationPath

    // MARK: - Computed Properties

    /// Total number of tasks
    private var totalTasks: Int
    {
        tasks.count
    }

    /// Number of completed tasks
    private var completedTasks: Int
    {
        tasks.filter { $0.isCompleted }.count
    }

    /// Number of pending tasks
    private var pendingTasks: Int
    {
        totalTasks - completedTasks
    }

    /// Task completion percentage
    private var completionPercentage: Double
    {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100
    }

    /// Total number of task items
    private var totalItems: Int
    {
        taskItems.count
    }

    /// Number of purchased items
    private var purchasedItems: Int
    {
        taskItems.filter { $0.wasPurchased }.count
    }

    /// Total amount spent on purchased items
    private var totalSpent: Double
    {
        var total: Decimal = 0.00
        
        // Only include purchased items
        let purchasedItems = taskItems.filter { $0.wasPurchased }
        
        for item in purchasedItems
        {
            // totalPrice already returns Decimal with quantity * price
            total += item.totalPrice
        }
        
        return NSDecimalNumber(decimal: total).doubleValue
    }

    /// Tasks grouped by priority
    private var tasksByPriority: [String: Int]
    {
        Dictionary(grouping: tasks, by: { $0.priority })
            .mapValues { $0.count }
    }

    /// Tasks grouped by location
    private var tasksByLocation: [String: Int]
    {
        Dictionary(grouping: tasks, by: { $0.location })
            .mapValues { $0.count }
    }

    /// Tasks grouped by category
    private var tasksByCategory: [String: Int]
    {
        Dictionary(grouping: tasks, by: { $0.category })
            .mapValues { $0.count }
    }

    /// High priority incomplete tasks
    private var highPriorityTasks: [Task]
    {
        tasks.filter { !$0.isCompleted && $0.priority == "High" }
            .sorted { $0.createdDate > $1.createdDate }
            .prefix(5)
            .map { $0 }
    }

    /// Recently completed tasks
    private var recentlyCompletedTasks: [Task]
    {
        tasks.filter { $0.isCompleted }
            .sorted { $0.completedDate > $1.completedDate }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Body

    var body: some View
    {
        ZStack
        {
            backgroundGradient
            
            mainScrollView
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.regularMaterial, for: .navigationBar)
    }

    private var mainScrollView: some View
    {
        ScrollView
        {
            VStack(spacing: 20)
            {
                dashboardHeader
                quickStatsRow
                progressSection

                if totalItems > 0
                {
                    financialSection
                }

                breakdownSections
                priorityTaskSections
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 1) // Minimal bottom padding - let safe area handle it
        }
        .scrollContentBackground(.hidden)
    }

    private var breakdownSections: some View
    {
        Group
        {
            priorityBreakdownSection
            locationBreakdownSection
            categoryBreakdownSection
        }
    }

    private var priorityTaskSections: some View
    {
        Group
        {
            if !highPriorityTasks.isEmpty
            {
                highPrioritySection
            }

            if !recentlyCompletedTasks.isEmpty
            {
                recentlyCompletedSection
            }
        }
    }

    // MARK: - View Components

    private var backgroundGradient: some View
    {
        ZStack
        {
            // Solid base layer to prevent transparency
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Main gradient background
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.15),
                    Color.blue.opacity(0.12),
                    Color.purple.opacity(0.15),
                    Color.pink.opacity(0.10),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    private var dashboardHeader: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            Text("Welcome Back!")
                .font(.title2)
                .fontWeight(.bold)

            Text("Here's an overview of your moving tasks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }

    private var quickStatsRow: some View
    {
        HStack(spacing: 12)
        {
            totalTasksCard
            completedTasksCard
            pendingTasksCard
        }
    }

    private var totalTasksCard: some View
    {
        StatCardView(
            title: "Total Tasks",
            value: "\(totalTasks)",
            icon: "list.bullet.rectangle",
            gradient: [.blue, .cyan]
        )
    }

    private var completedTasksCard: some View
    {
        StatCardView(
            title: "Completed",
            value: "\(completedTasks)",
            icon: "checkmark.circle.fill",
            gradient: [.green, .mint]
        )
    }

    private var pendingTasksCard: some View
    {
        StatCardView(
            title: "Pending",
            value: "\(pendingTasks)",
            icon: "clock.fill",
            gradient: [.orange, .yellow]
        )
    }

    private var progressSection: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            progressHeader
            progressContent
        }
        .padding()
        .background(progressBackground)
    }

    private var progressHeader: some View
    {
        HStack
        {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("Overall Progress")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }

    private var progressContent: some View
    {
        VStack(spacing: 8)
        {
            HStack
            {
                Text("Task Completion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(completionPercentage))%")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            ProgressView(value: completionPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .scaleEffect(x: 1, y: 2, anchor: .center)

            HStack
            {
                Text("\(completedTasks) of \(totalTasks) tasks completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var progressBackground: some View
    {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    private var financialSection: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            financialHeader
            financialContent
        }
        .padding()
        .background(financialBackground)
    }

    private var financialHeader: some View
    {
        HStack
        {
            Image(systemName: "dollarsign.circle.fill")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("Financial Summary")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }

    private var financialContent: some View
    {
        VStack(spacing: 12)
        {
            HStack
            {
                VStack(alignment: .leading, spacing: 4)
                {
                    Text("Total Items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(totalItems)")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4)
                {
                    Text("Purchased")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(purchasedItems)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
            }

            Divider()

            HStack
            {
                Text("Total Spent")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "$%.2f", totalSpent))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
        }
    }

    private var financialBackground: some View
    {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .mint.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    private var priorityBreakdownSection: some View
    {
        BreakdownSectionView(
            title: "Priority Breakdown",
            icon: "exclamationmark.triangle.fill",
            gradient: [.red, .orange],
            data: tasksByPriority,
            total: totalTasks
        )
    }

    private var locationBreakdownSection: some View
    {
        BreakdownSectionView(
            title: "Location Breakdown",
            icon: "location.fill",
            gradient: [.blue, .cyan],
            data: tasksByLocation,
            total: totalTasks
        )
    }

    private var categoryBreakdownSection: some View
    {
        BreakdownSectionView(
            title: "Category Breakdown",
            icon: "folder.fill",
            gradient: [.purple, .pink],
            data: tasksByCategory,
            total: totalTasks
        )
    }

    private var highPrioritySection: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            highPriorityHeader
            highPriorityTasksList
        }
        .padding()
        .background(highPriorityBackground)
    }

    private var highPriorityHeader: some View
    {
        HStack
        {
            Image(systemName: "flag.fill")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("High Priority Tasks")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }

    private var highPriorityTasksList: some View
    {
        VStack(spacing: 8)
        {
            ForEach(highPriorityTasks, id: \.taskId)
            { task in
                DashboardTaskRow(task: task)
            }
        }
    }

    private var highPriorityBackground: some View
    {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.red.opacity(0.3), .orange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    private var recentlyCompletedSection: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            recentlyCompletedHeader
            recentlyCompletedTasksList
        }
        .padding()
        .background(recentlyCompletedBackground)
    }

    private var recentlyCompletedHeader: some View
    {
        HStack
        {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("Recently Completed")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }

    private var recentlyCompletedTasksList: some View
    {
        VStack(spacing: 8)
        {
            ForEach(recentlyCompletedTasks, id: \.taskId)
            { task in
                DashboardTaskRow(task: task, showCompletedDate: true)
            }
        }
    }

    private var recentlyCompletedBackground: some View
    {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .mint.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Supporting Views

/// A card displaying a single statistic
struct StatCardView: View
{
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]

    private var gradientColors: [Color]
    {
        gradient.map { $0.opacity(0.3) }
    }

    var body: some View
    {
        VStack(spacing: 8)
        {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(cardBackground)
    }

    private var cardBackground: some View
    {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

/// A section showing breakdown of data by category
struct BreakdownSectionView: View
{
    let title: String
    let icon: String
    let gradient: [Color]
    let data: [String: Int]
    let total: Int

    var sortedData: [(String, Int)]
    {
        data.sorted { $0.value > $1.value }
    }

    private var gradientColors: [Color]
    {
        gradient.map { $0.opacity(0.3) }
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            HStack
            {
                Image(systemName: icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            if sortedData.isEmpty
            {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            else
            {
                VStack(spacing: 12)
                {
                    ForEach(sortedData, id: \.0)
                    { item in
                        BreakdownRowView(
                            label: item.0,
                            count: item.1,
                            total: total,
                            color: gradient[0]
                        )
                    }
                }
            }
        }
        .padding()
        .background(sectionBackground)
    }

    private var sectionBackground: some View
    {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

/// A row showing a single item in a breakdown
struct BreakdownRowView: View
{
    let label: String
    let count: Int
    let total: Int
    let color: Color

    var percentage: Double
    {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }

    var body: some View
    {
        VStack(spacing: 6)
        {
            HStack
            {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("(\(Int(percentage))%)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ZStack(alignment: .leading)
            {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.2))
                    .frame(height: 6)

                GeometryReader
                { geometry in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

/// A compact row showing task information for the dashboard
struct DashboardTaskRow: View
{
    let task: Task
    var showCompletedDate: Bool = false

    var body: some View
    {
        HStack(spacing: 12)
        {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .green : .secondary)

            VStack(alignment: .leading, spacing: 4)
            {
                Text(task.taskTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 8)
                {
                    Label(task.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label(task.category, systemImage: "folder.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if showCompletedDate && task.isCompleted && !task.completedDate.isEmpty
                {
                    Label(task.completedDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            PriorityBadge(priority: task.priority)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

/// A badge showing task priority
struct PriorityBadge: View
{
    let priority: String

    var color: Color
    {
        switch priority
        {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .green
        default: return .gray
        }
    }

    var body: some View
    {
        Text(priority)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview(traits: .fixedLayout(width: 400, height: 800))
{
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path)
    {
        DashboardView(path: $path)
    }
    .modelContainer(previewContainer())
}

/// Creates a preview model container with sample data
@MainActor
private func previewContainer() -> ModelContainer
{
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, TaskItem.self, configurations: config)

    // Add sample data
    let context = container.mainContext
    Task.sampleData().forEach { context.insert($0) }

    return container
}

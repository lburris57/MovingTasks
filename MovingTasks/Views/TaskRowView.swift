//
//  TaskRowView.swift
//  MovingTasks
//
//  Created by Assistant on 2/21/26.
//

import SwiftUI

/// A modern card-style row view for displaying individual tasks.
///
/// `TaskRowView` presents task information in a visually appealing card format with:
/// - Priority indicator with colored accent
/// - Task title and description
/// - Task items badge
/// - Location and category chips
/// - Completion status with checkmark
///
struct TaskRowView: View
{
    let task: Task
    let styleForPriority: (String) -> Color
    
    private func colorForCategory(_ category: String) -> Color
    {
        switch category.lowercased()
        {
        case "cleaning":
            return .cyan
        case "painting":
            return .purple
        case "organizing":
            return .orange
        case "repair":
            return .red
        case "packing":
            return .brown
        case "removal":
            return .gray
        case "replacement":
            return .indigo
        case "carpeting":
            return .teal
        case "storage":
            return .mint
        default:
            return .blue
        }
    }
    
    private func colorForLocation(_ location: String) -> Color
    {
        switch location.lowercased()
        {
        case "kitchen":
            return .green
        case "bedroom":
            return .blue
        case "bathroom":
            return .cyan
        case "living room":
            return .orange
        case "garage":
            return .gray
        case "home office":
            return .purple
        case "basement":
            return .brown
        case "attic":
            return .indigo
        default:
            return .teal
        }
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 12)
        {
            // Header with priority and title
            HStack(alignment: .top, spacing: 12)
            {
                // Priority indicator with gradient
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [styleForPriority(task.priority), styleForPriority(task.priority).opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 5)
                    .shadow(color: styleForPriority(task.priority).opacity(0.3), radius: 2, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 6)
                {
                    HStack
                    {
                        Text(task.taskTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if task.isCompleted
                        {
                            ZStack
                            {
                                Circle()
                                    .fill(.green.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .font(.title3)
                            }
                        }
                    }
                    
                    Text(task.taskDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            // Chips for location, category, and priority
            HStack(spacing: 8)
            {
                ChipView(icon: "location.fill", text: task.location, color: colorForLocation(task.location))
                ChipView(icon: "tag.fill", text: task.category, color: colorForCategory(task.category))
                
                Spacer()
                
                // Priority badge
                HStack(spacing: 4)
                {
                    Image(systemName: "flag.fill")
                        .font(.caption2)
                    Text(task.priority)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    styleForPriority(task.priority).opacity(0.15),
                    in: Capsule()
                )
                .foregroundStyle(styleForPriority(task.priority))
                .overlay(
                    Capsule()
                        .stroke(styleForPriority(task.priority).opacity(0.3), lineWidth: 1)
                )
            }
            
            // Footer with date and task items count
            HStack
            {
                HStack(spacing: 4)
                {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(task.createdDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Task items badge
                HStack(spacing: 4)
                {
                    Image(systemName: "list.bullet.circle.fill")
                        .font(.caption)
                    Text("\(task.taskItemsArray.count) items")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .foregroundStyle(.blue)
                
                if task.isCompleted
                {
                    HStack(spacing: 4)
                    {
                        Image(systemName: "checkmark.circle")
                            .font(.caption2)
                            .foregroundStyle(.green)
                        
                        Text(task.completedDate)
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            styleForPriority(task.priority).opacity(0.3),
                            styleForPriority(task.priority).opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

/// A compact chip view for displaying categorized information with gradient styling.
struct ChipView: View
{
    let icon: String
    let text: String
    let color: Color
    
    var body: some View
    {
        HStack(spacing: 4)
        {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [color.opacity(0.15), color.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: Capsule()
        )
        .foregroundStyle(color)
        .overlay(
            Capsule()
                .stroke(color.opacity(0.25), lineWidth: 0.5)
        )
    }
}

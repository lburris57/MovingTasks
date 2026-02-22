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
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 12)
        {
            // Header with priority and title
            HStack(alignment: .top, spacing: 12)
            {
                // Priority indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(styleForPriority(task.priority))
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 4)
                {
                    HStack
                    {
                        Text(task.taskTitle)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if task.isCompleted
                        {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.title3)
                        }
                    }
                    
                    Text(task.taskDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            // Chips for location, category, and task items
            HStack(spacing: 8)
            {
                ChipView(icon: "location.fill", text: task.location, color: .blue)
                ChipView(icon: "tag.fill", text: task.category, color: .orange)
                
                Spacer()
                
                // Task items badge
                HStack(spacing: 4)
                {
                    Image(systemName: "list.bullet")
                        .font(.caption)
                    Text("\(task.taskItemsArray.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.blue.opacity(0.1), in: Capsule())
                .foregroundStyle(.blue)
            }
            
            // Footer with date
            HStack
            {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(task.createdDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if task.isCompleted
                {
                    Spacer()
                    
                    Image(systemName: "checkmark.circle")
                        .font(.caption2)
                        .foregroundStyle(.green)
                    
                    Text(task.completedDate)
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(styleForPriority(task.priority).opacity(0.2), lineWidth: 1)
        )
    }
}

/// A compact chip view for displaying categorized information.
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
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1), in: Capsule())
        .foregroundStyle(color)
    }
}

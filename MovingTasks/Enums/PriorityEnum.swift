//
//  PriorityEnum.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/11/23.
//
import Foundation

enum PriorityEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }

    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

extension PriorityEnum
{
    var title: String
    {
        switch self
        {
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
        }
    }
}

//
//  StatusEnum.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/12/23.
//
import Foundation

enum StatusEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }

    case all = "All"
    case incomplete = "Incomplete"
    case completed = "Completed"
}

extension StatusEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .incomplete:
                return "Incomplete"
            case .completed:
                return "Completed"
        }
    }
}

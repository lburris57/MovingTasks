//
//  FilterEnum.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/11/23.
//
import Foundation

enum FilterEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }

    case none = "None"
    case category = "Category"
    case location = "Location"
    case priority = "Priority"
    case status = "Status"
}

extension FilterEnum
{
    var filterType: String
    {
        switch self
        {
            case .none:
                return "None"
            case .category:
                return "Category"
            case .location:
                return "Location"
            case .priority:
                return "Priority"
            case .status:
                return "Status"
        }
    }
}

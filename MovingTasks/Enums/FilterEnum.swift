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
    case status = "Status"
    case location = "Location"
    case category = "Category"
    case priority = "Priority"
    case creationDate = "Creation Date"
    case completionDate = "Completion Date"
}

extension FilterEnum
{
    var filterType: String
    {
        switch self
        {
            case .none:
                return "None"
            case .status:
                return "Status"
            case .location:
                return "Location"
            case .category:
                return "Category"
            case .priority:
                return "Priority"
            case .creationDate:
                return "Creation Date"
            case .completionDate:
                return "Completion Date"
        }
    }
}

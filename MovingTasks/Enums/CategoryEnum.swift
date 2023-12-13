//
//  CategoryEnum.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/11/23.
//
import Foundation

enum CategoryEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }

    case all = "All"
    case cleaning = "Cleaning"
    case miscellaneous = "Miscellaneous"
    case packing = "Packing"
    case painting = "Painting"
    case removal = "Removal"
    case repair = "Repair"
    case replacement = "Replacement"
    case storage = "Storage"
}

extension CategoryEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .cleaning:
                return "Cleaning"
            case .miscellaneous:
                return "Miscellaneous"
            case .packing:
                return "Packing"
            case .painting:
                return "Painting"
            case .removal:
                return "Removal"
            case .repair:
                return "Repair"
            case .replacement:
                return "Replacement"
            case .storage:
                return "Storage"
        }
    }
}

//
//  LocationEnum.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import Foundation

enum LocationEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }

    case all = "All"
    case mainBedroom = "Main Bedroom"
    case backBedroom = "Back Bedroom"
    case basement = "Basement"
    case computerRoom = "Computer Room"
    case deck = "Deck"
    case diningRoom = "Dining Room"
    case foyer = "Foyer"
    case frontBedroom = "Front Bedroom"
    case frontPorch = "Front Porch"
    case kitchen = "Kitchen"
    case livingRoom = "Living Room"
    case mainBathroom = "Main Bathroom"
    case pantry = "Pantry"
    case smallBathroom = "Small Bathroom"
    case firstFloor = "First Floor"
    case secondFloor = "Second Floor"
    case thirdFloor = "Third Floor"
    case thirdFloorStairwell = "Third Floor Stairwell"
}

extension LocationEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .mainBedroom:
                return "Main Bedroom"
            case .backBedroom:
                return "Back Bedroom"
            case .basement:
                return "Basement"
            case .computerRoom:
                return "Computer Room"
            case .deck:
                return "Deck"
            case .diningRoom:
                return "Dining Room"
            case .foyer:
                return "Foyer"
            case .frontBedroom:
                return "Front Bedroom"
            case .frontPorch:
                return "Front Porch"
            case .kitchen:
                return "Kitchen"
            case .livingRoom:
                return "Living Room"
            case .mainBathroom:
                return "Main Bathroom"
            case .pantry:
                return "Pantry"
            case .smallBathroom:
                return "Small Bathroom"
            case .firstFloor:
                return "First Floor"
            case .secondFloor:
                return "Second Floor"
            case .thirdFloor:
                return "Third Floor"
            case .thirdFloorStairwell:
                return "Third Floor Stairwell"
            
        }
    }
}

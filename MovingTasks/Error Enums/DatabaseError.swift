//
//  DatabaseError.swift
//  ToDoSwiftData
//
//  Created by Larry Burris on 8/13/23.
//
import SwiftUI

enum DatabaseError: Error, LocalizedError
{
    case saveError
    case readError

    var errorDescription: String?
    {
        switch self
        {
            case .saveError: NSLocalizedString(Constants.DATABASE_SAVE_ERROR, comment: Constants.EMPTY_STRING)
            case .readError: NSLocalizedString(Constants.DATABASE_READ_ERROR, comment: Constants.EMPTY_STRING)
        }
    }
}

//
//  Logger+Extension.swift
//  ToDoSwiftData
//
//  Created by Larry Burris on 8/13/23.
//
import Foundation
import OSLog

extension Logger 
{
    static let subsystem = Bundle.main.bundleIdentifier!
    static let fileLocation = Logger(subsystem: subsystem, category: "FileLocation")
    static let dataStore = Logger(subsystem: subsystem, category: "TaskItem")
    static let fileManager = Logger(subsystem: subsystem, category: "Category")
}

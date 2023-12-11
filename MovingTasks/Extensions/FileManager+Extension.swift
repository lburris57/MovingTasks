//
//  FileManager+Extension.swift
//  ToDoSwiftData
//
//  Created by Larry Burris on 8/13/23.
//
import Foundation
import OSLog

extension FileManager
{
    static let fileName = "ToDos.json"
    static let logger = Logger.fileManager
    func readDocument(docName: String) throws -> Data
    {
        let url = URL.documentsDirectory.appendingPathComponent(docName)
        do
        {
            let data = try Data(contentsOf: url)
            return data
        }
        catch
        {
            Self.logger.error("\(error.localizedDescription)")
            throw DatabaseError.readError
        }
    }

    func saveDocument(contents: String, docName: String) throws
    {
        let url = URL.documentsDirectory.appendingPathComponent(docName)
        do
        {
            try contents.write(to: url, atomically: true, encoding: .utf8)
        }
        catch
        {
            Self.logger.error("\(error.localizedDescription)")
            throw DatabaseError.saveError
        }
    }

    func docExist(named docName: String) -> Bool
    {
        fileExists(atPath: URL.documentsDirectory.appendingPathComponent(docName).path)
    }
}

//
//  Binding+Extension.swift
//  MovingTasks
//
//  Created by Larry Burris on 12/10/23.
//
import Foundation
import SwiftUI

extension Binding
{
    func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>
    {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

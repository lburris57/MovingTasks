//
//  Constants.swift
//  ProjectLifecycleManager
//
//  Created by Larry Burris on 6/21/23.
//
import Foundation

struct Constants
{
    static let EMPTY_STRING = ""
    static let ZERO_STRING = "0"
    static let ZERO = 0
    static let ZERO_DECIMAL = Decimal(0.00)
    static let ZERO_CURRENCY = "0.00"
    
    static let DOLLAR_SIGN = "$"
    
    static let COMPLETE = "Complete"
    static let INCOMPLETE = "Incomplete"
    
    static let NOT_APPLICABLE = "N/A"
    
    static let YES = "Yes"
    static let NO = "No"
    
    //  Error strings
    static let DATABASE_SAVE_ERROR = "Could not save information to the database."
    static let DATABASE_READ_ERROR = "Could not load information from the database."
    
    static let US_DOLLARS_CODE = "USD"
}

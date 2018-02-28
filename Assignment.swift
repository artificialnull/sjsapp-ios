//
//  Assignment.swift
//  sjsapp
//
//  Created by Ishan on 2/23/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import Foundation
import SwiftyJSON

class Assignment {
    static var toDoColor = UIColor(red:0.75, green:0.68, blue:0.87, alpha:1.0)
    static var inProgressColor = UIColor(red:0.97, green:0.67, blue:0.35, alpha:1.0)
    static var completedColor = UIColor(red:0.10, green:0.70, blue:0.58, alpha:1.0)
    static var gradedColor = UIColor(red:0.10, green:0.70, blue:0.58, alpha:1.0)
    
    class AssignmentStatus {
        var statusString = ""
        var statusCode = 0
        var statusColor = UIColor()
        
        init(sstr: String, scode: Int, scolor: UIColor) {
            statusString = sstr
            statusCode = scode
            statusColor = scolor
        }
        init() {
        }
    }
    
    static var ToDo = AssignmentStatus(sstr: "To Do", scode: -1, scolor: toDoColor)
    static var InProgress = AssignmentStatus(sstr: "In Progress", scode: 0, scolor: inProgressColor)
    static var Completed = AssignmentStatus(sstr: "Completed", scode: 1, scolor: completedColor)
    static var Graded = AssignmentStatus(sstr: "Graded", scode: 4, scolor: gradedColor)
    
    var assignmentClass = ""
    var assignmentShort = ""
    var assignmentLong: String?
    var assignmentStatus = AssignmentStatus()
    var assignmentType = ""
    var assignmentAssigned = Date()
    var assignmentDue = Date()
    var assignmentIndexID = 0
    var assignmentID = 0
    
    func statusFromInt(status: Int) -> AssignmentStatus {
        switch status {
        case -1:
            return Assignment.ToDo
        case 0:
            return Assignment.InProgress
        case 1:
            return Assignment.Completed
        case 4:
            return Assignment.Graded
        default:
            return AssignmentStatus()
        }
    }
    
    init(json: JSON) {
        let fmt = DateFormatter()
        fmt.dateFormat = "M/d/yyyy h:mm aa"
        
        assignmentClass = json["groupname"].string!
        assignmentShort = json["short_description"].string!
        assignmentLong = json["long_description"].string
        assignmentType = json["assignment_type"].string!
        assignmentStatus = statusFromInt(status: json["assignment_status"].int!)
        assignmentAssigned = fmt.date(from: json["date_assigned"].string!)!
        assignmentDue = fmt.date(from: json["date_due"].string!)!
        assignmentIndexID = json["assignment_index_id"].int!
        assignmentID = json["assignment_id"].int!
    }
    
    init() {
    }
}


//
//  ScheduledClass.swift
//  sjsapp
//
//  Created by Ishan on 2/20/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import Foundation
import SwiftyJSON

class ScheduledClass {
    var className: String = ""
    var classStart: Date = Date()
    var classEnd: Date = Date()
    var classTeacher: String = ""
    var classBlock: String = ""
    var classRoom: String = ""
    
    init(json: JSON) {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm aa"
        
        className = json["CourseTitle"].string!
        classStart = fmt.date(from: json["MyDayStartTime"].string!)!
        classEnd = fmt.date(from: json["MyDayEndTime"].string!)!
        classTeacher = json["Contact"].string!
        classBlock = json["Block"].string!
        classRoom = json["RoomNumber"].string!
    }
    
    init() {
    }
    
}

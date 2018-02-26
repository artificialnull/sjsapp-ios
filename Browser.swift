//
//  Browser.swift
//  sjsapp
//
//  Created by Ishan on 2/19/18.
//  Copyright © 2018 GABDEG Studios. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Browser {
    
    static var un: String = ""
    static var pw: String = ""
    static var rvt: String = ""
    
    func setCredentials(username: String, password: String) {
        Browser.un = username
        Browser.pw = password
    }
    
    func getToken(handler: @escaping ((DataResponse<String>?) -> ())) {
        Alamofire.request("https://sjs.myschoolapp.com").responseString {
            response in
            if response.result.value != nil {
                Browser.rvt = response.result.value!
                    .components(separatedBy: "__AjaxAntiForgery")[1]
                    .components(separatedBy: "value=\"")[1]
                    .components(separatedBy: "\"")[0]
            }
            print(Browser.rvt)
            handler(response)
        }
    }
    
    func logIn(handler: @escaping ((DataResponse<Any>?) -> ())) {
        if Browser.un != "" && Browser.pw != "" {
            getToken() { _ in
                Alamofire.request(
                    "https://sjs.myschoolapp.com/api/SignIn",
                    method: .post,
                    parameters: [
                        "Username": Browser.un,
                        "Password": Browser.pw
                    ],
                    encoding: JSONEncoding.default
                    ).responseJSON { response in
                        print(response)
                        handler(response)
                }
            }
        }
    }
    
    func checkLogIn(handler: @escaping ((Bool) -> ())) {
        logIn() { _ in
            Alamofire.request(
                "https://sjs.myschoolapp.com/api/webapp/userstatus"
                ).responseJSON { response in
                    print(response)
                    handler(JSON(response.result.value as Any)["TokenValid"].bool!)
            }
        }
    }
    
    func getAssignmentJSON(handler: @escaping (([Assignment]?) -> ())) {
        logIn() { _ in
            Alamofire.request("https://sjs.myschoolapp.com/api/DataDirect/"
                + "AssignmentCenterAssignments/?format=json&filter=2&persona=2")
                .responseJSON { response in
                    let json = JSON(response.result.value as Any)
                    var assignments = [Assignment]()
                    for assignmentJSON in (json.array)! {
                        assignments.append(
                            Assignment(json: assignmentJSON)
                        )
                    }
                    handler(assignments)
            }
        }
    }
    
    func getScheduleJSON(date: Date,
                         handler: @escaping (([ScheduledClass]?) -> ())) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M'%2F'd'%2F'yyyy"
        logIn() { _ in
            print(formatter.string(from: date))
            Alamofire.request("https://sjs.myschoolapp.com/api/schedule/"
                + "MyDayCalendarStudentList/?scheduleDate="
                + formatter.string(from: date)
                ).responseJSON { response in
                    let json = JSON(response.result.value as Any)
                    var scheduledClasses = [ScheduledClass]()
                    for classJSON in (json.array)! {
                        scheduledClasses.append(
                            ScheduledClass(json: classJSON)
                        )
                    }
                    handler(scheduledClasses)
            }
        }
    }
    
    func updateAssignmentStatus(assignment: Assignment) {
        logIn() { _ in
            Alamofire.request("https://sjs.myschoolapp.com/api/assignment2/"
                + "assignmentstatusupdate?format=json",
                              method: .post,
                              parameters: [
                                "assignmentIndexId": assignment.assignmentIndexID,
                                "assignmentStatus": assignment.assignmentStatus.statusCode
                ],
                              encoding: JSONEncoding.default,
                              headers: [
                                "requestverificationtoken": Browser.rvt
                ]
                ).responseJSON { response in
                    print(response)
            }
        }
    }
    
}

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
    
    func clearCredentials() {
        Browser.un = ""
        Browser.pw = ""
        let cookieStore = HTTPCookieStorage.shared
        for cookie in cookieStore.cookies ?? [] {
            cookieStore.deleteCookie(cookie)
        }
    }
    
    func credentialsExist() -> Bool {
        if !Browser.un.isEmpty && !Browser.pw.isEmpty {
            return true
        }
        return false
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
                print(Browser.un)
                print(Browser.pw)
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
    
    func getAssignmentJSON(startDate: Date, endDate: Date, viewBy: Int, handler: @escaping (([Assignment]?) -> ())) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M'%2F'd'%2F'yyyy"

        logIn() { _ in
            Alamofire.request("https://sjs.myschoolapp.com/api/DataDirect/"
                + "AssignmentCenterAssignments/?format=json&filter=\(viewBy)&persona=2"
                + "&dateStart=" + formatter.string(from: startDate)
                + "&dateEnd="   + formatter.string(from: endDate)
                )
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
    
    func getFullAssignment(assignment: Assignment, handler: @escaping ((Assignment?) -> ())) {
        logIn() { _ in
            Alamofire.request(
                "https://sjs.myschoolapp.com/api/assignment2/read/\(assignment.assignmentID)/?format=json"
                ).responseJSON { response in
                    let json = JSON(response.result.value as Any)
                    var links = [Assignment.Link]()
                    var dnlds = [Assignment.Download]()
                    let linkJSON = json["LinkItems"].array
                    
                    for link in linkJSON! {
                        links.append(
                            Assignment.Link(url: link["Url"].string!,
                                            title: link["ShortDescription"].string!)
                        )
                    }
                    
                    let dnldJSON = json["DownloadItems"].array
                    
                    for dnld in dnldJSON! {
                        dnlds.append(
                            Assignment.Download(url: dnld["DownloadUrl"].string!,
                                                title: dnld["ShortDescription"].string!)
                        )
                    }
                    assignment.assignmentLinks = links
                    assignment.assignmentDownloads = dnlds
                    handler(assignment)
            }
        }
    }
    
    func downloadFile(download: Assignment.Download, handler: @escaping ((DownloadResponse<Data>?) -> ())) {
        let destination = DownloadRequest
            .suggestedDownloadDestination(for: .documentDirectory)
        print(destination)
        Alamofire.download(download.extraUrl, to: destination).responseData {
            response in handler(response)}

    }
    
}

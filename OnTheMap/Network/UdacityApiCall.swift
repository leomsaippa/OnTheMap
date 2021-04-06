//
//  UdacityApiCall.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 02/04/21.
//

import Foundation

class UdacityApiCall: NSObject {
    

    //All endpoints
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case udacitySignUp
        case udacityLogin
        case getStudentLocations
        case addLocation
        case updateLocation
        case getLoggedInUserProfile
        
        var stringValue: String {
            switch self {
            case .udacitySignUp:
                return "https://auth.udacity.com/sign-up"
            case .udacityLogin:
                return Endpoints.base + "/session"
            case .getStudentLocations:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .addLocation:
                return Endpoints.base + "/StudentLocation"
            case .updateLocation:
                return Endpoints.base + "/StudentLocation/" + Auth.objectId
            case .getLoggedInUserProfile:
                return Endpoints.base + "/users/" + Auth.key
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    struct Auth {
        static var sessionId: String? = nil
        static var key = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
    }
    
    
    class func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        
        RequestHelper.taskForPOSTRequest(url: Endpoints.udacityLogin.url,isStudentCall: false, responseType: LoginResponse.self, body: body, httpMethod: "POST") { (response, error) in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
                getLoggedInUserProfile(completion: { (success, error) in
                    if success {
                        print("Login succesfully")
                    }
                })
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    class func getLoggedInUserProfile(completion: @escaping (Bool, Error?) -> Void) {
        RequestHelper.taskForGETRequest(url: Endpoints.getLoggedInUserProfile.url, isStudentCall: false, responseType: User.self) { (response, error) in
            if let response = response {
                print("First Name : \(response.firstName) && Last Name : \(response.lastName) && Full Name: \(response.nickname)")
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                print("Failed to get user's profile.")
                completion(false, error)
            }
        }
    }
    
    class func getStudentLocations(completion: @escaping ([StudentInfo]?, Error?) -> Void) {
        RequestHelper.taskForGETRequest(url: Endpoints.getStudentLocations.url,isStudentCall: true, responseType: StudentLocation.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
                print("Succes")
                print(response.results.count)
            } else {
                completion([], error)
                print("error")
            }
        }
    }
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.udacityLogin.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error logging out.")
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    class func addStudentLocation(information: StudentInfo, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        RequestHelper.taskForPOSTRequest(url: Endpoints.addLocation.url, isStudentCall: true, responseType: StudentPostResponse.self, body: body, httpMethod: "POST") { (response, error) in
            if let response = response, response.createdAt != nil {
                Auth.objectId = response.objectId ?? ""
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func updateStudentLocation(information: StudentInfo, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        RequestHelper.taskForPOSTRequest(url: Endpoints.updateLocation.url, isStudentCall: true, responseType: UpdateStudantResponse.self, body: body, httpMethod: "PUT") { (response, error) in
            if let response = response, response.updatedAt != nil {
                completion(true, nil)
            }
            completion(false, error)
        }
    }

    
}

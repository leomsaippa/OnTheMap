    //
    //  RequestHelper.swift
    //  OnTheMap
    //
    //  Created by Leonardo Saippa on 02/04/21.
    //

    import Foundation

    class RequestHelper {
        

        class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           
            let task = URLSession.shared.dataTask(with: request) { data, response, error  in
                if error != nil {
                    completion(nil, error)
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                do {
                    let range = 5..<data.count
                        let newData = data.subdata(in: range)
                        let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                        DispatchQueue.main.async {
                            completion(responseObject, nil)
                        }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            task.resume()
        }
        
        // MARK: Helper for POST or PUT Requests
        
        class func taskForPOSTRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: String, httpMethod: String, completion: @escaping (ResponseType?, Error?) -> Void) {
            var request = URLRequest(url: url)
            if httpMethod == "POST" {
                request.httpMethod = "POST"
            } else {
                request.httpMethod = "PUT"
            }
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = body.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion(nil, error)
                }
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                do {
                        let range = 5..<data.count
                        let newData = data.subdata(in: range)
                        let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                        DispatchQueue.main.async {
                            completion(responseObject, nil)
                        }
                   
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            task.resume()
        }
        
    }


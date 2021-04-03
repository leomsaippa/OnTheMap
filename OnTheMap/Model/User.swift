//
//  User.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 02/04/21.
//

import Foundation

struct User: Codable {
    let firstName: String
    let lastName: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
    }
 
}

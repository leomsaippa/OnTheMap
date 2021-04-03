//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 02/04/21.
//

import Foundation

struct LoginResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

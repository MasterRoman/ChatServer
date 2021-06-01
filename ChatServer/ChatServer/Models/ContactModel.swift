//
//  ContactModel.swift
//  CourseworkChat
//
//  Created by Admin on 01.06.2021.
//

import Foundation

class Contact : Codable{
    let login : String
    let name : String?
    let surname : String?
    
    init(with login : String,name : String?,surname : String?) {
        self.login = login
        self.name = name
        self.surname = surname
    }
}

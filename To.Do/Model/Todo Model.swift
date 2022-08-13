//
//  Todo Model.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-12.
//

import Foundation

struct Todo{
    let id: Int
    let text: String
    let isDone: Bool
    let highPriority: Bool
    let reminder: String?  // TODO: Change to date later
}

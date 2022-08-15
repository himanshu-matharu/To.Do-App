//
//  SectionModel.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-15.
//

import Foundation

enum Section {
    case todo(items: [Todo])
    case done(items: [Todo])
}

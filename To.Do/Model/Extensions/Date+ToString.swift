//
//  Date+ToString.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-13.
//

import Foundation

extension Date{
    func toString(format:String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

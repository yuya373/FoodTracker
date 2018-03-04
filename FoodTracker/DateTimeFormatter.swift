//
//  File.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/03/04.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit

struct DateTimeFormatter {
    static let formatter = buildFormatter()

    private static func buildFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    static func string(from: Date) -> String {
        return formatter.string(from: from)
    }
    
    static func date(from: String) -> Date? {
        return formatter.date(from: from)
    }
}

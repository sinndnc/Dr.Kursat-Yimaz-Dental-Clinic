//
//  Date+Extensions.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import Foundation


extension Date {
    var kyFormatted: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM yyyy"
        return f.string(from: self)
    }
    
    var kyFormattedWithTime: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM yyyy, HH:mm"
        return f.string(from: self)
    }
    
    var kyRelative: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
        if days == 0 { return "Bugün" }
        if days == 1 { return "Yarın" }
        if days == -1 { return "Dün" }
        if days > 1 { return "\(days) gün sonra" }
        return "\(-days) gün önce"
    }
}

//
//  Double+Extensions.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import Foundation

extension Double {
    var formatted_TRY: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "₺"
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "tr_TR")
        return f.string(from: NSNumber(value: self)) ?? "₺\(Int(self))"
    }
}

//
//  Helper.swift
//  Investor
//
//  Created by Karan Gill on 1/24/26.
//


func flagEmoji(_ countryCode: String) -> String {
    let base: UInt32 = 127397
    return countryCode
        .uppercased()
        .unicodeScalars
        .compactMap { UnicodeScalar(base + $0.value) }
        .map { String($0) }
        .joined()
}

//
//  SunInfo.swift
//  sun
//
//  Created by Bohdan on 3/23/19.
//  Copyright © 2019 Bohdan Podvirnyi. All rights reserved.
//

import Foundation

final class SunInfo {
    
    var sunriseTime: String = ""
    var sunsetTime: String = ""
    
    init(result: NSDictionary?) {
        guard let result = result else { return }
        
        sunriseTime = UTCToLocal(dateString: result["sunrise"] as? String)
        sunsetTime = UTCToLocal(dateString: result["sunset"] as? String)
    }
    
    private func UTCToLocal(dateString: String?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        var date = dateFormatter.date(from: dateString ?? "")
        if let timeZone = LocationService.shared().currentTimeZone {
            dateFormatter.timeZone = timeZone
        } else {
            dateFormatter.timeZone = TimeZone.current
        }
        date?.addTimeInterval(dateFormatter.timeZone.daylightSavingTimeOffset())
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date ?? Date())
    }
}

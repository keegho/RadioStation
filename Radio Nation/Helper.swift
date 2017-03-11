//
//  Helper.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/11/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import Foundation

class Helper {
    
    
    static var sharedInstance = Helper()
    
    func getApiKey() -> String {
        
        var apiKey = String()
        
        if let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist") {
            let results = NSDictionary(contentsOfFile: filePath)
            apiKey = results?.object(forKey: "ApiKey") as! String
        }

        return apiKey
        
    }
    
    
    
}

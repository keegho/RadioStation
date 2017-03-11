//
//  Radiostation.swift
//  Radio Nation
//
//  Created by Kegham Karsian on 3/10/17.
//  Copyright © 2017 appologi. All rights reserved.
//

import Foundation
import Alamofire

class Radiostation {
    
    var name: String
    var country: String
    var imgURL: String
    var thumbURL: String
    var listeners: Int
    var categoryTitle: String
    var streamURL: String
    var bitRate: Int
    var stationWebsite: String
    
    private var dribleApiKey: String
    
    
    init() {
        
        name = String()
        country = String()
        imgURL = String()
        thumbURL = String()
        listeners = Int()
        categoryTitle = String()
        streamURL = String()
        bitRate = Int()
        stationWebsite = String()
        dribleApiKey = Helper.sharedInstance.getApiKey()
    }
    
    //Get popular stations
    func popularStations(page: Int, stationsLimitPerPage: Int, completion:@escaping (_ data:Any?, _ status:Bool, _ error:Error?, _ msg:String?)->())
    {
        let url = URL(string:"http://api.dirble.com/v2/stations/popular?page=\(page)&per_page=\(stationsLimitPerPage)&token=\(dribleApiKey)")
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        .validate(statusCode: 200..<300)
        .responseJSON { (response) in
            switch response.result {
            case .success( _):
                print("Success")
                let jsonData = response.result.value
                completion(jsonData, true, nil, nil)
            case .failure(let err):
                completion(nil, false, err, "Failed to fetch data")
                print("failed")
            }
        }
    }
    
    

    
}

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
    
    var categoryStrcut: Categories
    var countryStruct: Countries
    
    
    
    private var dribleApiKey: String
    
    struct Categories {
        
        var id = Int()
        var name = String()
        var description = String()
    }
    
    struct Countries {
        
        var code = String()
        var name = String()
        var region = String()
        
    }
    
    
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
        categoryStrcut = Categories()
        countryStruct = Countries()
    }
    
    //Get popular stations
    func popularStations(page: Int, stationsLimitPerPage: Int, completion:@escaping (_ data:Any?, _ status:Bool, _ error:Error?, _ msg:String?)->())
    {
       // DispatchQueue.main.async {
            let url = URL(string:"http://api.dirble.com/v2/stations/popular?page=\(page)&per_page=\(stationsLimitPerPage)&token=\(self.dribleApiKey)")
            
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
         //   }

        }
    }
    
    //Get categories
    func categories(completion:@escaping (_ data:Any?, _ status:Bool, _ error:Error?, _ msg:String?)->()) {
        
        let url = URL(string:"http://api.dirble.com/v2/categories/primary?token=\(dribleApiKey)")
        
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
    
    //Get countries
    func countries(completion:@escaping (_ data:Any?, _ status:Bool, _ error:Error?, _ msg:String?)->()) {
        
        let url = URL(string:"http://api.dirble.com/v2/countries?token=\(dribleApiKey)")
        
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
    
    //Stations per category
    func categoriezedStation(categoryID: Int, completion:@escaping (_ data:Any?, _ status:Bool, _ error:Error?, _ msg:String?)->()) {
        
        let url = URL(string:"http://api.dirble.com/v2/category/\(categoryID)/stations\(dribleApiKey)")
        
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
    
    //Stations per country
    func countryStations(countryCode: String, page: Int, stationsLimitPerPage: Int, completion:@escaping (_ data:Any?, _ status:Bool, _ error:Error?, _ msg:String?)->() ) {
        
        let url = URL(string:"http://api.dirble.com/v2/countries/\(countryCode)/stations?page=\(page)&per_page=\(stationsLimitPerPage)&token=\(dribleApiKey)")
        
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

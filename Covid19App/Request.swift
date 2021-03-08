//
//  RequestAPI.swift
//  Covid19App
//
//  Created by Mac Mini on 2021/03/05.
//

import Foundation
import Alamofire

class Request {
    let apiURL:String
    let parameters : [String:Any]
    
    init(apiURL:String , parameters: [String:Any]) {
        self.apiURL = apiURL
        self.parameters = parameters
    }
    
    func DecideAPI(completionHandler: @escaping (Int) -> Void){
        AF.request(apiURL, method: .get, parameters: parameters).responseData { (response) in
            if let data = response.data {
                let value = XMLParser(xmlData: data).xmlDataParser()
                completionHandler(value)
            }
        }
    }
}



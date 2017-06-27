//
//  Network.swift
//  olxItems
//
//  Created by Daniel Torres on 6/25/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import UIKit
import Alamofire

class Network: NSObject {
    
    var host : String
    let utilityQueue = DispatchQueue.global(qos: .utility)
    var scheme: String
    var headers: HTTPHeaders?
    
    init(scheme: String, host: String){
        self.scheme = scheme
        self.host = host
    }
    
    
    //MARK:- Get Method
    
    func getMethod(params: [String:AnyObject], jsonBody: [String:AnyObject]? = nil, pathMethod: String,  completionHandlerForGet: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
    
        let url = makeUrl(with: params, and: pathMethod)
        
        let getRequest = asURLRequest(url: url, method: HTTPMethod.get, and: jsonBody)
            
        Alamofire.request(getRequest).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let result = response.result.value {
                    completionHandlerForGet(result as AnyObject, nil)
                }else {
                    let userInfo = [NSLocalizedDescriptionKey : "no value in GET task's response."]
                    let error = NSError(domain: "getMethod", code: -1, userInfo: userInfo)
                    completionHandlerForGet(nil, error)
                }
            case .failure(let error):
                print(error)
                completionHandlerForGet( nil , error as NSError)
            }
        }
    }
    

}

// MARK:- Helper methods
private extension Network {

    
    func asURLRequest(url: URL, method: HTTPMethod, and jsonBody : [String:AnyObject]? = nil) -> URLRequest {
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        
        if let headers = self.headers {
            for (key,value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        guard let jsonBody = jsonBody else {
            return urlRequest
        }
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonData
        }catch {
            return urlRequest
        }
        
        
        return urlRequest
    }
    

    func makeUrl(with parameters: [String:AnyObject]?, and pathExtension: String? = nil) -> URL{
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = pathExtension ?? ""
        
        guard let parameters = parameters else {
            return components.url!
        }
        
        components.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
}



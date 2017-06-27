//
//  ItemsManager.swift
//  olxItems
//
//  Created by Daniel Torres on 6/25/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import Foundation


protocol ItemProviderDelegate {
 
    func getLastLocations(nameOfItem: String, completionHandlerForGettingItems: @escaping (_ success: Bool, _ items: [Item]?, _ error: NSError?) -> Void)
}

class ItemsManager : NSObject {

    var networkManager : Network
    static let shared = ItemsManager()
    
    override init(){
        networkManager = Network(scheme: Constants.Domain.apiScheme, host: Constants.Domain.apiHost)
        super.init()
    }
    
    func getItems(item: String, offset: Int? = nil, completionHandlerForGettingItems: @escaping (_ success: Bool, _ locations: [Item]?, _ errorString: String?) -> Void) {
    
        let completionHandlerItemsFromServer = { (result: AnyObject?, error: NSError?) -> Void in
            
            func sendError(_ error: String) {
                print(error)
                completionHandlerForGettingItems(false, nil, "Oops!, we got some server issues please try again later")
            }
            
            guard error == nil else {
                return sendError(error!.description)
            }
            
            guard let results = result?[Constants.JSONBodyResponseKeys.data] as? [[String:AnyObject]] else {
                return sendError("Error in getItems with JSONBodyResponseKeys: data")
            }
            
            let items = Item.arrayOfItems(from: results)
            
            completionHandlerForGettingItems(true,items,nil)
            
        }
        
        let params : [String:AnyObject] =
            [Constants.UrlKeys.searchTerm: item as AnyObject,
             Constants.UrlKeys.location: Constants.Domain.location as AnyObject,
             Constants.UrlKeys.pageSize: 10 as AnyObject,
             Constants.UrlKeys.offset: offset as AnyObject]
        
        networkManager.getMethod(params: params, pathMethod: Constants.Methods.searchItems, completionHandlerForGet: completionHandlerItemsFromServer)
    }
}


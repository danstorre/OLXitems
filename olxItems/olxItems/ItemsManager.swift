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
    var shared = ItemsManager()
    
    override init(){
        networkManager = Network(scheme: Constants.Domain.apiScheme, host: Constants.Domain.apiHost)
        super.init()
    }
    
    
    func 
    
    
}


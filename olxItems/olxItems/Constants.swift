//
//  Constants.swift
//  olxItems
//
//  Created by Daniel Torres on 6/25/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import Foundation


struct Constants {

    // MARK: Constants
    struct Domain {
        
        // MARK: URLs
        static let apiScheme = "http"
        static let apiHost = "api-v2.olx.com"
        
        static let location = "www.olx.com.ar"
        
    }
    
    // MARK: Methods
    struct Methods {
        static let searchItems = "/items"
    }
    
    // MARK: URL Keys
    struct UrlKeys {
        // Locations
        static let location = "location"
        static let searchTerm = "searchTerm"
        static let pageSize = "pageSize"
        static let offset = "offset"
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        
    }
    
    // MARK: JSON Body Response Keys
    struct JSONBodyResponseKeys {
        //items
        static let data = "data"
        
        //item
        static let id = "id"
        static let title = "title"
        static let date = "date"
            //date it's a dict
            static let timestamp = "year"
            static let timezone = "Z"
        static let description = "description"
        static let priceTypeData = "priceTypeData"
        static let price = "price"
            //price it's a dict
            static let concurrency = "preCurrency"
            static let amount = "amount"
        static let mediumImage = "mediumImage"
        static let thumbnail = "thumbnail"
        static let fullImage = "fullImage"
        static let sold = "sold"
        
    }


}

//
//  Item.swift
//  olxItems
//
//  Created by Daniel Torres on 6/25/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import UIKit

struct Item{
    
    enum PriceType : String{
        case FIXED, NEGOTIABLE
    }
    
    
    var id : Double?
    var title : String?
    var date : Date?
    var priceTypeData : PriceType?
    var description : String?
    var price : Price?
    var thumbnailURL : String? = ""
    var thumbnail : UIImage?
    var mediumImageURL : String? = ""
    var mediumImage : UIImage?
    var fullImageURL : String? = ""
    var fullImage : UIImage?
    var sold : Bool?
    
    init(){
        
        id = 0
        title = ""
        date = Date()
        priceTypeData = PriceType.FIXED
        description = ""
        price = Price(amount: 0, concurrency: "$")
        mediumImage = UIImage()
        thumbnail = UIImage()
        fullImage = UIImage()
        sold = false
        
    }
    
    
    init(dictionary: [String:AnyObject]){
        
        self.init()
        
        if let id = dictionary[Constants.JSONBodyResponseKeys.id] as? Double {
            self.id = id
        }
        
        if let title = dictionary[Constants.JSONBodyResponseKeys.title] as? String {
            self.title = title
        }
        
        if let date = dictionary[Constants.JSONBodyResponseKeys.date] as? [String:AnyObject],
            let timestamp = date[Constants.JSONBodyResponseKeys.timestamp] as? String,
            let timezone = date[Constants.JSONBodyResponseKeys.timestamp] as? String {
            
            let formatterDate = DateFormatter()
            formatterDate.calendar = Calendar(identifier: .gregorian)
            formatterDate.locale = Locale.current
            formatterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" //e.g. 2017-06-25T21:09:39
            formatterDate.timeZone = TimeZone(identifier: timezone)
            
            self.date = formatterDate.date(from: timestamp)
        }
        
        if let priceTypeData = dictionary[Constants.JSONBodyResponseKeys.priceTypeData] as? String {
            self.priceTypeData = PriceType(rawValue: priceTypeData)
        }
        
        if let description = dictionary[Constants.JSONBodyResponseKeys.description] as? String {
            self.description = description
        }
        
        if let price = dictionary[Constants.JSONBodyResponseKeys.price] as? [String:AnyObject],
            let amount = price[Constants.JSONBodyResponseKeys.amount] as? Double,
            let concurrency = price[Constants.JSONBodyResponseKeys.concurrency] as? String {
            
            self.price = Price(amount: amount, concurrency: concurrency)
        }
       
        if let sold = dictionary[Constants.JSONBodyResponseKeys.sold] as? Bool {
            self.sold = sold
        }
        
        if let thumbnailURL = dictionary[Constants.JSONBodyResponseKeys.thumbnail] as? String {
            self.thumbnailURL = thumbnailURL
        }
        
        if let mediumImageURL = dictionary[Constants.JSONBodyResponseKeys.mediumImage] as? String {
            self.mediumImageURL = mediumImageURL
        }
        
        if let fullImageURL = dictionary[Constants.JSONBodyResponseKeys.fullImage] as? String {
            self.fullImageURL = fullImageURL
        }
    
    }
    
    //Mark:- Additional methods
    
    static func arrayOfItems(from dictionary: [[String:AnyObject]]) -> [Item]{
        var itemsToReturn = [Item]()
        
        for itemDict in dictionary{
            itemsToReturn.append(Item(dictionary: itemDict))
        }
        
        return itemsToReturn
        
    }
    

}

//Mark:- Additionals Structs
extension Item {

    struct Price{
        let amount : Double
        let concurrency : String
        var displayValue : String {
            get {
                //format the displayed number
                return "\(concurrency)\(amount)"
            }
        }
    }
    

}

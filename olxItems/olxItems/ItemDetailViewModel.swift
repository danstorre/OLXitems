//
//  ItemDetailViewModel.swift
//  olxItems
//
//  Created by Daniel Torres on 6/30/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ItemDetailViewModel {
    
    
    // MARK: RxSwift Observers
    var imageItemDriver: Single<Data?>? = nil
    
    
    init(string: String){
        
        
        self.imageItemDriver = ItemDetailViewModel.retrieveImage(urlString: string)
        
        
    
    }
    
    static func retrieveImage(urlString: String) -> Single<Data?> {
        return Single<Data?>.create { single in
            
            DispatchQueue.global().async {
            if let url = URL(string: urlString) {
                
                if let data = try? Data(contentsOf: url) {
                    
                     single(.success(data))
                    
                }

                }
            }
            
            return Disposables.create()
        }
    }
}

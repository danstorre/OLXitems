//
//  ItemsSearchViewModel.swift
//  olxItems
//
//  Created by Daniel Torres on 6/25/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct ItemsSearchViewModel {

    
    let disposeBag = DisposeBag()
    var driverItems : Driver<[Item]> {
        return self.driverItems.asDriver()
    }
    
    
    func getItems(itemName: String) -> Observable<[Item]> {
        return Observable<[Item]>.create { observer in
            
            ItemsManager.shared.getItems(item: itemName, completionHandlerForGettingItems: { (success, items, erroString) in
                if success {
                    observer.on(.next(items!))
                }
            })
            
            return Disposables.create()
        }
    }
    
}

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
    
    typealias DriverSearchBarText = Driver<String?>
    
    let itemFromSearchDriver : Driver<[Item]>
    let isSearching : Bool = false
    
    
    init(driverSearchBar: DriverSearchBarText){
    
        itemFromSearchDriver = driverSearchBar.throttle(0.3)
            .distinctUntilChanged { (first, second) -> Bool in
                return (first == second)
            }
            .flatMapLatest { (query) -> SharedSequence<DriverSharingStrategy, [Item]> in
                
                if query == "" {
                    return Driver.just([Item]())
                }
                return ItemsSearchViewModel.getItems(itemName: query!).asDriver(onErrorJustReturn: [Item]())
        }
        
        
        
    }
    
    static func getItems(itemName: String) -> Observable<[Item]> {
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

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

class ItemsSearchViewModel {

    
    let disposeBag = DisposeBag()
    
    // alias of drivers that this view model can receive
    typealias DriverSearchBarText = Driver<String?>
    
    // MARK: RxSwift Observers
    
    let itemFromSearchDriver : Driver<[Item]>
    let lastSearchFromBar : BehaviorSubject<[Item]> = BehaviorSubject(value: [Item]())
    
    var isSearching : Driver<Bool> {
        return isSearchingVar.asDriver()
    }
    
    var items: Driver<[Item]> {
        return itemsVar.asDriver()
    }
    
    var lastQuerySearched : String = ""
    var pagination: Int = 0
    var searchingPagination: Bool = false
    
    
    // MARK: RxSwift vars
    var isSearchingVar = Variable<Bool>(false)
    var itemsVar = Variable<[Item]>([Item]())
    

    // MARK: init methods
    init(driverSearchBar: DriverSearchBarText){
        
        itemFromSearchDriver = driverSearchBar.throttle(0.3)
            .distinctUntilChanged { (first, second) -> Bool in
                return (first == second)
            }
            .flatMapLatest { (query) -> SharedSequence<DriverSharingStrategy, [Item]> in
                
                
                guard let query = query, query != "" else {
                    return Driver.just([Item]())
                }
                let queryTrimmed = query.trimmingCharacters(in: [" "])
                guard queryTrimmed != "" else {
                    return Driver.just([Item]())
                }
                
                return ItemsSearchViewModel.getItems(itemName: query).asDriver(onErrorJustReturn: [Item]())
            }
        
    }
    
    // MARK: init methods
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
    
    func getMoreItems(){
        
        
        if !searchingPagination{
            self.pagination += 1
            self.searchingPagination = true
            ItemsManager.shared.getItems(item: self.lastQuerySearched, offset: pagination, completionHandlerForGettingItems: { (success, items, erroString) in
                
                DispatchQueue.main.async {
                    if success && self.searchingPagination {
                        self.itemsVar.value += items!
                        self.searchingPagination = false
                    }
                }
                
            })
        }
        
        
    }
    
    func retrieveImage(from urlString: String, to index: Int) {
        
        if let url = URL(string: urlString) {
            
            if let data = try? Data(contentsOf: url) {
                
                DispatchQueue.main.async {
                    
                    if index < self.itemsVar.value.count {
                        self.itemsVar.value[index].thumbnail = data
                    }
                    
                }
            }
        }
        
    }
    
}

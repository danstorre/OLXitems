//
//  ViewController.swift
//  olxItems
//
//  Created by Daniel Torres on 6/24/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ItemsSearchViewController: UIViewController {

    @IBOutlet weak var searchItemBar: UISearchBar!
    @IBOutlet weak var tableItemsView: UITableView!
    
    var viewModel : ItemsSearchViewModel?
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ItemsSearchViewModel()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let searchDriver = searchItemBar.rx.text.asDriver().throttle(0.3)
            .distinctUntilChanged { (first, second) -> Bool in
                return first != second
            }
            .flatMapLatest { (query) -> SharedSequence<DriverSharingStrategy, [Item]> in
                return self.viewModel!.getItems(itemName: query!).asDriver(onErrorJustReturn: [Item]())
        }
        
        
        searchDriver.drive(tableItemsView.rx.items(cellIdentifier: "Cell")) { (_, item, cell) in
            cell.textLabel?.text = item.title
            }.disposed(by: disposeBag)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureViewModel(){
    
        
    }


}

extension ItemsSearchViewController : UITableViewDelegate {


}

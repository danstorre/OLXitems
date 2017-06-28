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
    
    @IBOutlet weak var topActivity: UIActivityIndicatorView!
    @IBOutlet weak var lowActivity: UIActivityIndicatorView!
    
    var viewModel : ItemsSearchViewModel?
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ItemsSearchViewModel(driverSearchBar: searchItemBar.rx.text.asDriver())
        topActivity.stopAnimating()
        lowActivity.stopAnimating()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        viewModel?.itemFromSearchDriver.skip(1).drive(tableItemsView.rx.items(cellIdentifier: "Cell")) { (index, item, cell) in
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

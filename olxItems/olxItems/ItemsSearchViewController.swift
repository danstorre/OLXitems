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
        tableItemsView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        /* this is commented out to just have a small peek about how rx cocoa can help us out
        viewModel?.itemFromSearchDriver.skip(1).drive(tableItemsView.rx.items(cellIdentifier: "Cell")) { (index, item, cell) in
            cell.textLabel?.text = item.title
            }.disposed(by: disposeBag)*/
        
        guard let viewModel = viewModel else {
            return
        }
        
        //Does stuff whenever an http response came
        let _ = viewModel.itemFromSearchDriver.skip(1).drive( onNext: { [weak self] (newItems) in
            
            guard let `self` = self else { return }
            guard let viewModel = self.viewModel else { return }
            viewModel.itemsVar.value = newItems
            self.tableItemsView.reloadData()
            viewModel.isSearchingVar.value = false
        }, onCompleted: nil,
        onDisposed: {
            print("disposed itemFromSearchDriver")
        })
        
        //Does stuff whenever search bar changes it's text
        searchItemBar.rx.text.asDriver().skip(1).drive(onNext: { [weak self] (query) in
            guard let `self` = self else { return }
            guard let viewModel = self.viewModel else { return }
            viewModel.isSearchingVar.value =  query == "" ? false : true
            
            }, onCompleted: nil, onDisposed: {
                print("disposed itemFromSearchDriver")
        })
        
        //Does stuff whenever the app is searching for new items.
        viewModel.isSearching.asDriver().skip(1).drive(onNext: { [weak self] (isSearching) in
            guard let `self` = self else { return }
            
            if isSearching {
                viewModel.itemsVar.value = [Item]()
                viewModel.itemsVar.value.append(Item())
                self.tableItemsView.reloadData()
            }
            
        }, onCompleted: nil, onDisposed: nil)
        
        viewModel.items.asDriver().skip(1).drive(onNext: {[weak self] (item) in
            guard let `self` = self else { return }
            guard let viewModel = self.viewModel else { return }
            
            
            self.tableItemsView.reloadData()
            
        }, onCompleted: { 
            
        }, onDisposed: nil)
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureViewModel(){
    
        
    }


}

extension ItemsSearchViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let viewModel = viewModel else {
            return 0
        }
        
        return viewModel.itemsVar.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let viewModel = viewModel else {
            return UITableViewCell()
        }
        
        let item = viewModel.itemsVar.value[indexPath.row]

        guard let itemTitle = item.title, itemTitle != "" else {
            let searchingCell = tableView.dequeueReusableCell(withIdentifier: "Searching", for: indexPath) as! SearchingTableViewCell
            searchingCell.activity.startAnimating()
            searchingCell.message.text = "Searching"
            return searchingCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemTableViewCell
        
        cell.itemTitle.text = itemTitle
        
        if let imageThumnail = item.thumbnail {
            cell.activity.stopAnimating()
            cell.thumbNail.image = UIImage(data: imageThumnail)
            
        }else {
            cell.thumbNail.image = UIImage()
            
            DispatchQueue.global().async {
                if let urlStringThumbnail = item.thumbnailURL {
                    cell.activity.startAnimating()
                    viewModel.retrieveImage(from: urlStringThumbnail, to: indexPath.row)
                }
            }
            
        }
        
        return cell
    }
    
    
}

extension ItemsSearchViewController : UITableViewDelegate {


}

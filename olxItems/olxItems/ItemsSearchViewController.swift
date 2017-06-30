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
    
    var refreshControl: UIRefreshControl!
    var viewModel : ItemsSearchViewModel?
    let disposeBag = DisposeBag()
    var selectedItem : Item? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ItemsSearchViewModel(driverSearchBar: searchItemBar.rx.text.asDriver())
        
        tableItemsView.tableFooterView = UIView()
        refreshControl = UIRefreshControl()
        tableItemsView.addSubview(refreshControl)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
      
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
        
        guard let viewModel = viewModel else {
            return
        }
        
        
        //Here is where we configure our observers
        
        //Just saves the first request of items from search
        let _ = viewModel.itemFromSearchDriver.skip(1).drive(viewModel.lastSearchFromBar)
        
        //Does stuff whenever a new http response comes
        let _ = viewModel.itemFromSearchDriver.skip(1).drive( onNext: { [weak self] (newItems) in
            
            guard let `self` = self else { return }
            guard let viewModel = self.viewModel else { return }
            viewModel.itemsVar.value = newItems
            viewModel.pagination = 0
            viewModel.searchingPagination = false
        
            self.tableItemsView.reloadData()
            self.refreshControl.endRefreshing()
            viewModel.isSearchingVar.value = false
        }, onCompleted: nil,
        onDisposed: {
            print("disposed itemFromSearchDriver")
        })
        
        //Does stuff whenever search bar changes it's text
        searchItemBar.rx.text.asDriver().skip(1).drive(onNext: { [weak self] (query) in
            guard let `self` = self else { return }
            guard let viewModel = self.viewModel else { return }
            
            let queryTrimmed = query!.trimmingCharacters(in: [" "])
            viewModel.isSearchingVar.value =  queryTrimmed == "" ? false : true
            viewModel.lastQuerySearched = queryTrimmed
            
            if queryTrimmed == "" {
                viewModel.itemsVar.value = [Item]()
                viewModel.pagination = 0
                viewModel.searchingPagination = false
                viewModel.isSearchingVar.value = false
                self.tableItemsView.reloadData()
                self.refreshControl.endRefreshing()
            }
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
        
        //Does stuff whenever items are updated
        viewModel.items.asDriver().skip(1).drive(onNext: {[weak self] (item) in
            guard let `self` = self else { return }
            
            self.tableItemsView.reloadData()
            
        }, onCompleted: { 
            
        }, onDisposed: nil)
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

//MARK: Navigation
extension ItemsSearchViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detailItem" {
        
            let detailItemVC = segue.destination as! DetailItemViewController
            detailItemVC.item = selectedItem
            
        }
    }
}


//MARK: Table View methods
extension ItemsSearchViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let viewModel = viewModel else {
            return 0
        }
        
        return  (viewModel.lastQuerySearched != "" && viewModel.itemsVar.value.count != 0) ? viewModel.itemsVar.value.count + 1 : viewModel.itemsVar.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let viewModel = viewModel else {
            return UITableViewCell()
        }
        
        //do the pagination if it is the last row
        guard  (indexPath.row < viewModel.itemsVar.value.count), viewModel.lastQuerySearched != "" else {
            let searchingCell = tableView.dequeueReusableCell(withIdentifier: "pagination", for: indexPath) as! PaginationTableViewCell
            
            searchingCell.activity.startAnimating()
            
            DispatchQueue.global().async {
                viewModel.getMoreItems()
            }
            return searchingCell
        }
        
        let item = viewModel.itemsVar.value[indexPath.row]

        //do the pagination if it is the last row
        guard let itemTitle = item.title, itemTitle != "" else {
            let searchingCell = tableView.dequeueReusableCell(withIdentifier: "Searching", for: indexPath) as! SearchingTableViewCell
            searchingCell.activity.startAnimating()
            searchingCell.message.text = "Searching for \(viewModel.lastQuerySearched)"
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            
            guard let viewModel = viewModel, let lastItems = try? viewModel.lastSearchFromBar.value() else {
                return
            }
            
            viewModel.itemsVar.value = lastItems
            self.tableItemsView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewModel = viewModel else {
            return
        }
        
        //do the pagination if it is the last row
        guard  indexPath.row < viewModel.itemsVar.value.count else {
            return
        }
        
        selectedItem = viewModel.itemsVar.value[indexPath.row]
        
        self.performSegue(withIdentifier: "detailItem", sender: nil)
        
        
        
    }
    
    
}

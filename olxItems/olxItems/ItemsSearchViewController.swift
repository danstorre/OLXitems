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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var reachability: Reachability? = Reachability.networkReachabilityForInternetConnection()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reachability?.stopNotifier()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewModel = ItemsSearchViewModel(driverSearchBar: searchItemBar.rx.text.asDriver())
        
        tableItemsView.tableFooterView = UIView()
        refreshControl = UIRefreshControl()
        tableItemsView.addSubview(refreshControl)
        searchItemBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: NSNotification.Name(rawValue: ReachabilityDidChangeNotificationName), object: nil)
        
        _ = reachability?.startNotifier()
        
    }
      
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        checkReachability()
        
        guard let viewModel = viewModel else {
            return
        }
        
        
        //Here is where we configure our observers
        
        //Just saves the first request of items from search for the refresh
        let _ = viewModel.itemFromSearchDriver.skip(1).drive(viewModel.lastSearchFromBar)
        
        //Does stuff whenever a new http response comes
        let _ = viewModel.itemFromSearchDriver.skip(1).drive( onNext: { [weak self] (newItems) in
            
            guard let `self` = self else { return }
            guard let viewModel = self.viewModel else { return }
            viewModel.itemsVar.value = newItems
            viewModel.pagination = 0
            viewModel.searchingPagination = false
            viewModel.isSearchingVar.value = false
            self.tableItemsView.reloadData()
            self.refreshControl.endRefreshing()
            
        }, onCompleted: nil,
        onDisposed: {
            print("disposed itemFromSearchDriver")
        })
        
        //Does stuff whenever search bar changes it's text
        let _ = searchItemBar.rx.text.asDriver().skip(1).drive(onNext: { [weak self] (query) in
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
        let _ = viewModel.isSearching.asDriver().skip(1).drive(onNext: { [weak self] (isSearching) in
            guard let `self` = self else { return }
            
            if isSearching {
                viewModel.itemsVar.value = [Item]()
                viewModel.itemsVar.value.append(Item())
                self.tableItemsView.reloadData()
            }
            
        }, onCompleted: nil, onDisposed: nil)
        
        //Does stuff whenever items are updated
        let _ = viewModel.items.asDriver().skip(1).asDriver(onErrorJustReturn: [Item]()).throttle(2.5).drive(onNext: {[weak self] (item) in
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

        //do the searchcell
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
            cell.activity.startAnimating()
            
            if let image = lookImageForItem(for: item, with: indexPath) {
                cell.thumbNail.image = image
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


extension ItemsSearchViewController {
    
    // MARK:- helper Methods
    
    func lookImageForItem(for item: Item, with indexPath: IndexPath) -> UIImage?{
        if  let idItem = item.id,
            let urlThumnail = item.thumbnailURL,
            let data: Data = appDelegate.customCache!.object(forKey: "\(idItem)+\(urlThumnail)") {
            return UIImage(data: data)
        }else {
            if let urlStringThumbnail = item.thumbnailURL {
                viewModel?.retrieveImage(from: urlStringThumbnail, to: indexPath.row)
            }
        }
        
        return nil
    }
    
    
    // MARK:- Reachabilty Methods
    
    func reachabilityDidChange(_ notification: Notification) {
        checkReachability()
    }
    
    func checkReachability() {
        guard let r = reachability else { return }
        guard r.isReachable else {
            DispatchQueue.main.async {
                let rootViewController : UIViewController? = UIApplication.shared.keyWindow?.rootViewController
                
                
                guard let presentedViewController = rootViewController?.presentedViewController else {
                    return rootViewController!.displayAlert("Check Your Internet Connection", completionHandler: {})
                }
                
                presentedViewController.displayAlert("Check Your Internet Connection", completionHandler: {})
                
                
            }
            return
        }
    }
    
    
}

extension ItemsSearchViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        
        DispatchQueue.main.async {
            if searchBar.isFirstResponder {
                searchBar.resignFirstResponder()
            }
        } 
        
    }
    
}

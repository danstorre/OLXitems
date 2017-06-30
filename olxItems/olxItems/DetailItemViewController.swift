//
//  DetailItemViewController.swift
//  olxItems
//
//  Created by Daniel Torres on 6/29/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import UIKit

class DetailItemViewController: UIViewController {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var available: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var item : Item?
    var viewModel : ItemDetailViewModel?
    
    
    //let disposeBag = Disposebag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        
        viewModel?.imageItemDriver?.asDriver(onErrorJustReturn: Data()).drive(onNext: { [weak self] (dataImage) in
            
            guard let `self` = self else {return }
            self.activity.stopAnimating()
            self.itemImageView.image = UIImage(data: dataImage!)
            
        }, onCompleted: nil, onDisposed: nil)
        
    }

}

// MARK: - DetailItemViewController Methods

extension DetailItemViewController {

    func configureView(){
        self.navigationController?.navigationBar.isHidden = false
        activity.startAnimating()
        guard let item = item else {
            return
        }
        
        viewModel = ItemDetailViewModel(string: item.fullImageURL ?? "")
        
        titleLabel.text = item.title
        available.text = item.textForSold
        priceLabel.text = item.price?.displayValue ?? "Not Availabel"
        descriptionLabel.text = item.description 
        
    }
}

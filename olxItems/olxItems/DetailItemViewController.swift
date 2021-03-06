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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        
        if  let item = item,
            let idItem = item.id,
            let fullImageURL = item.fullImageURL,
            let dataImage: Data = appDelegate.customCache!.object(forKey: "\(idItem)+\(fullImageURL)") {
            
            itemImageView.image = UIImage(data: dataImage)
        }
        else {
            let _ = viewModel?.imageItemDriver?.asDriver(onErrorJustReturn: Data()).drive(onNext: { [weak self] (dataImage) in
                
                guard let `self` = self else {return }
                guard let dataImage = dataImage else {return }
                
                self.activity.stopAnimating()
                self.itemImageView.image = UIImage(data: dataImage)
                
                try? self.appDelegate.customCache!.addObject(dataImage, forKey: "\(self.item!.id!)+\(self.item!.fullImageURL!)")
                
                }, onCompleted: nil, onDisposed: nil)
        }
       
        
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
        
        guard let imageThumnail = item.thumbnail else {
            return
        }
        
        try? self.appDelegate.customCache!.addObject(imageThumnail, forKey: "\(self.item!.id!)+\(self.item!.thumbnailURL!)")
        
        
    }
}

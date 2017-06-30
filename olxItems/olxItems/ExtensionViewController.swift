//
//  ExtensionViewController.swift
//  olxItems
//
//  Created by Daniel Torres on 6/30/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayAlert(_ errorString: String, completionHandler: @escaping (() -> Void)) {
        
        let alertViewController = UIAlertController(title: "Alert!", message: errorString, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertViewController.addAction(okButton)
        
        self.present(alertViewController, animated: true, completion: completionHandler )
    }
    
    func displayMessage(_ title: String, _ messageString: String, completionHandler: @escaping (() -> Void)) {
        
        let alertViewController = UIAlertController(title: title, message: messageString, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertViewController.addAction(okButton)
        
        self.present(alertViewController, animated: true, completion: completionHandler )
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

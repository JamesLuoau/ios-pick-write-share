//
//  MemeDetailViewController.swift
//  Meme
//
//  Created by James Luo on 31/8/17.
//  Copyright © 2017 James Luo. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    var meme: Meme!

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        self.imageView!.image = meme.memedImage
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
    }
    
}

extension MemeDetailViewController {
    
    class func showMeme(meme: Meme, parentNavigationController: UINavigationController) {
        let detailController = parentNavigationController.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = meme
        parentNavigationController.pushViewController(detailController, animated: true)
    }
    
}

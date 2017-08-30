//
//  CollectionViewController.swift
//  Meme
//
//  Created by James Luo on 29/8/17.
//  Copyright © 2017 James Luo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MemeCollectionViewCell"

class CollectionViewController: UICollectionViewController {

    @IBOutlet weak var viewFlowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        viewFlowLayout.minimumInteritemSpacing = space
        viewFlowLayout.minimumLineSpacing = space
        viewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        memes = Meme.sharedMemes()
        self.collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
    
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        cell.memImageView?.image = meme.memedImage
        
        return cell
    }
    
    @IBAction func newMeme(_ sender: Any) {
        editMeme(meme: Meme())
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        editMeme(meme: self.memes[(indexPath as NSIndexPath).row])
    }
    
    private func editMeme(meme: Meme) {
        MemeEditViewController.editMeme(meme: meme, parentNavigationController: self.navigationController!)
    }

}

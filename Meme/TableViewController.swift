//
//  TableViewController.swift
//  Meme
//
//  Created by James Luo on 27/8/17.
//  Copyright © 2017 James Luo. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var memes: [Meme] = []

    override func viewWillAppear(_ animated: Bool) {
        memes = Meme.sharedMemes()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell")!
        let meme = memes[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = meme.description()
        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editMeme(meme: self.memes[(indexPath as NSIndexPath).row])
    }
    
    @IBAction func newMeme(_ sender: Any) {
        editMeme(meme: Meme())
    }
    
    private func editMeme(meme: Meme) {
        MemeEditViewController.editMeme(meme: meme, parentNavigationController: self.navigationController!)
    }
    
}

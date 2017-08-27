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
        
        cell.textLabel?.text = meme.topText + " " + meme.bottomText
        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

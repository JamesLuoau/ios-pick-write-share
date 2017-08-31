//
//  Meme.swift
//  Meme
//
//  Created by James Luo on 26/8/17.
//  Copyright © 2017 James Luo. All rights reserved.
//

import Foundation
import UIKit


struct Meme {
    var isNew: Bool = true
    var topText: String = TOP_TEXT_DEFAULT
    var bottomText: String = BOTTOM_TEXT_DEFAULT
    var originalImage: UIImage? = nil
    var memedImage: UIImage? = nil
    
    func description() -> String {
        return topText + "..." + bottomText
    }
}


extension Meme {
    
    static let TOP_TEXT_DEFAULT = "TOP"
    static let BOTTOM_TEXT_DEFAULT = "BOTTOM"

    static func sharedMemes() -> [Meme] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    static func addMeme(meme: Meme) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
}

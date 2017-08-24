//
//  TextFieldDelegate.swift
//  Meme
//
//  Created by James Luo on 22/8/17.
//  Copyright © 2017 James Luo. All rights reserved.
//

import Foundation
import UIKit

class MemoTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        return newText.length <= 5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}

//
//  ViewController.swift
//  Meme
//
//  Created by James Luo on 22/8/17.
//  Copyright © 2017 James Luo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topMemoTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var memeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func canel(_ sender: UIBarButtonItem) {
        imageView.image = nil
        shareButton.isEnabled = false
        resetTextField()
    }
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        enum ImageSourceType: Int {
            case fromCamera = 0
            case fromLibrary = 1
            
            func toUIImagePickerControllerSourceType() -> UIImagePickerControllerSourceType {
                switch self {
                case .fromCamera:
                    return UIImagePickerControllerSourceType.camera
                case .fromLibrary:
                    return UIImagePickerControllerSourceType.photoLibrary
                }
            }
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = ImageSourceType(rawValue: sender.tag)!.toUIImagePickerControllerSourceType()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: {
            () -> Void in
                self.shareButton.isEnabled = true
        })
    }
    
    func generateMemedImage() -> UIImage {
        UIGraphicsBeginImageContext(self.memeView.frame.size)
        memeView.drawHierarchy(in: CGRect(origin: CGPoint(x: 0, y: 0), size: self.memeView.frame.size), afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: self.topMemoTextField.text!, bottomText: self.bottomTextField.text!, originalImage: self.imageView.image!, memedImage: self.generateMemedImage())
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
        resignFirstResponderIfTextFieldsHasFocus()
        
        let activityViewController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            (_,successful,_,_) in
            if successful{
                let meme = Meme(topText: self.topMemoTextField.text!, bottomText: self.bottomTextField.text!, originalImage: self.imageView.image!, memedImage: self.generateMemedImage())
                
                Meme.addMeme(meme: meme)
                self.dismiss(animated: true, completion: nil)
            }
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            present(activityViewController, animated: true, completion: nil)
        }else{
            let popover = activityViewController.popoverPresentationController
            if (popover != nil){
                popover?.barButtonItem = shareButton
                popover?.permittedArrowDirections = UIPopoverArrowDirection.any
                present(activityViewController, animated: true, completion: nil)
            }
        }
        
    }
    
    private func setupUIStatus() {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -4.0]
        
        for textField in [topMemoTextField, bottomTextField] {
            textField!.defaultTextAttributes = memeTextAttributes
            textField!.textAlignment = .center
            textField!.delegate = self
        }
        
        resetTextField()
        
        shareButton.isEnabled = false
    }
    
    let TOP_TEXT_FIELD_TEXT = "TOP"
    let BOTTOM_TEXT_FIELD_TEXT = "BOTTOM"
    private func resetTextField() {
        topMemoTextField.text = TOP_TEXT_FIELD_TEXT
        bottomTextField.text = BOTTOM_TEXT_FIELD_TEXT
    }
    
    private func resignFirstResponderIfTextFieldsHasFocus() {
        if topMemoTextField.isFirstResponder {
            topMemoTextField.resignFirstResponder()
        }
        if bottomTextField.isFirstResponder {
            bottomTextField.resignFirstResponder()
        }
    }
}

// MARK: UITextFieldDelegate

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == TOP_TEXT_FIELD_TEXT || textField.text == BOTTOM_TEXT_FIELD_TEXT {
            textField.text = ""
        }
    }
    
}

// MARK: Keyboard Functions

extension ViewController {
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}

// MARK: UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }

}


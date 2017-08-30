//
//  ViewController.swift
//  Meme
//
//  Created by James Luo on 22/8/17.
//  Copyright © 2017 James Luo. All rights reserved.
//

import UIKit

class MemeEditViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topMemoTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var memeView: UIView!
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tabBarController?.tabBar.isHidden = true
//        self.navigationController?.isToolbarHidden = true
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
        
        loadFromMeme(meme: meme)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
//        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func canel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
        present(imagePicker, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        UIGraphicsBeginImageContext(self.memeView.frame.size)
        memeView.drawHierarchy(in: CGRect(origin: CGPoint(x: 0, y: 0), size: self.memeView.frame.size), afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func save() {
        self.meme.topText = self.topMemoTextField.text!
        self.meme.bottomText = self.bottomTextField.text!
        self.meme.originalImage = self.imageView.image!
        self.meme.memedImage = self.generateMemedImage()
        
        if self.meme.isNew {
            self.meme.isNew = false
            Meme.addMeme(meme: meme)
        }
    }
    
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
        resignFirstResponderIfTextFieldsHasFocus()
        
        let activityViewController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            (_,successful,_,_) in
            if successful{
                self.save()
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
        updateShareButtonStatus()
    }
    
    func updateShareButtonStatus() {
        shareButton.isEnabled = self.meme.originalImage != nil
    }
    
    private func loadFromMeme(meme: Meme) {
        topMemoTextField.text = meme.topText
        bottomTextField.text = meme.bottomText
        imageView.image = meme.originalImage
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

extension MemeEditViewController {

    class func editMeme(meme: Meme, parentNavigationController: UINavigationController) {
        let navigationController = parentNavigationController.storyboard!.instantiateViewController(withIdentifier: "MemeEditNavigationController") as! UINavigationController
        let detailController = navigationController.viewControllers[0] as! MemeEditViewController
        detailController.meme = meme
        parentNavigationController.present(navigationController, animated: true, completion: nil)
    }
    
}

// MARK: UITextFieldDelegate

extension MemeEditViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == Meme.TOP_TEXT_DEFAULT || textField.text == Meme.BOTTOM_TEXT_DEFAULT {
            textField.text = ""
        }
    }
    
}

// MARK: Keyboard Functions

extension MemeEditViewController {
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

extension MemeEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.meme.originalImage = image
            self.updateShareButtonStatus()
        }
        
        dismiss(animated: true, completion: nil)
    }

}


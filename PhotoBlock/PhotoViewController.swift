//
//  PhotoViewController.swift
//  PhotoBlock
//
//  Created by Shreyas Thiagaraj on 9/24/19.
//  Copyright © 2019 Shreyas Thiagaraj. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import UIKit
import Blockstack

fileprivate let filename = "photoFile"

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingView.isHidden = false
        Blockstack.shared.getFile(at: filename, decrypt: true) {
            decryptedContent, error in
            self.loadingView.isHidden = true
            guard error == nil else {
                let error = UIAlertController(title: "Oops!", message: "Something went wrong. Check your internet connection and try again.", preferredStyle: .alert)
                error.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(error, animated: true, completion: nil)
                return
            }
            guard let bytes = (decryptedContent as? DecryptedValue)?.bytes else {
                let alert = UIAlertController(title: nil, message: "Nothing found. Try uploading something!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let image = UIImage(data: Data(bytes))
            self.imageView.image = image
        }
    }
    
    @IBAction func photoActionTapped(_ sender: Any) {
        if self.image == nil {
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        } else {
            self.imageView.image = nil
            self.uploadPhotoButton.setTitle("+ upload photo", for: .normal)
            self.image = nil
        }
    }
    
    // MARK: - UIImagePickerViewControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let loading = UIAlertController(title: "Encrypting & Uploading...", message: nil, preferredStyle: .alert)
        self.present(loading, animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }

        self.image = image
        let data = image.jpegData(compressionQuality: 1)!.bytes
        
        // Upload file to Gaia storage
        Blockstack.shared.putFile(
            to: filename,
            bytes: data,
            encrypt: true) { gaiaUrl, error in
                guard error == nil else {
                    // Handle error
                    let alert = UIAlertController(title: "Oops!", message: "Something went wrong during upload. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                // Success
                print(gaiaUrl ?? "")
                DispatchQueue.main.async {
                    loading.dismiss(animated: true, completion: nil)
                    self.imageView.image = image
                    self.uploadPhotoButton.setTitle("- delete photo", for: .normal)
                }
        }
    }
    
    private var image: UIImage?
    private let imagePicker = UIImagePickerController()
}

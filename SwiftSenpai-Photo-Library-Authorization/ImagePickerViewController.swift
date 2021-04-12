//
//  ImagePickerViewController.swift
//  SwiftSenpai-Photo-Library-Authorization
//
//  Created by Kah Seng Lee on 08/04/2021.
//

import UIKit
import PhotosUI

class ImagePickerViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var manageButton: UIButton!
    @IBOutlet weak var seeAllButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe photo library changes
        PHPhotoLibrary.shared().register(self)
        
        // Request permission to access photo library
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            DispatchQueue.main.async { [unowned self] in
                showUI(for: status)
            }
        }
    }

    @IBAction func manageButtonTapped(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "",
                                            message: "Select more photos or go to Settings to allow access to all photos.",
                                            preferredStyle: .actionSheet)
        
        let selectPhotosAction = UIAlertAction(title: "Select more photos",
                                               style: .default) { [unowned self] (_) in
            // Show limited library picker
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: "Allow access to all photos",
                                                  style: .default) { [unowned self] (_) in
            // Open app privacy settings
            gotoAppPrivacySettings()
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }

    @IBAction func seeAllButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Allow access to your photos",
                                      message: "This lets you share from your camera roll and enables other features for photos and videos. Go to your settings and tap \"Photos\".",
                                      preferredStyle: .alert)
        
        let notNowAction = UIAlertAction(title: "Not Now",
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(notNowAction)
        
        let openSettingsAction = UIAlertAction(title: "Open Settings",
                                               style: .default) { [unowned self] (_) in
            // Open app privacy settings
            gotoAppPrivacySettings()
        }
        alert.addAction(openSettingsAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension ImagePickerViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [unowned self] in
            // Obtain authorization status and update UI accordingly
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            showUI(for: status)
        }
    }
}

private extension ImagePickerViewController {
    
    func showUI(for status: PHAuthorizationStatus) {
        
        switch status {
        case .authorized:
            showFullAccessUI()

        case .limited:
            showLimittedAccessUI()

        case .restricted:
            showRestrictedAccessUI()

        case .denied:
            showAccessDeniedUI()

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }
    
    func showFullAccessUI() {
        manageButton.isHidden = true
        seeAllButton.isHidden = true
        
        let photoCount = PHAsset.fetchAssets(with: nil).count
        infoLabel.text = "Status: authorized\nPhotos: \(photoCount)"
    }
    
    func showLimittedAccessUI() {
        manageButton.isHidden = false
        seeAllButton.isHidden = true
        
        let photoCount = PHAsset.fetchAssets(with: nil).count
        infoLabel.text = "Status: limited\nPhotos: \(photoCount)"
    }
    
    func showRestrictedAccessUI() {
        manageButton.isHidden = true
        seeAllButton.isHidden = true
        
        infoLabel.text = "Status: restricted"
    }
    
    func showAccessDeniedUI() {
        manageButton.isHidden = true
        seeAllButton.isHidden = false
        
        infoLabel.text = "Status: denied"
    }
    
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


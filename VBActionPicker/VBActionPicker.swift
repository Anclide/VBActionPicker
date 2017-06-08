//
//  VBActionPicker.swift
//  VBActionPicker
//
//  Created by Victor Bogatyrev on 26.04.17.
//  Copyright © 2017 Victor Bogatyrev. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import ContactsUI
import MapKit

protocol VBActionPickerDelegate {
    func picker(_ picker: VBActionPicker, didFinishPickingMediaWithResult result:[String:Any])
}

let yOffset = 60

class VBActionPicker: NSObject {
    
    enum VBActionPickerStyle {
        case `default`
        case topPhotoLibrary
        case collection
        case custom
    }
    
    enum VBActionPickerObjectStyle {
        case imageBeforeLabel
        case imageAfterLabel
        case onlyLabel
    }
    
    
    var delegate: VBActionPickerDelegate?
    var customView: UIView?
    
    fileprivate var actionSheet: UIAlertController!
    fileprivate var style: VBActionPickerStyle = .default
    fileprivate var objectStyle: VBActionPickerObjectStyle = .onlyLabel
    
    
    var tintColor: UIColor = UIColor.white {
        didSet {
            if style != .default {
                actionSheet.view.tintColor = self.tintColor
            }
        }
    }
    
    var backgroundColor: UIColor = UIColor.white {
        didSet {
            if style != .default {
                actionSheet.view.backgroundColor = self.backgroundColor
            }
        }
    }
    
    
    dynamic fileprivate var result: [String:Any] = [:]
    
    override init() {
        super.init()
        let view = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet = view
        self.addObserver(self, forKeyPath: #keyPath(result), options: [.old, .new], context: nil)
        

    }
    
    func configure(with pickerStyle: VBActionPickerStyle, objectStyles: VBActionPickerObjectStyle, objects: Array<VBActionPickerObject>) {
        
        self.style = pickerStyle
        self.objectStyle = objectStyles
        
        switch self.style {
        case .topPhotoLibrary:
            self.addPhotoLibrary()
            self.addActions(actions: objects)
        case .custom:
            self.drawCustomView(actions: objects)
        default:
            actionSheet.title = nil
            self.addActions(actions: objects)
        }
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
    }
    
    fileprivate func drawCustomView(actions: Array<VBActionPickerObject>) {
        customView = UIView(frame: CGRect(x: -10, y: 0, width: 375, height: (actions.count + 1) * yOffset))
        customView?.backgroundColor = backgroundColor
        //var titleString = "\n"
        var offsetY = 0
        for action in actions {
            let button = UIButton(frame: CGRect(x: 0, y: offsetY, width: 375, height: yOffset))
            button.setTitle(action.title, for: .normal)
            if objectStyle != .onlyLabel {
                button.setImage(action.image, for: .normal)
            }
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            button.setTitleColor(UIColor.white, for: .normal)
            button.tintColor = tintColor
            button.backgroundColor = UIColor.clear
            customView?.addSubview(button)
            button.actionHandle(controlEvents: .touchUpInside, ForAction: self.addAction(withType: action.type)!)
            offsetY += yOffset
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        let button = UIButton(frame: CGRect(x: 0, y: offsetY, width: 375, height: yOffset))
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.tintColor = tintColor
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        customView?.addSubview(button)
        //actionSheet.title = titleString
        let height:NSLayoutConstraint = NSLayoutConstraint(item: actionSheet.view,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1,
                                                           constant: customView!.frame.height - 10)
        actionSheet.view.addConstraint(height);
        actionSheet.view.addSubview(customView!)
        
    }
    
    @objc fileprivate func dismiss() {
        actionSheet.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func addActions(actions: Array<VBActionPickerObject>) {
        for object in actions {
            let action = UIAlertAction(title: object.title, style: .default, handler: object.customAction ?? self.addAction(withType: object.type))
            action.setValue(object.image, forKey: "image")
            actionSheet.addAction(action)
        }
    }
    
    
    fileprivate func addPhotoLibrary() {
        actionSheet.title = "\n\n\n\n\n\n"
        let margin:CGFloat = 10.0
        let rect = CGRect(x: margin, y: margin, width: actionSheet.view.bounds.size.width - margin * 4.0, height: 120)
        //let customView = UIView(frame: rect)
        
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 120, height: 120)
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame:rect, collectionViewLayout: flowLayout)
        
        let collectionController = VBAssetsCollectionViewController()
        //collectionController.collectionView = collectionView
        collectionView.delegate = collectionController
        collectionView.dataSource = collectionController
        
        //actionSheet.view.addSubview(collectionView)
    }
    
    
    func show() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if rootViewController is UINavigationController {
            (rootViewController as? UINavigationController)?.topViewController?.present(actionSheet, animated: true, completion: nil)
        } else if rootViewController is UITabBarController {
            (rootViewController as? UITabBarController)?.selectedViewController?.present(actionSheet, animated: true, completion: nil)
        } else {
            rootViewController?.present(self.actionSheet, animated: true, completion: nil)
        }
    }
    
    fileprivate func addAction(withType: VBActionPickerObjectActionType) -> ((UIAlertAction) -> Void)? {
        let action: ((UIAlertAction) -> Void)
        if withType == .camera {
            action = { (action: UIAlertAction) -> Void in
                
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePicker.sourceType = .camera
                    self.viewControllerToPresent().present(imagePicker, animated: true, completion: nil)
                }
            }
            return action
        } else if withType == .cameraRoll {
            action = { (action: UIAlertAction) -> Void in
                
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    imagePicker.sourceType = .photoLibrary
                    self.viewControllerToPresent().present(imagePicker, animated: true, completion: nil)
                }
            }
            return action
        } else if withType == .location {
            action = { (action: UIAlertAction) -> Void in
                let location = VBActionPickerLocationViewController()
                self.viewControllerToPresent().present(location, animated: true, completion: nil)
                
            }
            return action
        } else if withType == .contacts {
            action = { (action: UIAlertAction) -> Void in
                let contactPickerViewController = CNContactPickerViewController()
                
                contactPickerViewController.delegate = self
                
                self.viewControllerToPresent().present(contactPickerViewController, animated: true, completion: nil)
                
            }
            return action
        } else if withType == .file {
            action = { (action: UIAlertAction) -> Void in
                let docs = UIDocumentPickerViewController(documentTypes: ["public.data"], in: UIDocumentPickerMode.import)
                docs.delegate = self
                self.viewControllerToPresent().present(docs, animated: true, completion: nil)
                
            }
            return action
            
        } else {
            return nil
        }
        
    }
    
    fileprivate func viewControllerToPresent() -> UIViewController {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if rootViewController is UINavigationController {
            return ((rootViewController as? UINavigationController)?.topViewController)!
        } else if rootViewController is UITabBarController {
            return ((rootViewController as? UITabBarController)?.selectedViewController)!
        } else {
            return rootViewController!
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(result) {
            delegate?.picker(self, didFinishPickingMediaWithResult: result)
        }
    }
    
}

extension VBActionPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img = info[UIImagePickerControllerEditedImage] as! UIImage
        result["images"] = [img]
        picker.dismiss(animated: true, completion: nil)
    
    }
    
}

extension VBActionPicker: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        result["contacts"] = contacts
        picker.dismiss(animated: true, completion: nil)
    }
}

extension VBActionPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
//        url.startAccessingSecurityScopedResource()
//        
//        var data: Data? = nil
//        
//        let coordinator = NSFileCoordinator()
//        
//        var error: Error? = nil
//        coordinator.coordinate(readingItemAt: url, options: NSFileCoordinator.ReadingOptions(rawValue: 0), error: &error) { (newUrl) in
//            data = try! Data.init(contentsOf: newUrl)
//        }
//        
//        url.stopAccessingSecurityScopedResource()
//        result["document"] = data
    }
}

extension VBActionPicker: VBLocationPickerDelegate {
    func didSelectLocation(placemark: MKPlacemark) {
        result["location"] = placemark
    }
}

extension UIButton {
    private func actionHandleBlock(action:((UIAlertAction) -> Void)? = nil) {
        struct __ {
            static var action :((UIAlertAction) -> Void)?
        }
        if action != nil {
            __.action = action
        }
    }
    
    @objc private func triggerActionHandleBlock() {
        self.actionHandleBlock()
    }
    
    func actionHandle(controlEvents control :UIControlEvents, ForAction action:@escaping (UIAlertAction) -> Void) {
        self.actionHandleBlock(action: action)
        self.addTarget(self, action: #selector(UIButton.triggerActionHandleBlock), for: control)
    }
}



//
//  VBActionPickerObject.swift
//  VBActionPicker
//
//  Created by Victor Bogatyrev on 26.04.17.
//  Copyright © 2017 Victor Bogatyrev. All rights reserved.
//

import UIKit

public enum VBActionPickerObjectActionType {
    case custom
    case location
    case camera
    case cameraRoll
    case cameraAndPhotoLibrary
    case contacts
    case file
}

class VBActionPickerObject: NSObject {
    
    var title = ""
    var image: UIImage?
    var type: VBActionPickerObjectActionType! = .custom
    var customAction: ((UIAlertAction) -> Void)?
    
    
    init(withTitle title: String, image: UIImage?, type: VBActionPickerObjectActionType) {
        self.title = title
        self.image = image
        self.type = type
    }
    
    
    

}

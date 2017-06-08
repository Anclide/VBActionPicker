//
//  VBAsset.swift
//  VBActionPicker
//
//  Created by Victor Bogatyrev on 27.04.17.
//  Copyright © 2017 Victor Bogatyrev. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public protocol MediaProvider {
    func image() -> UIImage?
    func video() -> AVAsset?
}

/**
 Protocol representation of an asset.
 */
protocol VBAsset: MediaProvider {
    associatedtype AssetType
    var asset: AssetType { get }
}

/**
 Default implementations of MediaProviding protocol methods.
 */
extension VBAsset {
    public func image() -> UIImage? {
        var result: UIImage?
        
        if let image = asset as? UIImage {
            result = image
        } else if let avasset = asset as? AVAsset {
            let imageGenerator = AVAssetImageGenerator(asset: avasset)
            imageGenerator.appliesPreferredTrackTransform = true
            var time = avasset.duration
            time.value = min(time.value, 1)
            
            if let imageRef = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
                result = UIImage(cgImage: imageRef)
            }
        }
        
        return result
    }
    
    public func video() -> AVAsset? {
        var result: AVAsset?
        
        if let avasset = asset as? AVAsset {
            result = avasset
        }
        
        return result
    }
}

/**
 Conforming asset types.
 */
extension UIImage: VBAsset {
    internal var asset: UIImage {
        return self
    }
}
extension AVAsset: VBAsset {
    internal var asset: AVAsset {
        return self
    }
}

/**
 Type erasing wrapper around PPAsset.
 Covariance is not supported as of Swift 3.
 */
struct AnyVBAsset<AssetType>: VBAsset {
    let base: AssetType
    
    init<A : VBAsset>(_ base: A) where A.AssetType == AssetType {
        self.base = base.asset
    }
    
    internal var asset: AssetType {
        return base
    }
}

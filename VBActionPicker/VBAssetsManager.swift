//
//  VBAssetsmanager.swift
//  VBActionPicker
//
//  Created by Victor Bogatyrev on 27.04.17.
//  Copyright © 2017 Victor Bogatyrev. All rights reserved.
//

import Foundation
import Photos

struct VBAssetsManager {
    func getAssets(offset: Int, count: Int, imagesOnly: Bool, _ handler: @escaping ([MediaProvider]) -> ()) {
        guard authorizationStatus() == .authorized else {
            handler([])
            return
        }
        
        DispatchQueue.global(qos: offset == 0 ? .userInitiated : .default).async {
            let result: PHFetchResult<PHAsset>
            let options = self.getFetchOptions(offset, count)
            
            if imagesOnly {
                result = PHAsset.fetchAssets(with: .image, options: options)
            } else {
                result = PHAsset.fetchAssets(with: options)
            }
            
            
            let placeholder = #imageLiteral(resourceName: "Plus")
            var assets: [MediaProvider] = Array(repeating: AnyVBAsset(placeholder), count: result.count)
            
            var counter = 0
            let counterCheck = {
                counter += 1
                if (counter == result.count) {
                    DispatchQueue.main.async {
                        handler(assets)
                    }
                }
            }
            
            result.enumerateObjects ({ asset, index, stop in
                
                if asset.mediaType == .image {
                    PHImageManager.default().requestImageData(for: asset, options: nil)
                    { imageData, dataUTI, orientation, info in
                        imageData.map {
                            if let image = UIImage(data: $0) {
                                assets[index] = AnyVBAsset(image)
                            }
                            counterCheck()
                        }
                    }
                } else {
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil)
                    { avasset, audioMix, info in
                        avasset.map {
                            assets[index] = AnyVBAsset($0)
                            counterCheck()
                        }
                    }
                }
            })
        }
    }
    
    private func getFetchOptions(_ offset: Int, _ count: Int) -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        if #available(iOS 9.0, *) {
            fetchOptions.fetchLimit = offset + count
        }
        fetchOptions.wantsIncrementalChangeDetails = false
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        return fetchOptions
    }
    
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                handler(status)
            }
        }
    }
    
    func authorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
}

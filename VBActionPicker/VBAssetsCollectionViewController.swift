//
//  VBAssetsCollectionViewController.swift
//  VBActionPicker
//
//  Created by Victor Bogatyrev on 27.04.17.
//  Copyright © 2017 Victor Bogatyrev. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class VBAssetsCollectionViewController: UICollectionViewController {
    
    private var manager = VBAssetsManager()
    fileprivate var resultAssets: [MediaProvider] = []
    fileprivate let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    fileprivate var frame: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(VBAseetsCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.manager.getAssets(offset: 0, count: 20, imagesOnly: true) { (assets) in
            if assets.count > 0 {
                self.resultAssets = assets
                self.collectionView?.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }
    /*
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 120, height: 120)
        flowLayout.scrollDirection = .horizontal
        super.init(collectionViewLayout: flowLayout)
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 120), collectionViewLayout: flowLayout)
        manager = VBAssetsManager()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return resultAssets.count + rowCountForLiveCameraCell()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageData = resultAssets[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VBAseetsCell
        cell.imageView.image = imageData.image()
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension VBAssetsCollectionViewController {
    
    func rowCountForLiveCameraCell() -> Int {
        return cameraIsAvailable ? 1 : 0
    }
}

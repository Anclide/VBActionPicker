//
//  ViewController.swift
//  VBActionPicker
//
//  Created by Victor Bogatyrev on 26.04.17.
//  Copyright © 2017 Victor Bogatyrev. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class ViewController: UIViewController {
    
    let picker = VBActionPicker()
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        let firstAction = VBActionPickerObject(withTitle: "Camera", image: #imageLiteral(resourceName: "Plus"), type: .camera)
        let secondAction = VBActionPickerObject(withTitle: "Location", image: #imageLiteral(resourceName: "Plus"), type: .location)
        let thirdAction = VBActionPickerObject(withTitle: "Camera Roll", image: #imageLiteral(resourceName: "Plus"), type: .cameraRoll)
        let fourthAction = VBActionPickerObject(withTitle: "File", image: #imageLiteral(resourceName: "File"), type: .file)
        let fifthAction = VBActionPickerObject(withTitle: "Contacts", image: #imageLiteral(resourceName: "Plus"), type: .contacts)
        let objects = [firstAction, secondAction, thirdAction, fourthAction, fifthAction]
        
        picker.tintColor = UIColor.white
        picker.backgroundColor = UIColor(red: (13/255), green: (143/255), blue: (229/255), alpha: 1)
        picker.configure(with: .default, objectStyles: .onlyLabel, objects: objects)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(_sender: Any) {
        picker.show()
    }

}

extension ViewController: VBActionPickerDelegate {
    func picker(_ picker: VBActionPicker, didFinishPickingMediaWithResult result: [String : Any]) {
        if let img = result["images"] as? Array<UIImage> {
            imageView.image = nil
            imageView.image = img[0]
        }
        
        if let loc = result["location"] as? MKPlacemark {
            label.text = loc.locality?.appending(" \(loc.title ?? "")")
        }
        
        if let cont = result["contacts"] as? [CNContact] {
            let first = cont[0]
            label.text = first.givenName.appending("\n \(first.phoneNumbers[0].value.stringValue)")
            if first.imageDataAvailable {
                imageView.image = UIImage(data: first.imageData!)
            }
        }
    }
}


//
//  VBActionPickerLocationViewController.swift
//  VBActionPicker
//
//  Created by Victor Bogatyrev on 29.05.17.
//  Copyright © 2017 Victor Bogatyrev. All rights reserved.
//

import UIKit
import MapKit
protocol VBLocationPickerDelegate {
    func didSelectLocation(placemark: MKPlacemark)
}

class VBActionPickerLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var getButton: UIButton!
    var locationManager: CLLocationManager = CLLocationManager()
    var geocoder: CLGeocoder = CLGeocoder()
    var placemark: MKPlacemark? = nil
    var delegate: VBLocationPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getTapped(_ sender: Any) {
        delegate?.didSelectLocation(placemark: placemark!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VBActionPickerLocationViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if ((userLocation.coordinate.latitude != 0.0) && (userLocation.coordinate.longitude != 0.0)) {
            DispatchQueue.main.async {
                mapView.setCenter(userLocation.coordinate, animated: true)
            }
        }
        
        geocoder.reverseGeocodeLocation(mapView.userLocation.location!) { (placemarks, error) in
            if placemarks != nil && (placemarks?.count)! > 0 {
                self.placemark = placemarks?.first as? MKPlacemark
                self.getButton.isEnabled = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        getButton.isEnabled = false
        
        if (self.presentedViewController != nil) {
            let message = error.localizedDescription
            
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
}

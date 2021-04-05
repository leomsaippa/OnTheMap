//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 04/04/21.
//

import MapKit
import UIKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locationTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func findOnTheMap(_ sender: Any) {
        
        let newLocation = locationTextField.text

        findPosition(newLocation: newLocation ?? "")
    }
    
    private func findPosition(newLocation: String) {
        CLGeocoder().geocodeAddressString(newLocation) { (newMarker, error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription, title: "Location Not Found")
                print("Location not found")
            } else {
                var location: CLLocation?
                if let marker = newMarker, marker.count > 0 {
                    location = marker.first?.location
                    print("Location found \(location)")

                }
                
                if let location = location {
              
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "SaveLocationViewController") as! SaveLocationViewController
                    controller.location = location
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    self.showAlert(message: "Please try again later.", title: "Error")
             
                    print("There was an error.")
                }
            }
        }
    }
}

//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 04/04/21.
//

import MapKit
import UIKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    
    var locationTextFieldIsEmpty = true

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    @IBOutlet weak var locationTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        isToShowIndicator(isToShow: false)
        locationTextField.delegate = self
        isToEnableButton(false, button: findOnTheMapButton)
        self.hideKeyboardWhenTappedAround()
    
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func findOnTheMap(_ sender: Any) {
        self.isToShowIndicator(isToShow: true)
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
        self.isToShowIndicator(isToShow: false)

    }

    func isToShowIndicator(isToShow: Bool) {
  
        
        if isToShow {
            DispatchQueue.main.async {
                self.indicatorView.startAnimating()
                self.isToEnableButton(false, button: self.findOnTheMapButton)
            }
        } else {
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.isToEnableButton(true, button: self.findOnTheMapButton)
            }
        }
        DispatchQueue.main.async {
            self.locationTextField.isEnabled = !isToShow
            self.findOnTheMapButton.isEnabled = !isToShow
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == locationTextField {
            let currenText = locationTextField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                locationTextFieldIsEmpty = true
            } else {
                locationTextFieldIsEmpty = false
            }
        }
        

        
        if locationTextFieldIsEmpty == false  {
            isToEnableButton(true, button: findOnTheMapButton)
        } else {
            isToEnableButton(false, button: findOnTheMapButton)
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isToEnableButton(false, button: findOnTheMapButton)
        if textField == locationTextField {
            locationTextFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            findOnTheMap(findOnTheMapButton)
            
        }
        return true
    }
   
}


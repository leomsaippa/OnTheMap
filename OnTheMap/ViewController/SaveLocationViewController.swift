//
//  SaveLocationViewController.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 04/04/21.
//

import UIKit
import MapKit

class SaveLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation?
    var objectId: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Location \(location!)")
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: Fix to show after view load map zoom animation
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(location != nil){
            print("setting")
            if let coordinate = extractCoordinate(latitude: location?.coordinate.latitude, longitude: location?.coordinate.longitude) {
                let annotation = MKPointAnnotation()
                annotation.title = ""
                annotation.subtitle = ""
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
                mapView.showAnnotations(mapView.annotations, animated: true)
                //Zoom to 400/400
                mapView.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400), animated: true)
            }
            
        } else{
            print("Location nil")
        }

    }
    
    @IBAction func onSubmitClicked(_ sender: Any) {
        guard let url = URL(string: linkTextField.text!), UIApplication.shared.canOpenURL(url) else {
            self.showAlert(message: "Please include 'http://' in your link.", title: "Invalid URL")
            return
        }
        if(location != nil){
            let studentInfo = buildStudentInfo(location!.coordinate)
            addLocationOnApi(studentInfo: studentInfo)
        } else{
            print("Location nil")
        }
    }
        
    
    
    private func buildStudentInfo(_ coordinate: CLLocationCoordinate2D) -> StudentInfo {
        
        var studentInfo = [
            "uniqueKey": UdacityApiCall.Auth.key,
            "firstName": UdacityApiCall.Auth.firstName,
            "lastName": UdacityApiCall.Auth.lastName,
            "mapString": location!,
            "mediaURL": linkTextField.text!,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            ] as [String: AnyObject]
        
        if let objectId = objectId {
            studentInfo["objectId"] = objectId as AnyObject
            print(objectId)
        }

        return StudentInfo(studentInfo)

    }
    
    private func extractCoordinate(latitude: Double?, longitude: Double?) -> CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return nil
    }
    
    func isToShowIndicator(isToShow: Bool) {
  
        
        if isToShow {
            DispatchQueue.main.async {
                
                self.indicatorView.startAnimating()
                self.isToEnableButton(false, button: self.submitButton)
            }
        } else {
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.isToEnableButton(true, button: self.submitButton)
            }
        }
        DispatchQueue.main.async {
            self.submitButton.isEnabled = !isToShow
        }
    }
    
    private func addLocationOnApi(studentInfo: StudentInfo) {
            if UdacityApiCall.Auth.objectId == "" {
                    UdacityApiCall.addStudentLocation(information: studentInfo) { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.isToShowIndicator(isToShow: false)
                                self.showMapViewController()
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(message: error?.localizedDescription ?? "Something went wrong", title: "Something went wrong")
                                self.isToShowIndicator(isToShow: false)
                            }
                        }
                        
                    }
            } else {
                let alertVC = UIAlertController(title: "", message: "This student has already posted a location. Would you like to overwrite this location?", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action: UIAlertAction) in
                    UdacityApiCall.updateStudentLocation(information: studentInfo) { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.isToShowIndicator(isToShow: true)
                                self.showMapViewController()
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                                self.isToShowIndicator(isToShow: false)
                            }
                        }
                    }
                }))
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
                    DispatchQueue.main.async {
                        self.isToShowIndicator(isToShow: false)
                        alertVC.dismiss(animated: true, completion: nil)
                    }
                }))
                self.present(alertVC, animated: true)
            }
        }
    
    
    func showMapViewController() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

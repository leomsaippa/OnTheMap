//
//  SaveLocationViewController.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 04/04/21.
//

import UIKit
import MapKit

class SaveLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var linkTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation?
    var objectId: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Location \(location!)")
    }
    
    @IBAction func onSubmitClicked(_ sender: Any) {
        guard let url = URL(string: linkTextField.text!), UIApplication.shared.canOpenURL(url) else {
            self.showAlert(message: "Please include 'http://' in your link.", title: "Invalid URL")
            return
        }
        if(location != nil){
        
            let studentInfo = buildStudentInfo(location!.coordinate)
            addLocationToMap(studentInfo: studentInfo)
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
    
    private func addLocationToMap(studentInfo: StudentInfo) {
        if let coordinate = extractCoordinate(studentInfo: studentInfo) {
            let annotation = MKPointAnnotation()
            annotation.title = studentInfo.labelName
            annotation.subtitle = studentInfo.mediaURL ?? ""
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    private func extractCoordinate(studentInfo: StudentInfo) -> CLLocationCoordinate2D? {
        if let lat = studentInfo.latitude, let lon = studentInfo.longitude {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return nil
    }

}

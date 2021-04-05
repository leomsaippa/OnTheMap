//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 03/04/21.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var location = [StudentInfo]()
    var annotations = [MKPointAnnotation]()


    @IBAction func refreshMap(_ sender: UIBarButtonItem) {
        print("call refresh map")
        getInfo()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.indicatorView.startAnimating()
        UdacityApiCall.logout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.indicatorView.stopAnimating()

            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        getInfo()

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("isHere")
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("isHere now")

        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                print("open")
                openLinkClicked(toOpen ?? "")

            }
        }
    }
    
    
    func getInfo() {
        indicatorView.startAnimating()
        print("calling getInfo")
        UdacityApiCall.getStudentLocations() { locations, error in
            self.mapView.removeAnnotations(self.annotations)
            self.annotations.removeAll()
            self.location = locations ?? []
            for dictionary in locations ?? [] {
                let lat = CLLocationDegrees(dictionary.latitude ?? 0.0)
                let long = CLLocationDegrees(dictionary.longitude ?? 0.0)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let first = dictionary.firstName
                let last = dictionary.lastName
                let mediaURL = dictionary.mediaURL
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                self.annotations.append(annotation)
            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.annotations)
                self.indicatorView.stopAnimating()

            
            }
        }
    }

}

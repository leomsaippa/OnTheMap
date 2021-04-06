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
    
    var location = DataManager.shared.locations
    var annotations = [MKPointAnnotation]()
    var currentCoordinate: CLLocationCoordinate2D?



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
    
    @IBAction func addOnMap(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        getInfo()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
            
            if(error != nil){
                DispatchQueue.main.async {
                self.showAlert(message: "Fail to get students informations.", title: "Error")
                self.indicatorView.stopAnimating()
                }
              
            } else {
                self.mapView.removeAnnotations(self.annotations)
                self.annotations.removeAll()
                self.location = locations ?? []
                for dictionary in locations ?? [] {
                    let lat = CLLocationDegrees(dictionary.latitude ?? 0.0)
                    let long = CLLocationDegrees(dictionary.longitude ?? 0.0)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    self.currentCoordinate = coordinate
                    let first = dictionary.firstName
                    let last = dictionary.lastName
                    let mediaURL = dictionary.mediaURL
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    self.annotations.append(annotation)
                    DispatchQueue.main.async {
                        self.mapView.addAnnotations(self.annotations)
                        self.indicatorView.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc func willEnterForeground() {
        print("willEnterForegroun")
        getInfo()
    }

}

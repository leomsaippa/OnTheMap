//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 03/04/21.
//

import UIKit


class TableViewController: UITableViewController {
    
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var studentTableView: UITableView!

    @IBAction func refreshList(_ sender: UIBarButtonItem) {
        print("call refresh list")

        getStudentsList()
    }

    var students = DataManager.shared.locations

    override func viewDidLoad() {
        super.viewDidLoad()
        isToShowIndicator(isToShow: true)
        self.hideKeyboardWhenTappedAround()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getStudentsList()
    }
    
    @IBAction func addOnMap(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        isToShowIndicator(isToShow: true)
        UdacityApiCall.logout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.isToShowIndicator(isToShow: false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[indexPath.row]
        openLinkClicked(student.mediaURL ?? "")

    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell", for: indexPath)
        let student = students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL ?? "")"
        return cell
    }
    
    func getStudentsList() {
        print("getStudentsList")
        isToShowIndicator(isToShow: true)
        UdacityApiCall.getStudentLocations() {students, error in
            self.students = students ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.isToShowIndicator(isToShow: false)

            }
        }
    }
    
    func isToShowIndicator(isToShow: Bool) {
        indicatorView.isHidden = !isToShow
        if isToShow {
            indicatorView.startAnimating()
        } else{
            indicatorView.stopAnimating()
        }
    }
}

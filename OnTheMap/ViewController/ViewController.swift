//
//  ViewController.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 01/04/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func onLoginBtnClicked(_ sender: Any) {
        UdacityApiCall.login(email: self.emailField.text ?? "", password: self.passwordField.text ?? "", completion: handleLoginResponse(success:error:))

    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        if success {
            DispatchQueue.main.async {
                print("SUCCESS")
                self.performSegue(withIdentifier: "loginClick", sender: nil)
                
            }
        } else {
            print("ERROR")

        }
    }
}


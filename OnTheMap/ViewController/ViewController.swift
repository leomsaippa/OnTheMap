//
//  ViewController.swift
//  OnTheMap
//
//  Created by Leonardo Saippa on 01/04/21.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    let signUpUrl = UdacityApiCall.Endpoints.udacitySignUp.url
    
    var emailFieldIsEmpty = true
    var passwordFieldIsEmpty = true
    
    @IBAction func signUpBtnClicked(_ sender: Any) {
        setIndicator(true)
        UIApplication.shared.open(signUpUrl, options: [:], completionHandler: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.text = ""
        passwordField.text = ""
        emailField.delegate = self
        passwordField.delegate = self
        isToEnableButton(false, button: loginButton)
        self.hideKeyboardWhenTappedAround()
    }


    override func viewWillAppear(_ animated: Bool) {
        emailField.text = ""
        passwordField.text = ""
    }
    
    @IBAction func onLoginBtnClicked(_ sender: Any) {
        setIndicator(true)
        UdacityApiCall.login(email: self.emailField.text ?? "", password: self.passwordField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        setIndicator(false)
        if success {
            DispatchQueue.main.async {
                print("SUCCESS")
                self.performSegue(withIdentifier: "loginClick", sender: nil)
                
            }
        } else {
            setIndicator(false)
                showAlert(message: "Wrong credential.", title: "Login Error")

        }
    }
    
    func setIndicator(_ isToShowIndicator: Bool) {
        if isToShowIndicator {
            DispatchQueue.main.async {
                self.indicatorView.startAnimating()
                self.isToEnableButton(false, button: self.loginButton)
            }
        } else {
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.isToEnableButton(true, button: self.loginButton)
            }
        }
        DispatchQueue.main.async {
            self.emailField.isEnabled = !isToShowIndicator
            self.passwordField.isEnabled = !isToShowIndicator
            self.loginButton.isEnabled = !isToShowIndicator
            self.signUpButton.isEnabled = !isToShowIndicator
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailField {
            let currenText = emailField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                emailFieldIsEmpty = true
            } else {
                emailFieldIsEmpty = false
            }
        }
        
        if textField == passwordField {
            let currenText = passwordField.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                passwordFieldIsEmpty = true
            } else {
                passwordFieldIsEmpty = false
            }
        }
        
        if emailFieldIsEmpty == false && passwordFieldIsEmpty == false {
            isToEnableButton(true, button: loginButton)
        } else {
            isToEnableButton(false, button: loginButton)
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isToEnableButton(false, button: loginButton)
        if textField == emailField {
            emailFieldIsEmpty = true
        }
        if textField == passwordField {
            passwordFieldIsEmpty = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            onLoginBtnClicked(loginButton)
        }
        return true
    }
}


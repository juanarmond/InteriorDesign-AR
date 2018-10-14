//
//  CreateAccountViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 30/09/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    
    @IBOutlet weak var fNameField: UITextField!
    @IBOutlet weak var lNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logIn(_ sender: Any) {
        performSegue(withIdentifier: "signIn", sender: self)
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
        if let email = self.emailField.text, let password = self.passwordField.text{
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                // [START_EXCLUDE]
                //                self.hideSpinner {
                //                    guard let email = authResult?.user.email, error == nil else {
                //                        self.showMessagePrompt(error!.localizedDescription)
                //                        return
                //                    }
                //                    print("\(email) created")
                //                    self.navigationController!.popViewController(animated: true)
                //                }
                // [END_EXCLUDE]
                guard let user = authResult?.user else { return }
            }
        }
    }
    

}

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
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    @IBAction func logIn(_ sender: Any) {
        performSegue(withIdentifier: "signIn", sender: self)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if let fName = self.fNameField.text, let lName = self.lNameField.text,let email = self.emailField.text, let password = self.passwordField.text{
            var ref: DocumentReference? = nil
            ref = db.collection("users").addDocument(data: [
                "first": fName,
                "last": lName,
                "email": email,
                "password": password
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.performSegue(withIdentifier: "account", sender: self)
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fNameField.resignFirstResponder()
        lNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
}

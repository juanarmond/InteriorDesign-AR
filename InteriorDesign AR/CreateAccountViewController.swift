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
    var em: String!
    var id: String!
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let TypeUserViewController = segue.destination as? TypeUserViewController {
            TypeUserViewController.id = id
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if let fName = self.fNameField.text, let lName = self.lNameField.text,let email = self.emailField.text, let password = self.passwordField.text{
            if fName.isEmpty||fName == "First Name"||lName.isEmpty||lName == "Last Name"||email.isEmpty||email == "Email"||password.isEmpty||password == "password"{
                print ("Please fill all fields")
            } else{
                let collection = db.collection("users")
                collection
                    .whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                        for document in (querySnapshot?.documents)!{
                            self.em = document.data()["email"] as? String
                            print (self.em)
                        }
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else if self.em != email{
                            var ref: DocumentReference? = nil
                            ref = self.db.collection("users").addDocument(data: [
                                "first": fName,
                                "last": lName,
                                "email": email,
                                "password": password
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    self.id = String(describing: ref!.documentID)
                                    print("Document added with ID: \(ref!.documentID)")
                                    self.performSegue(withIdentifier: "typeUser", sender: self)
                                }
                            }
                        }else{
                            print ("Email already in the database")
                        }
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

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
        connectFirebase()
    }
    
    func connectFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
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
                showAlertUser()
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
                                "password": password, "accType": "Client"
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
                            self.showAlertEmail()
                        }
                }
            }
            
        }
    }
    
    func showAlertEmail() {
        let alertController = UIAlertController(title: "Email", message:
            "Email already in the database!", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertUser() {
        let alertController = UIAlertController(title: "User Details", message:
            "Please fill all fields", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func termsConditions(_ sender: Any) {
        let alertController = UIAlertController(title: "Terms and Conditions", message:
            "The use of this iOS application is subject to the following terms of use: \n•    The content of the pages of this iOS application is for your general information and use only. It is subject to change without notice.\n•    Neither we nor any third parties provide any warranty or guarantee as to the accuracy, timeliness, performance, completeness or suitability of the information and materials found or offered on this website for any particular purpose. You acknowledge that such information and materials may contain inaccuracies or errors and we expressly exclude liability for any such inaccuracies or errors to the fullest extent permitted by law.\n•    Your use of any information or materials on this iOS application is entirely at your own risk, for which we shall not be liable. It shall be your own responsibility to ensure that any products, services or information available through this website meet your specific requirements.\n•    This iOS application contains material which is owned by or licensed to us. This material includes, but is not limited to, the design, layout, look, appearance and graphics. Reproduction is prohibited other than in accordance with the copyright notice, which forms part of these terms and conditions.\n•    All trademarks reproduced in this website which are not the property of, or licensed to, the operator is acknowledged on the iOS application.\n•    Unauthorised use of this iOS application may give rise to a claim for damages and/or be a criminal offence.\n•    From time to time this iOS application may also include links to other websites or applications. These links are provided for your convenience to provide further information. They do not signify that we endorse the website(s) or application(s). We have no responsibility for the content of the linked website(s) or application(s).\n•    Your use of this iOS application and any dispute arising out of such use of the website is subject to the laws of England, Northern Ireland, Scotland and Wales."
, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fNameField.resignFirstResponder()
        lNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
}

//
//  SignInViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 30/09/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var db: Firestore!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let CompanyAccountViewController = segue.destination as? CompanyAccountViewController {
            CompanyAccountViewController.id = id
        }
        if let ARScanViewController = segue.destination as? ARScanViewController {
            ARScanViewController.id = id
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        if let email = self.emailField.text, let password = self.passwordField.text{
            let collection = db.collection("users")
            collection
                .whereField("email", isEqualTo: email)
                .whereField("password", isEqualTo: password).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else if querySnapshot!.isEmpty{
                        print("Document not  found)")
                        self.showAlert()
                    } else {
                        for document in (querySnapshot?.documents)!{
                            if let em = document.data()["email"] as? String {
                                if let ps = document.data()["password"] as? String{
                                    print (em, ps)
                                    self.id = document.documentID
                                    if let accType = document.data()["accType"] as? String{
                                        if "\(accType)" == "Client" {
                                            self.performSegue(withIdentifier: "arScan", sender: self)
                                            print("\(accType)")
                                        }else{
                                            self.performSegue(withIdentifier: "companyAccount", sender: self)
                                            print("\(accType)")
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "User Details", message:
            "Incorrect Email and Password", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        performSegue(withIdentifier: "createAccount", sender: self)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

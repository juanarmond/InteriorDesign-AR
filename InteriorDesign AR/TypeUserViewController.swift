//
//  TypeUserViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 21/10/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class TypeUserViewController: UIViewController {
    
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var emailField: UILabel!
    
    var id: String!
    var db: Firestore!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()

//        let user = db.collection("users").document(id)
//
//        user.getDocument{ (document, error) in
//            if let document = document {
//                self.nameField.text = document.get("name") as? String
//                self.emailField.text = document.get("email") as? String
//            } else {
//                print("Document does not exist in cache")
//            }
//        }
    }
//
//    @IBAction func accType(_ sender: Any) {
//
//    }
//
//    @IBAction func done(_ sender: Any) {
//        self.performSegue(withIdentifier: "account", sender: self)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

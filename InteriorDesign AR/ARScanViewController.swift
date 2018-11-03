//
//  ARScanViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 03/11/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class ARScanViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    var db: Firestore!
    var id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        getUser()
    }
    
    func getUser(){
        db = Firestore.firestore()
        let user = db.collection("users").document(id)
        user.getDocument{ (document, error) in
            if let document = document {
                let first = document.get("first") as? String
                let last = document.get("last") as? String
                self.nameLabel.text = first! + " " + last!
                print(first! + " " + last!)
            } else {
                print("Document does not exist in cache")
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let SearchItemViewController = segue.destination as? SearchItemViewController {
            SearchItemViewController.id = id
        }
    }
    
    @IBAction func tryAR(_ sender: Any) {
        self.performSegue(withIdentifier: "searchItem", sender: self)
    }
    
    @IBAction func tryScan(_ sender: Any) {
//        self.performSegue(withIdentifier: "scan", sender: self)
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

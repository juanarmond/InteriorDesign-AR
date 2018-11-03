//
//  ARViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 03/11/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import ARKit
import Firebase

class ARViewController: UIViewController{

    
    @IBOutlet weak var ARView: ARSCNView!
    
    var db: Firestore!
    var item: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
    }
    
    func getItem(){
        db = Firestore.firestore()
        db.collection("products").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.item = document.get("product ID") as? String
                    //                    print("\(document.documentID) => \(document.get("product") ?? "empty")")
                }
                print(self.item)
            }
        }
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

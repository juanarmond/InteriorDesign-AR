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
    var products: [String] = []
    var productsID: [String] = []
    var client: String!
    var clientEmail: String!
    
    @IBOutlet weak var avatarView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectFirebase()
        getUser()
        getUserAvatar()
        getItems()
    }
    
    func connectFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func getUser(){
        db = Firestore.firestore()
        let user = db.collection("users").document(id)
        user.getDocument{ (document, error) in
            if let document = document {
                let first = document.get("first") as? String
                let last = document.get("last") as? String
                self.nameLabel.text = first! + " " + last!
                self.client = first! + " " + last!
                self.clientEmail = document.get("email") as? String
                print(first! + " " + last!)
            } else {
                print("Document does not exist in cache")
            }
        }
    }
    
    func getUserAvatar(){
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Create a reference to the file you want to download
        let avatarRef = storageRef.child("avatar/\(id!)")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        avatarRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("Error download avatar")
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.avatarView.image = image
                print("Avatar")
            }
        }
    }
    
    func getItems(){
        var notFound: Bool = true
        db = Firestore.firestore()
        db.collection("products").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    for docID in self.productsID{
                        if(document.get("product ID")as! String == docID){
                            notFound = false
                        }
                    }
                    if(notFound){
                        self.products.append(document.get("product") as! String)
                        self.productsID.append(document.get("product ID") as! String)
                    }
                }
                print(self.products.count)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if  segue.identifier == "searchItem",
          if  let SearchItemViewController = segue.destination as? SearchItemViewController {
                SearchItemViewController.id = id
                SearchItemViewController.products = products
                SearchItemViewController.productsID = productsID
                SearchItemViewController.client = client
                SearchItemViewController.clientEmail = clientEmail
        }
//        if  segue.identifier == "arScan",
          if  let ScanViewController = segue.destination as? ScanViewController {
            ScanViewController.id = id
            print(id)
        }
    }
    
    @IBAction func tryAR(_ sender: Any) {
        self.performSegue(withIdentifier: "searchItem", sender: self)
    }
    
    @IBAction func tryScan(_ sender: Any) {
        self.performSegue(withIdentifier: "scan", sender: self)
    }
    
    @IBAction func logout(_ sender: Any) {
        self.performSegue(withIdentifier: "welcome", sender: self)
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

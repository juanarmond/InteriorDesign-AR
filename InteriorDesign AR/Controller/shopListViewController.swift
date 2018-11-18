//
//  shopListViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 07/11/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class shopListViewController: UIViewController {

    var db: Firestore!
    var item: String!
    var id: String!
    var products: [String]!
    var productsID: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectFirebase()
        getItems()
    }
    
    func connectFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
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

    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "searchItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let SearchItemViewController = segue.destination as? SearchItemViewController {
            SearchItemViewController.id = id
            SearchItemViewController.products = products
            SearchItemViewController.productsID = productsID
            
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

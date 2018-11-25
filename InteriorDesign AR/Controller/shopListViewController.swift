//
//  shopListViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 07/11/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class shopListViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var db: Firestore!
    var item: String!
    var id: String!
    var products: [String]!
    var productsID: [String]!
    var shopListDic : [Int: (String, Int, Double)] = [:]
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopListDic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath )
        cell.textLabel?.text = shopListDic[indexPath.row]!.0
//            + "    " + "\(shopListDic[indexPath.row]!.1)" + "    " + "\(shopListDic[indexPath.row]!.2)"
//        }
        return cell
    }
    
    

    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "searchItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if let SearchItemViewController = segue.destination as? SearchItemViewController {
                SearchItemViewController.id = id
                SearchItemViewController.products = products
                SearchItemViewController.productsID = productsID
                SearchItemViewController.shopListDic = shopListDic
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

//
//  AccountViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 14/10/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    /** @var handle
     @brief The handler for the auth state listener, to allow cancelling later.
     */
    var id: String!
    var db: Firestore!
    var products: [String] = []
    var refresher: UIRefreshControl!
//    let data = ["data 1", "data 2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        getUser()
        getItems()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "pull to refresh")
        refresher.addTarget(self, action: #selector(AccountViewController.refresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refresher)
        refresh()
    }
    
    func getUser(){
        db = Firestore.firestore()
        let user = db.collection("users").document(id)
        user.getDocument{ (document, error) in
            if let document = document {
                let first = document.get("first") as? String
                let last = document.get("last") as? String
                print(first! + " " + last!)
            } else {
                print("Document does not exist in cache")
            }
        }
    }
    
    func getItems(){
        db = Firestore.firestore()
        db.collection("products").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.products.append(document.get("product") as! String)
                    print("\(document.documentID) => \(document.get("product") ?? "empty")")
                }
                print(self.products.count)
            }
        }
    }
    @objc func refresh(){
        self.tableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath )
        
        cell.textLabel?.text = products[indexPath.row]
        return cell
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

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
     var countItens: Int = 0;
    
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item = "Item"
        let qty = "Qty"
        return item.padding(toLength: 35, withPad: " ", startingAt: 0) + qty.padding(toLength: 15, withPad: " ", startingAt: 0) + "Cost"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath )
        let costF : String = NSString(format: "%.02f", shopListDic[indexPath.row]!.2) as String
        let qty : String = "\(shopListDic[indexPath.row]!.1)".padding(toLength: 15-costF.count, withPad: " ", startingAt: 0)
        let pound : String = "£".padding(toLength: 8-costF.count, withPad: " ", startingAt: 0)
        cell.textLabel?.text = shopListDic[indexPath.row]!.0.padding(toLength: 20, withPad: " ", startingAt: 0)
        cell.detailTextLabel?.text = qty + pound + costF
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            self.shopListDic.removeValue(forKey: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print(self.shopListDic)
        }
        return [delete]
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
                SearchItemViewController.countItens = countItens
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

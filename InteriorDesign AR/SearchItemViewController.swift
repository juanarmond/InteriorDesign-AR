//
//  SearchItemViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 14/10/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class SearchItemViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    /** @var handle
     @brief The handler for the auth state listener, to allow cancelling later.
     */
    var id: String!
    var db: Firestore!
    var products: [String] = []
    var productsID: [String] = []
    var sortedID : [String] = []
    var refresher: UIRefreshControl!
    var searchProduct: [String] = []
    var searching: Bool = false
    var item: String!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        getItems()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "pull to refresh")
        refresher.addTarget(self, action: #selector(SearchItemViewController.refresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refresher)
        refresh()
    }
    
    func getItems(){
        db = Firestore.firestore()
        db.collection("products").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.products.append(document.get("product") as! String)
                    self.productsID.append(document.get("product ID") as! String)
//                    self.products.append((document.get("product")as! String, document.get("product ID") as! String))
//                    print("\(document.documentID) => \(document.get("product") ?? "empty")")
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
        if (searching) {
            return searchProduct.count
        }else{
            return products.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath )
        if (searching){
            cell.textLabel?.text = searchProduct[indexPath.row]
        } else{
//            products.sort()
            let offsets = products.enumerated().sorted{$0.element < $1.element }.map { $0.offset }
            let sorted_pro = offsets.map { products[$0] }
            sortedID = offsets.map { productsID[$0] }
            cell.textLabel?.text = sorted_pro[indexPath.row]
//            cell.textLabel?.text = products[indexPath.row]
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchProduct = products.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
//        searchProduct = products.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
        self.searching = true
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searching = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    // return keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        index = tableView.indexPathForSelectedRow?.row
//        getItem(index: index)
        item = self.sortedID[self.index]
        print(item)
        if  segue.identifier == "ar",
            let ARViewController = segue.destination as? ARViewController{
                ARViewController.item = self.item
                ARViewController.id = self.id
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


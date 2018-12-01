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
    
    var id: String!
    var db: Firestore!
    var products: [String]!
    var productsID: [String]!
    var proImage:[UIImage] = []
    var sortedID : [String] = []
    var refresher: UIRefreshControl!
    var searchProduct: [String] = []
    var searching: Bool = false
    var item: String!
    var index: Int!
    var shopListDic : [Int: (String, Int, Double)] = [:]
    var countItens: Int = 0;
    var client: String!
    var clientEmail: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectFirebase()
        getItems()
        refreshList()
        refresh()
    }
    
    func connectFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func refreshList(){
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "pull to refresh")
        refresher.addTarget(self, action: #selector(SearchItemViewController.refresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refresher)
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

////            Creating preview in each row
//            let storage = Storage.storage()
//
//            // Create a storage reference from our storage service
//            let storageRef = storage.reference()
//            // Create a reference to the file you want to download
//
////            let imageRef = storageRef.child("products/qdc5StI534Q4Np0uAR8g/\(productsID[indexPath.row])/\(sorted_pro[indexPath.row]).usdz")
//            let imageRef = storageRef.child("products/qdc5StI534Q4Np0uAR8g/3qRguxBGjK6XsRdHOh1Z/redchair.usdz")
//
//            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//           let downloadTask = imageRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
//                if error != nil {
//                    // Uh-oh, an error occurred!
//                    print("no image")
//                    print(imageRef)
//                } else {
//                    // Data for "product" is returned
//                    DispatchQueue.main.async {
//                        cell.imageView?.image = UIImage(data: data!)
//                    }
//                }
//            }
//
//            downloadTask.observe(.progress) { snapshot in
//                // A progress event occured
//                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
//                    / Double(snapshot.progress!.totalUnitCount)
//                print(percentComplete)
//            }
//
//            downloadTask.observe(.success) { snapshot in
//                // Upload completed successfully
//                print("Upload Sucess")
//            }
//
//            downloadTask.observe(.failure) { snapshot in
//                guard let errorCode = (snapshot.error as NSError?)?.code else {
//                    return
//                }
//                guard let error = StorageErrorCode(rawValue: errorCode) else {
//                    return
//                }
//                switch (error) {
//                case .objectNotFound:
//                    print("File doesn't exist")
//                    break
//                case .unauthorized:
//                    print("User doesn't have permission to access file")
//                    break
//                case .cancelled:
//                    print("User cancelled the download")
//                    break
//                    /* ... */
//                case .unknown:
//                    print("Unknown error occurred, inspect the server response")
//                    break
//                default:
//                    print("Another error occurred. This is a good place to retry the download.")
//                    break
//                }
//            }
            
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
//        if  segue.identifier == "ar",
           if let ARViewController = segue.destination as? ARViewController{
                index = tableView.indexPathForSelectedRow?.row
                item = self.sortedID[self.index]
                print(item!)
                ARViewController.item = item
                ARViewController.id = id
                ARViewController.products = products
                ARViewController.productsID = productsID
                ARViewController.shopListDic = shopListDic
                ARViewController.countItens = countItens
                ARViewController.client = client
                ARViewController.clientEmail = clientEmail
            }
        if let ARScanViewController = segue.destination as? ARScanViewController {
            ARScanViewController.id = id
            ARScanViewController.products = products
            ARScanViewController.productsID = productsID
            ARScanViewController.client = client
            ARScanViewController.clientEmail = clientEmail
        }
    }

    @IBAction func goBack(_ sender: Any) {
        self.performSegue(withIdentifier: "arScan", sender: self)
    }

}


//
//  ARViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 03/11/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import Firebase
import QuickLook

class ARViewController: UIViewController, QLPreviewControllerDataSource{

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var db: Firestore!
    var item: String!
    var id: String!
//    var image: UIImage!
//    var virtualOS: Any!
    var cost: Double!
    var percentComplete: Double = 0
    var products: [String]!
    var productsID: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        connectFirebase()
        getItem()
        getItemDetails()
        getItems()
    }
    
    func connectFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        print(id!, " ", item!)
    }

    func getItem(){
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("products/qdc5StI534Q4Np0uAR8g/\(item!)/picture.usdz")
        // Create local filesystem URL
        let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = URL(string: "\(localDocumentsURL)/picture.usdz")!
        let downloadTask = imageRef
            .write(toFile: localURL) { url, error in
            if error != nil {
                // Uh-oh, an error occurred!
                print("no image")
                print(imageRef)
            } else {
                let previewController = QLPreviewController()
                previewController.dataSource = self
                self.present(previewController, animated: true)
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
            // A progress event occured
            self.percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print(Float(self.percentComplete/100))
            self.progressLabel.text = NSString(format: "%.0f", self.percentComplete) as String + "%"
            self.progressView.progress = Float(self.percentComplete/100)
        }
        
        downloadTask.observe(.success) { snapshot in
            // Upload completed successfully
            print("Download Sucess")
        }
        
        downloadTask.observe(.failure) { snapshot in
            guard let errorCode = (snapshot.error as NSError?)?.code else {
                return
            }
            guard let error = StorageErrorCode(rawValue: errorCode) else {
                return
            }
            switch (error) {
            case .objectNotFound:
                print("File doesn't exist")
                break
            case .unauthorized:
                print("User doesn't have permission to access file")
                break
            case .cancelled:
                print("User cancelled the download")
                break
                /* ... */
            case .unknown:
                print("Unknown error occurred, inspect the server response")
                break
            default:
                print("Another error occurred. This is a good place to retry the download.")
                break
            }
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("picture.usdz")
          return fileURL as QLPreviewItem
    }
    
    @IBAction func chooseAnother(_ sender: Any) {
        self.performSegue(withIdentifier: "searchItem", sender: self)
        // Cancel the download
        
    }
    
    @IBAction func shopList(_ sender: Any) {
        self.performSegue(withIdentifier: "shopList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let SearchItemViewController = segue.destination as? SearchItemViewController {
            SearchItemViewController.id = id
            SearchItemViewController.products = products
            SearchItemViewController.productsID = productsID
            
        }
    }
    
    func getItemDetails(){
        db = Firestore.firestore()
        let product = db.collection("products").document(item)
        let user = db.collection("users")
        var companyID: String!
        // Get the User Information
        product.getDocument{ (document, error) in
            if let document = document {
                self.nameLabel.text = document.get("product") as? String
                self.descriptionLabel.text = document.get("description") as? String
                companyID = document.get("company ID") as? String
                self.cost = document.get("cost") as? Double
                self.priceLabel.text = NSString(format: "£ %.02f", self.cost) as String
            } else {
                print("Document does not exist in cache")
            }
            //Get Company Name
            user.document(companyID).getDocument{ (document, error) in
                if let document = document {
                    let first = document.get("first") as? String
                    let last = document.get("last") as? String
                    self.companyLabel.text = first! + " " + last!
                } else {
                    print("Document does not exist in cache")
                }
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
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        quantityLabel.text = Int(sender.value).description
        self.priceLabel.text = NSString(format: "£ %.02f", (self.cost! * Double(sender.value))) as String
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

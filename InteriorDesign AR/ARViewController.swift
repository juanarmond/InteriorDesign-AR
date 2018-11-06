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
    
    var db: Firestore!
    var item: String!
    var id: String!
    var image: UIImage!
    var virtualOS: Any!
    var cost: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        print(id!, " ", item!)
        getItem()
        getItemDetails()
    }

    func getItem(){
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("products/qdc5StI534Q4Np0uAR8g/\(item!)/picture.usdz")
        
//        let imageRef = storageRef.child("products/qdc5StI534Q4Np0uAR8g/\(item!)/picture")
        
        // Create local filesystem URL
        let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = URL(string: "\(localDocumentsURL)/picture.usdz")!

        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        let downloadTask = imageRef
            .write(toFile: localURL) { url, error in
//            .getData(maxSize: 15 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                print("no image")
                print(imageRef)
            } else {
                // Data for "product" is returned
//                self.image = UIImage(data: data!)
//                self.virtualOS = data!
                
//                self.image = UIImage(data: data!)
//                print(self.virtualOS)
                
                let previewController = QLPreviewController()
                previewController.dataSource = self
                self.present(previewController, animated: true)
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
            // A progress event occured
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
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
//        let url = Bundle.main.url(forResource: "redchair", withExtension: "usdz")
//        let url = Bundle.main.url(forResource: "picture", withExtension: "jpg")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("picture.usdz")
        //https://stackoverflow.com/questions/26171901/swift-write-image-from-url-to-local-file
//            else {
//            fatalError("Could not load redchair.usdz")
//        }
          return fileURL as QLPreviewItem
    }
    
    @IBAction func chooseAnother(_ sender: Any) {
        self.performSegue(withIdentifier: "searchItem", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let SearchItemViewController = segue.destination as? SearchItemViewController {
            SearchItemViewController.id = id
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

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

class ARViewController: UIViewController{

    
    var db: Firestore!
    var item: String!
    var id: String!
    var image: UIImage!
    var virtualOS: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        print(id!, " ", item!)
        getItem()
    
    }

    func getItem(){
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("products/qdc5StI534Q4Np0uAR8g/\(item!)/redchair.usdz")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        let downloadTask = imageRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                print("no image")
                print(imageRef)
            } else {
                // Data for "product" is returned
                self.virtualOS = SCNScene(named: "\(data!)")
                
                self.image = UIImage(data: data!)
                print(self.image)
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
            print("Upload Sucess")
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
    
    @IBAction func chooseAnother(_ sender: Any) {
        self.performSegue(withIdentifier: "searchItem", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let SearchItemViewController = segue.destination as? SearchItemViewController {
            SearchItemViewController.id = id
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

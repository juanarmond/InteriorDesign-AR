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
import Foundation
import QuickLook

class ARViewController: UIViewController{

    
    @IBOutlet weak var aRView: ARSCNView!
    
    var db: Firestore!
    var item: String!
    var id: String!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        print(id, " ", item)
        
    }

    func getItem(){
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Create a reference to the file you want to download
        let islandRef = storageRef.child("products/qdc5StI534Q4Np0uAR8g/\(String(describing: item))")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                print("no image")
            } else {
                // Data for "product" is returned
                self.image = UIImage(data: data!)
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

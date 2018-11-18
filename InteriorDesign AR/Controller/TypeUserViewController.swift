//
//  TypeUserViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 21/10/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase


class TypeUserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
  
    var products: [String] = []
    var productsID: [String] = []
    var id: String!
    var db: Firestore!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectFirebase()
        // Get the User Information
        getUser()
        getItems()
    }
    func connectFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func getUser() {
        let user = db.collection("users").document(id)
        user.getDocument{ (document, error) in
            if let document = document {
                let first = document.get("first") as? String
                let last = document.get("last") as? String
                self.nameField.text = first! + " " + last!
                self.emailField.text = document.get("email") as? String
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
                    self.productsID.append(document.get("product ID") as! String)
//                    print("\(document.get("product"))")
                }
                print(self.products.count)
            }
        }
    }

    @IBAction func uploadPicture(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a Source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }))

        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        avatar.image = image
        let rot = imageOrientation(image)
        //Upload Image do Cloud
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("avatar/\(String(id))")
        guard let imageData = rot.jpegData(compressionQuality: 0.25) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let uploadTask = storageRef.putData(imageData, metadata: metaData)
        // Add a progress observer to an upload task
        let observer = uploadTask.observe(.progress) { snapshot in
            // A progress event occured
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
        }
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            print("Upload Sucess")
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    print("File doesn't exist")
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    print("User doesn't have permission to access file")
                    break
                case .cancelled:
                    // User canceled the upload
                    print("User canceled the upload")
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    print("Unknown error")
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    print("separate error occurred")
                    break
                }
            }
        }
        
        // don't delete
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Fix image orientation
    func imageOrientation(_ src:UIImage)->UIImage {
        if src.imageOrientation == UIImage.Orientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        
        return img
    }// Fix image rotation code below
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    

    
    @IBAction func accType(_ sender: Any) {
        
        let user = db.collection("users").document(id)
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            user.updateData(["accType": "Client"])
            print("Client")
        case 1:
            user.updateData(["accType": "Professional"])
            print("Professional")
        case 2:
            user.updateData(["accType": "Company"])
            print("Company")
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let CompanyAccountViewController = segue.destination as? CompanyAccountViewController {
            CompanyAccountViewController.id = id
        }
        if let AccountViewController = segue.destination as? SearchItemViewController {
            AccountViewController.id = id
            AccountViewController.products = products
            AccountViewController.productsID = productsID
        }
    }

    @IBAction func done(_ sender: Any) {
        let user = db.collection("users").document(id)
        user.getDocument{ (document, error) in
            if let document = document {
                let accType = document.get("accType") as! String
                print(accType)
                print("---------")
                if "\(accType)" != "Client" {
                    self.performSegue(withIdentifier: "companyAccount", sender: self)
                    print("///////")
                    print("\(accType)")
                }else {
                    self.performSegue(withIdentifier: "account", sender: self)
                    print("*****")
                    print("\(accType)")
                }
            }
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

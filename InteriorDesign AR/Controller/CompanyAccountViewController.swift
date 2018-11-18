//
//  CompanyAccountViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 28/10/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class CompanyAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentBrowserViewControllerDelegate {

    @IBOutlet weak var prodImage: UIImageView!
    @IBOutlet weak var accNameField: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var pdescriptionField: UITextView!
    @IBOutlet weak var costField: UITextField!

    var id: String!
    var db: Firestore!
    var prod: String!
    var pd: String!
    var start: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        connectFirebase()
        // Get the User Information
        getUser()
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
                self.accNameField.text = first! + " " + last!
            } else {
                print("Document does not exist in cache")
            }
        }
    }
    
    @IBAction func upload(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        let docPickerController = UIDocumentBrowserViewController()

        docPickerController.delegate = self
        imagePickerController.delegate = self

        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a Source", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action:UIAlertAction) in
//            imagePickerController.sourceType = .photoLibrary
//            self.present(imagePickerController, animated: true, completion: nil)
//        }))

        actionSheet.addAction(UIAlertAction(title: "Browse Files", style: .default, handler: { (action:UIAlertAction) in
            docPickerController.loadView()
//            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }

    @IBAction func done(_ sender: Any) {
        if let product = self.nameField.text, let pdescription = self.pdescriptionField.text, let cost = self.costField.text{
            if product.isEmpty||product == "Insert name."||pdescription.isEmpty||pdescription == "Insert description."||cost.isEmpty||cost == "Insert value."{
                print ("Please fill all fields")
                self.showAlertDetails()
            } else{
                let collection = db.collection("products")
                collection
                    .whereField("company ID", isEqualTo: id)
                    .whereField("product", isEqualTo: product).getDocuments() { (querySnapshot, err) in
                        for document in (querySnapshot?.documents)!{
                            self.prod = document.data()["product"] as? String
                            print (self.prod)
                        }
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else if self.prod != product{
                            var ref: DocumentReference? = nil
                            ref = self.db.collection("products").addDocument(data: [
                                "company ID" : self.id,
                                "product ID" : "",
                                "product": product,
                                "description": pdescription,
                                "cost": Double(cost)!
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    self.pd = "\(ref!.documentID)"
                                    self.start = true
                                    self.db.collection("products").document(self.pd).updateData(["product ID" : self.pd])
                                    
                                    print("Product added with ID: \(ref!.documentID)")
//                                    self.performSegue(withIdentifier: "typeUser", sender: self)
                                }
                            }
                        }else{
                            print ("Product already in the database")
                            self.showAlertProducts()
                        }
                }
            }

        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        prodImage.image = image
        let rot = imageOrientation(image)
        //Upload Image do Cloud
        //        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("products/\(String(id))/\(String(pd))/picture.jpg/")
//         let storageRef = Storage.storage().reference().child("products/\(String(id))/\(String(pd))/picture.usdz/")
        guard let imageData = rot.jpegData(compressionQuality: 0.25) else { return }
        let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
//            metaData.contentType = "single object/usdz"
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

    // return keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameField.resignFirstResponder()
        pdescriptionField.resignFirstResponder()
        costField.resignFirstResponder()
    }
    
    @IBAction func testAR(_ sender: Any) {
        self.performSegue(withIdentifier: "arScan", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ARScanViewController = segue.destination as? ARScanViewController {
            ARScanViewController.id = id
        }
    }
    
    func showAlertProducts() {
        let alertController = UIAlertController(title: "Product Details", message:
            "Product already in the database", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertDetails() {
        let alertController = UIAlertController(title: "Product Details", message:
            "Please fill all fields", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
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

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
    
    var id: String!
    var db: Firestore!
    var photo: UIImage!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        let user = db.collection("users").document(id)

        // Get the User Information
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
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func accType(_ sender: Any) {

    }

    @IBAction func done(_ sender: Any) {
        self.performSegue(withIdentifier: "account", sender: self)
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

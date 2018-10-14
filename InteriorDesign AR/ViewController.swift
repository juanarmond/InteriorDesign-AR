//
//  ViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 24/09/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func signIn(_ sender: Any) {
        performSegue(withIdentifier: "signIn", sender: self)
    }
    @IBAction func createAccount(_ sender: Any) {
        performSegue(withIdentifier: "createAccount", sender: self)
    }
}


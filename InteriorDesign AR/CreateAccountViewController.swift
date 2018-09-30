//
//  CreateAccountViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 30/09/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func logIn(_ sender: Any) {
        performSegue(withIdentifier: "signIn", sender: self)
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

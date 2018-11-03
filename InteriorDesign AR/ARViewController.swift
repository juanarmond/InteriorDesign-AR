//
//  ARViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 03/11/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import ARKit
import Firebase

class ARViewController: UIViewController{

    
    @IBOutlet weak var aRView: ARSCNView!
    
    var db: Firestore!
    var item: String!
    var id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        setupScene()
        setupScene()
        print(id, " ", item)
    }
    
    func setupScene() {
        let scene = SCNScene()
        aRView.scene = scene
    }
    
    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        aRView.session.run(configuration)
    }
    
//    func loadModel() {
//        guard let virtualObjectScene = SCNScene(named: "Drone.scn") else { return }
//        let wrapperNode = SCNNode()
//        for child in virtualObjectScene.rootNode.childNodes {
//            wrapperNode.addChildNode(child)
//        }
//        addChildNode(wrapperNode)
//    }
    
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

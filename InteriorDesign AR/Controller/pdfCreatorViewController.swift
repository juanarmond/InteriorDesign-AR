//
//  pdfCreatorViewController.swift
//  InteriorDesign AR
//
//  Created by Juan Armond on 01/12/2018.
//  Copyright © 2018 Juan Armond. All rights reserved.
//

import UIKit
import Firebase
import SimplePDF
import QuickLook

class pdfCreatorViewController: UIViewController, QLPreviewControllerDataSource {

    var db: Firestore!
    var id: String!
    var shopListDic : [Int: (String, Int, Double)] = [:]
    
    var client: String!
    var clientEmail: String!
    var companyID: String!
    var companyAvatar: UIImage!
    let formatter = DateFormatter()
    let day = Calendar.current.component(.day, from: Date())
    let month = Calendar.current.component(.month, from: Date())
    let year = Calendar.current.component(.year, from: Date())
    var shopL: [[String]] = []
    var totalL: [[String]] = []
    
//    let A4paperSize = CGSize(width: 595, height: 842)
    let pdf = SimplePDF(pageSize: CGSize(width: 595, height: 842))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        connectFirebase()
        getCompanyAvatar()
        shop()
    }
    
    func connectFirebase() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func shop() {
        var total: Double = 0
        for item in shopListDic {
            let name = item.value.0
            let qnt = "\(item.value.1)"
            let cost = NSString(format: "£ %.02f", item.value.2) as String
            shopL.append([name, qnt, cost])
            total += item.value.2
        }
        
        totalL.append(["Total", NSString(format: "£ %.02f", total) as String])
    }
    
    func getCompanyAvatar(){
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Create a reference to the file you want to download
        let avatarRef = storageRef.child("avatar/\(companyID!)")
//        let avatarRef = storageRef.child("avatar/qdc5StI534Q4Np0uAR8g")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        avatarRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("Error download avatar")
            } else {
                // Data for "images/island.jpg" is returned
//                self.companyAvatar = UIImage(data: data!)
                self.companyAvatar = self.scaledImage(UIImage(data: data!)!, maximumWidth: 100)
//                self.avatarView.image = image
                print("Avatar")
                print("avatar/\(self.id!)")
            }
        }
    }
    
    func createPDF(){
        pdf.setContentAlignment(.right)
        pdf.addText("Invoice")
        let date = "Date: \(day)/\(month)/\(year)"
        pdf.addText(date)
        pdf.addLineSpace(10)
        //Company Info

        pdf.setContentAlignment(.center)
        pdf.addImage(companyAvatar)
        pdf.setContentAlignment(.left)
        pdf.addLineSpace(20)
        pdf.addText("Sofa and More")
        pdf.addLineSpace(1)
        pdf.addText("Unit 5, Phoenix Trading Estate")
        pdf.addText("Bilton Road, Perivale")
        pdf.addText("Greenford, UB6-7DZ")
        pdf.addLineSpace(30)
        
        //Client Info
//        pdf.setContentAlignment(.right)
        pdf.addText("Name: " + client)
        pdf.addText("Email: " + clientEmail)
        pdf.addLineSpace(30)
        pdf.addLineSeparator()
        
        pdf.setContentAlignment(.left)
        
        let tableDef = TableDefinition(alignments: [.left, .left, .center],
                                       columnWidths: [210, 260, 200],
                                       fonts: [UIFont.systemFont(ofSize: 25), UIFont.systemFont(ofSize: 25), UIFont.systemFont(ofSize: 25)],
                                       textColors: [UIColor.black,
                                                    UIColor.black, UIColor.black])
        let dataArray = [["Item Name", "Quantity", "Cost"]]
        
        pdf.addTable(dataArray.count, columnCount: 3, rowHeight: 25, tableLineWidth: 0, tableDefinition: tableDef, dataArray: dataArray)
        pdf.addLineSeparator()
        pdf.addLineSpace(15)
        let tableDef2 = TableDefinition(alignments: [.left, .right, .right],
                                       columnWidths: [250, 200, 100],
                                       fonts: [UIFont.systemFont(ofSize: 20), UIFont.systemFont(ofSize: 20), UIFont.systemFont(ofSize: 20)],
                                       textColors: [UIColor.black,
                                                    UIColor.black, UIColor.black])
        
        pdf.addTable(shopL.count, columnCount: 3, rowHeight: 25, tableLineWidth: 0, tableDefinition: tableDef2, dataArray: shopL)
        pdf.addLineSpace(15)
        pdf.addLineSeparator()
        pdf.addLineSpace(25)
        
        let tableDef3 = TableDefinition(alignments: [.left, .right], columnWidths: [440, 100], fonts: [UIFont.systemFont(ofSize: 25), UIFont.systemFont(ofSize: 25)], textColors: [UIColor.red, UIColor.red])
        
        pdf.addTable(totalL.count, columnCount: 2, rowHeight: 25, tableLineWidth: 0, tableDefinition: tableDef3, dataArray: totalL)
        pdf.addLineSeparator()
        
        let pdfData = pdf.generatePDFdata()
        
        // write to file
        let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = URL(string: "\(localDocumentsURL)/invoice.pdf")!
        try? pdfData.write(to: localURL, options: .atomic)
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("invoice.pdf")
        return fileURL as QLPreviewItem
    }
    
    func readPDF() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        self.present(previewController, animated: true)
    }
    
    @IBAction func getPDF(_ sender: Any) {
        createPDF()
        readPDF()
    }
    
    @IBAction func startOver(_ sender: Any) {
        self.performSegue(withIdentifier: "startOver", sender: self)
    }
    
    func scaledImage(_ image: UIImage, maximumWidth: CGFloat) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let cgImage: CGImage = image.cgImage!.cropping(to: rect)!
        return UIImage(cgImage: cgImage, scale: image.size.width / maximumWidth, orientation: image.imageOrientation)
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

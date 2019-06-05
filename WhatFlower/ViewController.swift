//
//  ViewController.swift
//  WhatFlower
//
//  Created by Hongyuan Shen on 3/10/19.
//  Copyright © 2019 Hongyuan Shen. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var extractLabel: UILabel!
    private let imagePicker = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    @IBAction func cameraClicked(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let ciImage = CIImage(image: image) else {
                fatalError("Failed converting image to CIImage")
            }
            detect(flowerImage: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(flowerImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model)
        else {
            fatalError("Failed getting Model")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let results = request.results as? [VNClassificationObservation] {
                guard let name = results.first?.identifier.capitalized else {
                    fatalError("Failed getting flower name")
                }
                self.navigationItem.title = name
                self.getWikiData(url: self.wikipediaURl, flowerName: name)
            }
        }
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])
        } catch {
            fatalError("Handler failed")
        }
    }
    
    func getWikiData(url: String, flowerName: String) {
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
            ]
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let wikiJSON: JSON = JSON(response.result.value!)
                self.updateWikiData(json: wikiJSON)
            }
        }
    }
    
    func updateWikiData(json: JSON) {
        let pageID = json["query"]["pageids"][0].stringValue
        let extract = json["query"]["pages"][pageID]["extract"].stringValue
        let flowerImageURL = URL(string: json["query"]["pages"][pageID]["thumbnail"]["source"].stringValue)
        print(json)
        extractLabel.text = extract
        self.imageView.sd_setImage(with: flowerImageURL, completed: nil)
    }
    
    
    
}


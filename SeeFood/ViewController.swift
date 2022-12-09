//
//  ViewController.swift
//  SeeFood
//
//  Created by D L on 2022-12-07.
//

import UIKit
import CoreML
//Vision help to process images more easily and alow us to use images to work with CoreML
import Vision

//UIImagePicker class allow us to tap into the camera as well as choose an image to be used for image recognition
//For UIImagePicker to work it also needs the UINavigationControllerDelegate
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        //to implement the camera funcionality
        //if running on physical device change code to imagePicker.sourceType = .camera
        imagePicker.sourceType = .photoLibrary
        //set allowsEditing as true if you want to allow the user crop the image
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //to access the image that the user has picked
        //use optional binding and downcasting to specify the data type
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //to set the imageView in the background of the app to that image that the user has picked
            imageView.image = userImage
            
            //to convert UIImage into a CIImage which allow us to use the Vision and CoreML frameworks to get an interpretation from it
            guard let ciimage = CIImage(image: userImage) else {
                //if unable to convert image
                fatalError("Could not convert UIImage to CIImage")
            }
            //pass image into detect method
            detect(image: ciimage)
        }
        
        //to dismiss imagePicker and go back to viewController
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //to process CIImage
    func detect(image: CIImage) {
    
        //to load up model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed")
        }
        //to classify data/image
        //once handler process completes, this callback gets triggered
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            //to print the results that we got from classification
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        //handler that specifies the image we want to classify
        let handler = VNImageRequestHandler(ciImage: image)
        
        //we use image handler to perform this request of classifying the image
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        //when camera button gets tapped, app will present this imagePicker to the user so they can use the camera/album to pick an image
        present(imagePicker, animated: true, completion: nil)
    }
}



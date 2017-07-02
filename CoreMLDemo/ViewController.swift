//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by Sercan Burak AĞIR on 30.06.2017.
//  Copyright © 2017 Sercan Burak AĞIR. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var coreMLImageView: UIImageView!
    @IBOutlet weak var sonucLabel: UILabel!
    
    var model: Inceptionv3!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        model = Inceptionv3()
    }
    
    @IBAction func kameraAc(_ sender: UIBarButtonItem) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
        
    }
    
    @IBAction func resimSec(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        sonucLabel.text = "Analiz Ediliyor..."
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        let yeniImg = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let atts = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pxBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(yeniImg.size.width), Int(yeniImg.size.height), kCVPixelFormatType_32ARGB, atts, &pxBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue:0))
        let pixelData = CVPixelBufferGetBaseAddress(pxBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let kaynak = CGContext(data: pixelData, width: Int(yeniImg.size.width), height: Int(yeniImg.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pxBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        kaynak?.translateBy(x: 0, y: yeniImg.size.height)
        kaynak?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(kaynak!)
        yeniImg.draw(in: CGRect(x: 0, y: 0, width: yeniImg.size.width, height: yeniImg.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        coreMLImageView.image = yeniImg
        
        guard let tahminim = try? model.prediction(image: pxBuffer!) else {
            return
        }
        
        sonucLabel.text = "Bence bu bir \(tahminim.classLabel)".uppercased()
        
    }
    
}



























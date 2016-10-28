//
//  Capturado.swift
//  BountyHunter
//
//  Created by Infraestructura on 28/10/16.
//  Copyright © 2016 Infraestructura. All rights reserved.
//

import UIKit


class Capturado: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{

    @IBOutlet weak var txtNombre: UILabel!
    @IBOutlet weak var txtDelito: UILabel!
    @IBOutlet weak var txtRecompensa: UILabel!
    @IBOutlet weak var imgCapturado: UIImageView!
    
    var fugitiveInfo: Fugitive?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.txtNombre.text = fugitiveInfo!.name
        self.txtDelito.text = fugitiveInfo!.desc
        self.txtRecompensa.text = String(fugitiveInfo!.bounty!)
    }
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func btnFotoAction()
    {
        creaFotoGalleryPicker()
    }
    
    
    func creaFotoGalleryPicker()
    {
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        
        imagePickerController.modalPresentationStyle = .FullScreen
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.presentViewController(imagePickerController, animated:true, completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let image:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let selectedFoto:UIImageView = UIImageView(image: image)
        
        self.imgCapturado.image = selectedFoto.image
        
        selectedFoto.frame = CGRectMake(16, 100, 288, 192);
        
        self.view.addSubview(selectedFoto)
        
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    
    @IBAction func btnGuardar()
    {
        let imageData = NSData(data: UIImageJPEGRepresentation(self.imgCapturado!.image!, 1.0)!)
        
        self.fugitiveInfo?.image = imageData
        self.fugitiveInfo?.captdate = NSDate().timeIntervalSinceReferenceDate
        self.fugitiveInfo?.captured = true
        
        do
        {
            try DBManager.instance.managedObjectContext?.save()
            
            let googleMapsURL = "https://www.google.com.mx/maps/@\(self.fugitiveInfo?.capturedLat),\(self.fugitiveInfo?.capturedLon)"
            
            let text = "\(self.fugitiveInfo!.name!) fue capturado en \(googleMapsURL)."
            
            //let lafoto = UIImage(data: self.fugitiveInfo!.image!)
            
            let image = UIImage(named: "fugitivo")
            
            let items: Array<AnyObject> = [text, image!]
            
            let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            avc.setValue("Fugitivo Capturado", forKey: "Subject")
            
            self.presentViewController(avc, animated: true, completion:
            {
                self.navigationController?.popViewControllerAnimated(true)
            })
            

            
        } catch {
            
            print("ERROR")
        }
    }
}

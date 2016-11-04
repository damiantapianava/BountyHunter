//
//  Capturado.swift
//  BountyHunter
//
//  Created by Infraestructura on 28/10/16.
//  Copyright © 2016 Infraestructura. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Social

class Capturado: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{

    @IBOutlet weak var txtNombre: UILabel!
    @IBOutlet weak var txtDelito: UILabel!
    @IBOutlet weak var txtRecompensa: UILabel!
    @IBOutlet weak var imgCapturado: UIImageView!
    @IBOutlet weak var btnGuardarOutlet: UIButton!
    
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
        
        //let image:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
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
            
            let texto = "\(self.fugitiveInfo!.name!) fue capturado en \(googleMapsURL)."
            
            let laFoto = UIImage(data: self.fugitiveInfo!.image!)
            
            let image = UIImage(named: "fugitivo")
            
            let feizbuc_ENABLED = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
            
            let tuiter_ENABLED  = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
            
            if feizbuc_ENABLED && tuiter_ENABLED
            {
                let ac = UIAlertController(title: "Compartir", message: "Compartir captura con...", preferredStyle: .Alert)
                
                let btnFeiz = UIAlertAction(title: "Facebook", style: .Default, handler:
                {
                    (UIAlertAction) in
                    
                    let feizbuc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    
                    feizbuc.setInitialText(texto)
                    feizbuc.addImage(laFoto!)
                    
                    self.presentViewController(feizbuc, animated: true, completion:
                    {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                })
                
                let btnTuit = UIAlertAction(title: "Twitter", style: .Default, handler:
                {
                    (UIAlertAction) in
                        
                    let tuiter = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                        
                    tuiter.setInitialText(texto)
                    tuiter.addImage(laFoto!)
                        
                    self.presentViewController(tuiter, animated: true, completion:
                    {
                                self.navigationController?.popViewControllerAnimated(true)
                    })
                })
                
                ac.addAction(btnFeiz)
                ac.addAction(btnTuit)
                
                self.presentViewController(ac, animated: true, completion: nil)
            }
            
            else if feizbuc_ENABLED
            {
                let feizbuc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                feizbuc.setInitialText(texto)
                feizbuc.addImage(laFoto!)
                
                self.presentViewController(feizbuc, animated: true, completion:
                {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
            
            else if tuiter_ENABLED
            {
                let tuiter = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                tuiter.setInitialText(texto)
                tuiter.addImage(laFoto!)
                
                self.presentViewController(tuiter, animated: true, completion:
                {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
            
            else
            {
                //let items: Array<AnyObject> = [texto, image!]
                let items:Array<AnyObject> = [texto, laFoto!, image!]
                
                let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
                
                // esto solo es necesario para el caso del correo
                avc.setValue("Fugitivo Capturado!", forKey:"Subject") // jan.zelaznog@gmail.com
                
                if UIDevice.currentDevice().userInterfaceIdiom == .Phone
                {
                
                    self.presentViewController(avc, animated: true, completion:
                    {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                
                    self.navigationController?.popViewControllerAnimated(true) // esta linea me regresa
                    
                } else {
                    
                    let popover = UIPopoverController(contentViewController: avc)
                    
                    popover.presentPopoverFromRect(self.btnGuardarOutlet.frame, inView: self.view, permittedArrowDirections: .Any, animated: true)
                }
            }
            
        } catch {
            
            print("ERROR: Al salvar la BD")
        }
    }
}

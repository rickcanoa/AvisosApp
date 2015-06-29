//
//  DetailViewController.swift
//  AvisosApp
//
//  Created by Richard Canoa on 25/5/15.
//  Copyright (c) 2015 Richard Canoa. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var itemSelected:String = ""

    @IBOutlet weak var NavBarTitle: UINavigationItem!
    
    @IBOutlet weak var miMapa: MKMapView!
    var cont:Int = 0;
    var cont3:Int = 0;
    var currentItem: NSManagedObject!
    //var ref2 = nil;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ref2 = Firebase(url:"https://ucbcba.firebaseio.com/contador");
        ref2.observeEventType(.Value, withBlock: { snap in
            println("\(snap.value)")
            self.cont = snap.value as! Int
        })
        
        var ref3 = Firebase(url:"https://ucbcba.firebaseio.com/contador_img");
        ref3.observeEventType(.Value, withBlock: { snap3 in
            println("\(snap3.value)")
            self.cont3 = snap3.value as! Int
        })
        
        //recuperar Datos Modificar ---- INICIO -------
        if(self.itemSelected != "") {
            //println(itemSelected);
            NavBarTitle.title = "Modificar Aviso"
            let myUrl = "https://ucbcba.firebaseio.com/aviso/" + itemSelected;
            var ref = Firebase(url: myUrl);
            ref.observeEventType(.Value, withBlock: { snapshot in
                println(snapshot.value)
                self.lblDescripcion.text = snapshot.value.objectForKey("descripcion") as? String
                self.lblTitulo.text = snapshot.value.objectForKey("titulo") as? String
                self.lblDireccion.text = snapshot.value.objectForKey("direccion") as? String

                let urlImg = snapshot.value.objectForKey("imagen") as! String;
                if let url = NSURL(string: urlImg) {
                    if let data = NSData(contentsOfURL: url){
                        self.myImageView.contentMode = UIViewContentMode.ScaleAspectFit
                        self.myImageView.image = UIImage(data: data)
                    }
                }
            
                let pDireccion:String = snapshot.value.objectForKey("direccion") as! String
                let pLatitud = Double((snapshot.value.objectForKey("latitud") as! NSString).doubleValue)
                let pLongitud = Double((snapshot.value.objectForKey("longitud") as! NSString).doubleValue)
                self.renderMap(pLatitud,
                    _longitud: pLongitud,
                    _direccion: pDireccion,
                    _descripcion: "")
            
            
                }, withCancelBlock: { error in
                    println(error.description)
            })
        }
        //recuperar Datos Modificar ---- FIN -------
        else
        {
            NavBarTitle.title = "Registrar Aviso"
            
            let pNombre:String = "Universidad Catolica Boliviana"
            let pDescripcion:String = "Calle Marquez y Bolivar Esq. Jorge Trigo #8779"
            let pLatitud = -17.371714
            let pLongitud = -66.143859
            renderMap(pLatitud,
                _longitud: pLongitud,
                _direccion: pNombre,
                _descripcion: pDescripcion)
        }
    }
    
    @IBAction func BtnActualizarImg(sender: AnyObject) {    
        var idxImg:Int = self.cont3;
        if(idxImg >= 30) {
            idxImg = 1;
        } else {
            idxImg = idxImg + 1;
        }
        let urlImg = "http://www.checkingsoft.com/imagenes/\(idxImg).jpeg";
        
        if let url = NSURL(string: urlImg) {
            if let data = NSData(contentsOfURL: url){
                myImageView.contentMode = UIViewContentMode.ScaleAspectFit
                myImageView.image = UIImage(data: data)
            }
        }
    }
    
    func renderMap(_latitud: CLLocationDegrees, _longitud: CLLocationDegrees,
        _direccion: String, _descripcion: String){
            
            let ubicacion = CLLocationCoordinate2D(latitude: _latitud, longitude: _longitud)
            //let ubicacion = CLLocationCoordinate2D(latitude: la2, longitude: lo2)
            
            let Span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegion(center: ubicacion, span: Span)
            miMapa.setRegion(region, animated: true)
            
            //Establer el Pin de la Ubicacion
            let annotation = MKPointAnnotation()
            annotation.coordinate = ubicacion
            annotation.title = _direccion;
            annotation.subtitle = _descripcion
            miMapa.addAnnotation(annotation)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Cargar IMAGEN ::::::::: INICIO :::::::::::::
    @IBAction func uploadButtonTapped(sender: AnyObject) {
        myImageUploadRequest()
    }
    
    @IBAction func selectPhotoButton(sender: AnyObject) {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        myImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func myImageUploadRequest()
    {
        let myUrl = NSURL(string: "http://www.checkingsoft.com/upload.php");
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        let param = [
            "firstName" : "AppleTV",
            "lastName" : "test",
            "userId" : "100"
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = UIImageJPEGRepresentation(myImageView.image, 1)
        
        if(imageData==nil) { return; }
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        myActivityIndicator.startAnimating();
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            // You can print out response object
            println("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("****** response data = \(responseString!)")
            
            dispatch_async(dispatch_get_main_queue(),{
                self.myActivityIndicator.stopAnimating()
                //self.myImageView.image = nil;
            });
            
        }
        
        task.resume()
        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        
        var body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("–-\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "Imagen100.jpg"
        let mimetype = "image/jpg"
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    //Cargar IMAGEN ::::::::::::: FIN :::::::::::::::::::::
    
    @IBAction func BtnCancelar(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lblDescripcion: UITextField!
    @IBOutlet weak var lblDireccion: UITextField!
    @IBOutlet weak var lblLongitud: UITextField!
    @IBOutlet weak var lblLatitud: UITextField!
    @IBOutlet weak var lblTitulo: UITextField!
    @IBAction func BtnGuardar(sender: AnyObject) {
        var ref = Firebase(url: "https://ucbcba.firebaseio.com/aviso")
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let contxt:NSManagedObjectContext = appDel.managedObjectContext!
        //let en = NSEntityDescription.entityForName("Ubicacion", inManagedObjectContext: contxt)
        
        if (itemSelected != ""){
            //Actualizar porque el currentItem no es Nulo
            /*currentItem.setValue(txtNombre.text, forKey: "nombre");
            currentItem.setValue(txtDescripcion.text, forKey: "descripcion");
            currentItem.setValue(txtLatitud.text, forKey: "latitud");
            currentItem.setValue(txtLongitud.text, forKey: "longitud");*/
            var hopperRef = ref.childByAppendingPath(self.itemSelected)
            var titulo = ["titulo": "\(lblTitulo.text)"]
            hopperRef.updateChildValues(titulo)
            
            var descripcion = ["descripcion": "\(lblDescripcion.text)"]
            hopperRef.updateChildValues(descripcion)
            
            var direccion = ["direccion": "\(lblDireccion.text)"]
            hopperRef.updateChildValues(direccion)
            
        } else {
            //Para Crear uno Nuevo, create Item
            /*var newItem = Ubicacion(entity:en!, insertIntoManagedObjectContext:contxt)
            newItem.nombre = txtNombre.text
            newItem.descripcion = txtDescripcion.text
            newItem.longitud = txtLongitud.text
            newItem.latitud = txtLatitud.text
            println(newItem)*/
            // Write data to Firebase
            
            //if (lblTitulo.text == nil)
            
            if(self.cont3 >= 30) {
                self.cont3 = 1;
            } else {
                self.cont3 = self.cont3 + 1;
            }
            let urlImg = "http://www.checkingsoft.com/imagenes/\(self.cont3).jpeg";
            println(urlImg);
            
            self.cont = self.cont + 1;
            
            let item = ["descripcion": "\(lblDescripcion.text)", "direccion": "\(lblDireccion.text)", "imagen": "\(urlImg)", "latitud": "\(lblLatitud.text)", "longitud": "\(lblLongitud.text)", "titulo": "\(lblTitulo.text)", "usuario": "\(self.cont)"]
            
            //aviso = ["descripcion": "Hola", "direccion": "Calle 1", "imagen": "http://www.checkingsoft.com/Json/images/logo.jpg", "latitud": -22.32615,"longitud": -66.123458,"titulo":"Aviso de Prueba","usuario":0]
            
            //println(item)
            var aviso = item;
            //var avisos = ref.refirebase.child("aviso")
            
            //Contador Registro
            var ref2 = Firebase(url:"https://ucbcba.firebaseio.com/contador");
            ref2.setValue(self.cont)
            
            //Contador Imagen
            var ref3 = Firebase(url:"https://ucbcba.firebaseio.com/contador_img");
            
            ref3.setValue(self.cont3)
            
            //Guardar Registro
            var myString = String(self.cont)
            ref.childByAppendingPath(myString).setValue(aviso)
        }
        
        //println("Registro Insertado.... Cod: \(self.cont)");
        /*let postRef = ref.childByAppendingPath("aviso")
        let post1 = ["descripcion": "\(lblDescripcion.text)", "direccion": "\(lblDireccion.text)", "imagen": "\(urlImg)", "latitud": "\(lblLatitud.text)", "longitud": "\(lblLongitud.text)", "titulo": "\(lblTitulo.text)", "usuario": "0"]
        let post1Ref = ref.childByAutoId()
        post1Ref.setValue(post1)*/
        
        //var ref2 = Firebase(url:"https://ucbcba.firebaseio.com/contador");
        //ref2.setValue(self.cont)
       
        //Guardar Todo ya sea por Update o Insert
        //contxt.save(nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

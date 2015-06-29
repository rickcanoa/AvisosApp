
import UIKit
import MapKit

class VCAvisoDetalle: UIViewController {
    
    @IBOutlet var itemSelect: UILabel!
    var itemSelected:String = "0"
    
    @IBOutlet weak var LblDescripcion: UITextView!
    @IBOutlet weak var LblTitulo: UILabel!
    @IBOutlet weak var miImagen: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(itemSelected);
        
        let myUrl = "https://ucbcba.firebaseio.com/aviso/" + itemSelected;
        var ref = Firebase(url: myUrl);
        ref.observeEventType(.Value, withBlock: { snapshot in
            println(snapshot.value)
            self.LblDescripcion.text = snapshot.value.objectForKey("descripcion") as? String
            self.LblTitulo.text = snapshot.value.objectForKey("titulo") as? String
            
            let urlImg = snapshot.value.objectForKey("imagen") as! String;
            if let url = NSURL(string: urlImg) {
                if let data = NSData(contentsOfURL: url){
                    self.miImagen.contentMode = UIViewContentMode.ScaleAspectFit
                    self.miImagen.image = UIImage(data: data)
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
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderMap(_latitud: CLLocationDegrees, _longitud: CLLocationDegrees,
        _direccion: String, _descripcion: String){
            
            let ubicacion = CLLocationCoordinate2D(latitude: _latitud, longitude: _longitud)
            //let ubicacion = CLLocationCoordinate2D(latitude: la2, longitude: lo2)
            
            let Span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegion(center: ubicacion, span: Span)
            mapView.setRegion(region, animated: true)
            
            //Establer el Pin de la Ubicacion
            let annotation = MKPointAnnotation()
            annotation.coordinate = ubicacion
            annotation.title = _direccion;
            annotation.subtitle = _descripcion
            mapView.addAnnotation(annotation)
    }
    
    @IBAction func btnCancelarPress(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func btnModificarPress(sender: AnyObject) {
        
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //println("Variable..")
        if (segue.identifier == "modificar")
        {
            let desti = segue.destinationViewController as! DetailViewController
            desti.itemSelected = itemSelected
        }
        
    }
    
}

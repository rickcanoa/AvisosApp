//
//  ListAvisoTableViewController.swift
//  AvisosApp
//
//  Created by Richard Canoa on 20/5/15.
//  Copyright (c) 2015 Richard Canoa. All rights reserved.
//

import UIKit
import SwiftHTTP
import ObjectMapper
import CoreData

class ListAvisoTableViewController: UITableViewController {
    
    var listAvisos:Array<AnyObject> = []
    var cont = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        println("Cargando Datos...")
        let appD:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //let context:NSManagedObjectContext = appD.managedObjectContext!
        //let freq = NSFetchRequest (entityName: "Ubicacion")
        
        //Inicializar todo el rest api
        var request = HTTPTask()
        //request.requestSerializer = HTTPRequestSerializer()
        //request.requestSerializer.headers["GetAllAvisoIOSResult"] = "SomeValue"
        //request.responseSerializer = JSONResponseSerializer()
        //http://200.105.139.46/Json/getAvisos
        request.GET("https://ucbcba.firebaseio.com/aviso.json", parameters: nil, success:{(response: HTTPResponse) in
            if let data = response.responseObject as? NSData {
                let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                //NSUTF8StringEncoding
                //Handler del Error
                var jsonErrorOptional: NSError?
                //Parsear Dato Stream a Json
                //println("response \(str)")
                let jsonOptional: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonErrorOptional)
                if(jsonOptional != nil) {
                    //Convertir JSON a Array
                    //Usar Let es como la validacion si no se puede convertir al tipo deseado
                    if var statusArray: Array<AnyObject> = jsonOptional as? Array {
                        // map a list of restaurant from array
                        self.listAvisos = Mapper<Aviso>().mapArray(statusArray)!
                        // refresh table
                        self.tableView.reloadData()
                        //println(self.listAvisos)
                        
                        /*//Iterar cada elemento del Array
                        for rest in statusArray{
                        //Mapear a Json a Object
                        let aviso:Aviso = Mapper<Aviso>().map(rest)!
                        //Imprimir el Elemento del Objeto
                        //println("rest \(aviso._descripcion)")
                        var titulo = aviso._titulo
                        println(aviso)
                        //Luego de eso Enviar a un List View
                        //self.nameRest.text = titulo!
                        }*/
                    }
                }
            }
            
            }, failure: {(error: NSError, response: HTTPResponse?) -> Void in
                println("got an error: \(error)")
        })
        
        //Mostrar los datos en el TableView
        //tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listAvisos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var _aviso:Aviso = self.listAvisos[indexPath.row] as! Aviso
        
        var cell:myCustomCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! myCustomCell
        cell.lbl.text = _aviso.titulo //tableData[indexPath.row]
        cell.desc.text = _aviso.descripcion;
        
        var imgURL: NSURL = NSURL(string: _aviso.imagen!)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    cell.img.image = UIImage(data: data)
                }
        })
        
        //println(_aviso.titulo!)
        //println("Contador: \(cont)")
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //println("Variable..")
        if (segue.identifier == "segueDetalle")
        {   println("NEXT...")
            var seletedIndex = self.tableView.indexPathForSelectedRow()?.row
            var _aviso:Aviso = self.listAvisos[seletedIndex!] as! Aviso
            let desti = segue.destinationViewController as! VCAvisoDetalle
            
           // _aviso:Aviso = self.listAvisos[seletedIndex] as! Aviso
            
            println(_aviso.usuario);
            desti.itemSelected = _aviso.usuario!
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

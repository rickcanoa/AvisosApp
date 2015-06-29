//
//  Aviso.swift
//  AvisosApp
//
//  Created by Richard Canoa on 20/5/15.
//  Copyright (c) 2015 Richard Canoa. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
class Aviso: Mappable {
    var descripcion:String!
    var direccion:String!
    var imagen:String?
    var latitud:String!
    var longitud:String!
    var titulo:String?
    var usuario:String?
    //init(){}
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    // Mappable
    func mapping(map: Map) {
        descripcion <- map["descripcion"]
        direccion <- map["direccion"]
        imagen <- map["imagen"]
        latitud <- map["latitud"]
        longitud <- map["logititud"]
        titulo <- map["titulo"]
        usuario <- map["usuario"]
    }
}
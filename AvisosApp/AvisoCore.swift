//
//  AvisoCore.swift
//  AvisosApp
//
//  Created by Richard Canoa on 21/5/15.
//  Copyright (c) 2015 Richard Canoa. All rights reserved.
//

import Foundation
import CoreData

class AvisoCore: NSManagedObject {

    @NSManaged var titulo: String
    @NSManaged var descripcion: String
    @NSManaged var latitud: String
    @NSManaged var longitud: String
    @NSManaged var imagen: String
    @NSManaged var direccion: String
    @NSManaged var usuario: String
}

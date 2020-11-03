//
//  Recipe.swift
//  Recipe
//
//  Created by Aidan Lee on 02/11/2020.
//

import Foundation
import RealmSwift

class Recipe: Object{
    @objc dynamic var id: Int = 0
    @objc dynamic var Rname: String = ""
    @objc dynamic var RecType: String = ""
    @objc dynamic var Ingredients: String = ""
    @objc dynamic var Steps: String = ""
    @objc dynamic var url: String = ""
    
    override static func primaryKey() -> String? {
            return "id"
        }
}

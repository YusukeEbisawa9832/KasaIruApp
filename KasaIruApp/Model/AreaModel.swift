//
//  AreaModel.swift
//  KasaIruApp
//
//  Created by 海老沢優典 on 2023/11/27.
//

import Foundation
import RealmSwift

class AreaModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var prefecture: String = ""
    @objc dynamic var municipality: String = ""
    @objc dynamic var lat: String = ""
    @objc dynamic var lon: String = ""
}
